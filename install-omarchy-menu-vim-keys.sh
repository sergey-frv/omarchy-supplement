#!/bin/bash

# Vim navigation in the Omarchy shell menus:
#   Ctrl+J / Ctrl+N  down        Ctrl+H  left (Omarchy menu: back)
#   Ctrl+K / Ctrl+P  up          Ctrl+L  right (Omarchy menu: open)
# Covered: Omarchy menu, clipboard, emojis, theme/background picker. The app grid (Super+Alt+Space,
# Apps item of the menu) belongs to the dock plugin; a third-party clone of it gets no app list.
# Keys are matched by physical key, so they work in the ru layout too.
#
# Each built-in plugin is cloned with `omarchy plugin clone` into
# ~/.config/omarchy/plugins/<user>.<name>/ and its key handler is patched. The script links itself
# into the post-update hook; a clone is rebuilt when the built-in plugin, VimKeys.js or this script
# changes, and the shell is restarted after a rebuild. When a patch target is missing, the clone is
# removed and the built-in plugin comes back.

set -euo pipefail

SCRIPT_PATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
VIM_KEYS_JS="$SCRIPT_DIR/omarchy-menu-vim-keys/VimKeys.js"
BUILTIN_DIR="${OMARCHY_PATH:-/usr/share/omarchy}/shell/plugins"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
HOOK_PATH="$HOME/.config/omarchy/hooks/post-update.d/omarchy-menu-vim-keys"
USER_PREFIX="${USER:-$(id -un)}"
STAMP_FILE=".vim-keys-source"

UP='event.key === Qt.Key_Up'
DOWN='event.key === Qt.Key_Down'
LEFT='Util.readingKey(event) === Qt.Key_Left'
RIGHT='Util.readingKey(event) === Qt.Key_Right'

failed=0
changed=0

log() { echo "omarchy-menu-vim-keys: $*"; }

source_hash() {
  local src_dir="$1"
  {
    (cd "$src_dir" && find . -type f -print0 | sort -z | xargs -0 sha256sum)
    sha256sum "$VIM_KEYS_JS" "$SCRIPT_PATH"
  } | sha256sum | cut -d' ' -f1
}

plugin_enabled() {
  omarchy plugin list --json | jq -e --arg id "$1" 'any(.[]; .id == $id and .enabled)' >/dev/null
}

# Removes a clone; the shell then loads the built-in plugin again.
drop_clone() {
  local clone_id="$1" clone_dir="$2"
  if [[ -f $clone_dir/$STAMP_FILE ]]; then
    plugin_enabled "$clone_id" && omarchy plugin disable "$clone_id" >/dev/null
    rm -rf "$clone_dir"
    omarchy-shell shell rescanPlugins >/dev/null
  else
    # A clone made by hand: omarchy keeps a backup of it.
    omarchy plugin remove "$clone_id" --yes
  fi
}

# Wraps one condition: "<cond>" -> "(<cond> || VimKeys.<fn>(event))".
patch_condition() {
  local file="$1" cond="$2" fn="$3"
  local count
  count=$(grep -cF -- "$cond" "$file" || true)
  if [[ $count != 1 ]]; then
    log "$(basename "$file"): expected one '$cond', found $count"
    return 1
  fi
  COND="$cond" REPL="($cond || VimKeys.$fn(event))" perl -pi -e 's/\Q$ENV{COND}\E/$ENV{REPL}/' "$file"
}

patch_clone() {
  local clone_dir="$1" qml="$2"
  shift 2
  local file="$clone_dir/$qml" pair

  cp "$VIM_KEYS_JS" "$clone_dir/VimKeys.js"
  grep -q '^import QtQuick$' "$file" || { log "$qml: no 'import QtQuick' line"; return 1; }
  sed -i '0,/^import QtQuick$/s//&\nimport "VimKeys.js" as VimKeys/' "$file"

  for pair in "$@"; do
    patch_condition "$file" "${pair%|*}" "${pair##*|}" || return 1
  done
}

# install_plugin <name> <qml file> "<condition>|<VimKeys function>"...
install_plugin() {
  local name="$1" qml="$2"
  shift 2
  local src_dir="$BUILTIN_DIR/$name"
  local clone_id="$USER_PREFIX.$name"
  local clone_dir="$PLUGINS_DIR/$clone_id"
  local hash

  [[ -d $src_dir ]] || { log "$name: built-in plugin not found at $src_dir"; return 1; }
  hash=$(source_hash "$src_dir")

  if [[ -f $clone_dir/$STAMP_FILE && $(<"$clone_dir/$STAMP_FILE") == "$hash" ]] && plugin_enabled "$clone_id"; then
    log "$clone_id: up to date"
    return 0
  fi

  changed=1
  [[ -e $clone_dir ]] && drop_clone "$clone_id" "$clone_dir"

  omarchy plugin clone "omarchy.$name" >/dev/null || { log "$name: clone failed"; return 1; }
  if ! patch_clone "$clone_dir" "$qml" "$@"; then
    echo "$hash" >"$clone_dir/$STAMP_FILE"
    drop_clone "$clone_id" "$clone_dir"
    log "$name: patch failed, built-in plugin restored"
    return 1
  fi
  echo "$hash" >"$clone_dir/$STAMP_FILE"
  omarchy-shell shell rescanPlugins >/dev/null
  log "$clone_id: installed"
}

install_plugin menu Menu.qml "$UP|up" "$DOWN|down" "$LEFT|left" "$RIGHT|right" || failed=1
install_plugin clipboard Clipboard.qml "$UP|up" "$DOWN|down" || failed=1
install_plugin emojis Emojis.qml "$UP|up" "$DOWN|down" "$LEFT|left" "$RIGHT|right" || failed=1
install_plugin image-picker ImagePicker.qml "$LEFT|prev" "$RIGHT|next" || failed=1

mkdir -p "$(dirname "$HOOK_PATH")"
ln -sfn "$SCRIPT_PATH" "$HOOK_PATH"

# Several plugin reloads in a row leave the cloned overlays without a live instance;
# a shell restart loads them cleanly.
if (( changed )); then
  omarchy restart shell >/dev/null
  log "shell restarted"
fi

if (( failed )); then
  omarchy-notification-send -g 󰌌 "Vim keys in menus" "Patch failed, see omarchy update output" 2>/dev/null || true
  exit 1
fi
