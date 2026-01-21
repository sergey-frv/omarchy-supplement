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

  # Create backup folder
  if [ ! -d "backup" ]; then
    mkdir backup
  fi

  # Backup waybar configs
  if [ -d "backup/waybar" ]; then
    echo "waybar configs backup already exists"
  else
    cp -r ~/.config/waybar ./backup/
  fi
  rm -rf ~/.config/waybar/config.jsonc ~/.config/waybar/style.css
  stow waybar
  omarchy-restart-waybar

  # Backup walker configs
  if [ -d "backup/walker" ]; then
    echo "walker configs backup already exists"
  else
    cp -r ~/.config/walker ./backup/
  fi
  rm -rf ~/.config/walker/config.toml
  stow walker
  omarchy-restart-walker
else
  echo "Failed to clone the repository."
  cd "$ORIGINAL_DIR"
  exit 1
fi
cd "$ORIGINAL_DIR"
