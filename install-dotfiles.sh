#!/bin/bash

ORIGINAL_DIR=$(pwd)
REPO_URL="git@github.com:sergey-frv/dotfiles.git"
REPO_NAME="dotfiles"

is_stow_installed() {
  pacman -Qi "stow" &>/dev/null
}

if ! is_stow_installed; then
  echo "Install stow first"
  exit 1
fi

cd ~

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
  echo "Repository '$REPO_NAME' already exists. Skipping clone"
else
  git clone "$REPO_URL"
fi

# Check if the clone was successful
if [ $? -eq 0 ]; then
  echo "removing old configs"
  rm -rf ~/.config/nvim ~/.config/starship.toml ~/.local/share/nvim/ ~/.cache/nvim/ ~/.config/git/

  cd "$REPO_NAME"
  stow tmux
  stow nvim
  stow starship
  stow git
  stow bash

  # Omarchy shell plugins (cloned menu with ctrl+j / ctrl+k navigation)
  mkdir -p ~/.config/omarchy/plugins
  stow omarchy

  # Make the shell see the new plugin dir, then switch the menu to the clone
  omarchy-shell shell rescanPlugins >/dev/null
  for _ in $(seq 1 40); do
    if omarchy-plugin-list --json | jq -e 'any(.[]; .id == "sf.menu")' >/dev/null; then
      break
    fi
    sleep 0.05
  done
  omarchy plugin enable sf.menu
else
  echo "Failed to clone the repository."
  cd "$ORIGINAL_DIR"
  exit 1
fi
cd "$ORIGINAL_DIR"
