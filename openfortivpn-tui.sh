#!/usr/bin/env bash

set -euo pipefail
# ────────────────────────────────────────────────────────────────────────────────
#  Check required dependencies
# ────────────────────────────────────────────────────────────────────────────────

check_dependency() {
  local cmd="$1"
  local pkg="$2"
  local install_cmd="$3"

  if ! command -v "$cmd" &>/dev/null; then
    echo
    echo "┌──────────────────────────────────────────────────────────────┐"
    echo "│  ERROR: Required tool '$cmd' is not installed                │"
    echo "│                                                              │"
    echo "│  Package:   $pkg                                             │"
    echo "│  Install:   $install_cmd                                     │"
    echo "└──────────────────────────────────────────────────────────────┘"
    echo
    exit 1
  fi
}

check_dependency "openfortivpn" "openfortivpn" "yay -S openfortivpn"
check_dependency "gum" "gum" "yay -S gum"

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/openfortivpn-profiles.conf"
PIDFILE="/tmp/openfortivpn-${USER}.pid"
LOGFILE="/tmp/openfortivpn-${USER}.log"
OFP="/usr/bin/openfortivpn"

# ────────────────────────────────────────────────────────────────────────────────
#  Styling helpers
# ────────────────────────────────────────────────────────────────────────────────

header() {
  gum style \
    --foreground 212 --border-foreground 212 \
    --border double --align center --width 60 --margin "1 2" --padding "1 2" \
    "$1"
}

error() {
  gum style --foreground 196 $"Error: $*" >&2
  exit 1
}
success() { gum style --foreground 82 "$*"; }
info() { gum style --foreground 39 "$*"; }

# ────────────────────────────────────────────────────────────────────────────────
#  Load profiles
# ────────────────────────────────────────────────────────────────────────────────

load_profiles() {
  [[ -f "$CONFIG" ]] || error "Config not found:
  Create $CONFIG
  Format: name | host:port | [extra args]"

  mapfile -t lines < <(grep -vE '^\s*(#|$)' "$CONFIG" | sed 's/[[:space:]]*|[[:space:]]*/|/g')

  ((${#lines[@]} > 0)) || error "No profiles found in config"

  profile_names=()
  profiles=()

  for line in "${lines[@]}"; do
    name="${line%%|*}"
    rest="${line#*|}"
    profile_names+=("$name")
    profiles+=("$rest")
  done
}

# ────────────────────────────────────────────────────────────────────────────────
#  State checks
# ────────────────────────────────────────────────────────────────────────────────

is_running() {
  [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

# ────────────────────────────────────────────────────────────────────────────────
#  Start VPN + log watching + SAML URL detection
# ────────────────────────────────────────────────────────────────────────────────

start_vpn() {
  local host_port extra cmd
  host_port="$1"
  extra="${2:-}"

  # ── Early sudo check / prompt ─────────────────────────────────────────────
  info "Requesting sudo privileges (needed to start openfortivpn)..."
  if ! sudo -v; then
    error "sudo authentication failed — cannot continue"
  fi

  cmd=("$OFP" "$host_port" --saml-login $extra)

  gum style --foreground 212 "Connecting to $host_port"

  # Start openfortivpn in background, redirect output to log
  sudo "${cmd[@]}" >"$LOGFILE" 2>&1 &
  echo $! >"$PIDFILE"

  info "VPN process started (pid $(cat "$PIDFILE"))"
  info "Log file: $LOGFILE"
  info "Waiting for SAML URL or connection..."

  # Watch log in real time and look for SAML URL
  local found_url=""
  tail -f "$LOGFILE" --pid "$(cat "$PIDFILE")" | while IFS= read -r line; do
    echo "$line"

    # Look for SAML auth prompt
    if [[ -z "$found_url" ]]; then
      if [[ "$line" =~ Authenticate\ at\ \'(https?://[^\']+)\' ]]; then
        found_url="${BASH_REMATCH[1]}"
        info "SAML authentication required!"
        info "Opening browser → $found_url"
        xdg-open "$found_url" 2>/dev/null ||
          info "Could not open browser automatically. Please visit: $found_url"
        break # we found it → can stop searching
      fi
    fi

    # Optional: stop tail early if tunnel is up (heuristic)
    if [[ "$line" =~ "Established connection" || "$line" =~ "PPP negotiation complete" ]]; then
      success "Tunnel appears to be up!"
      break
    fi
  done &

  # Give some time for startup
  sleep 2

  if ! is_running; then
    error "VPN failed to start\nCheck log: $LOGFILE"
  fi

  success "VPN is running. Authenticate in the browser if prompted."
  info "Press Ctrl+C in this terminal to stop watching log (VPN will continue running)"
  info "To disconnect:   $0 stop"
  info "To see full log: $0 log"
}

# ────────────────────────────────────────────────────────────────────────────────
#  Stop / Log
# ────────────────────────────────────────────────────────────────────────────────

stop_vpn() {
  is_running || {
    info "VPN is not running"
    return
  }

  local pid=$(cat "$PIDFILE")
  gum confirm "Disconnect VPN (pid $pid)?" || exit 0

  sudo kill -INT "$pid" 2>/dev/null || true
  sleep 2

  if ! is_running; then
    rm -f "$PIDFILE"
    success "VPN disconnected"
  else
    error "Could not stop the process"
  fi
}

show_log() {
  [[ -f "$LOGFILE" ]] && gum pager <"$LOGFILE" || info "Log file not created yet"
}

# ────────────────────────────────────────────────────────────────────────────────
#  CLI + menu loop
# ────────────────────────────────────────────────────────────────────────────────

case "${1:-}" in
stop)
  stop_vpn
  exit
  ;;
log)
  show_log
  exit
  ;;
"") : ;;
*)
  echo "Usage: $(basename "$0") [stop|log]"
  exit 1
  ;;
esac

load_profiles

while true; do
  clear # <─── Clear screen at the beginning of each loop
  header "OpenFortiVPN SAML"

  if is_running; then
    gum style --bold --foreground 82 "Status: Connected (pid $(cat "$PIDFILE" 2>/dev/null || echo '?'))"
  else
    gum style --bold --foreground 196 "Status: Disconnected"
  fi

  ACTION=$(gum choose \
    --header "Choose action:" \
    --height 8 \
    "Connect" \
    "Disconnect" \
    "View log" \
    "Exit")

  case "$ACTION" in
  "Connect")
    if is_running; then
      gum confirm "VPN is already running. Reconnect?" || continue
      stop_vpn
    fi

    CHOICE=$(gum choose --header "Select profile" "${profile_names[@]}")
    [[ -z "$CHOICE" ]] && continue

    for i in "${!profile_names[@]}"; do
      [[ "${profile_names[i]}" == "$CHOICE" ]] && break
    done

    full="${profiles[i]}"
    host_port="${full%%|*}"
    extra="${full#*|}"
    [[ "$extra" == "$host_port" ]] && extra=""

    start_vpn "$host_port" "$extra"
    ;;

  "Disconnect") stop_vpn ;;
  "View log") show_log ;;
  "Exit" | "") exit 0 ;;
  esac

  echo
done
