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

  # A local CLAUDE.md is kept as a backup; ~/.claude must exist so stow links the file, not the whole directory
  mkdir -p ~/.claude
  if [ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
    mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak.$(date +%s)
  fi

  # Omarchy's herdr config is kept as a backup; ~/.config/herdr also holds sockets, logs and plugins,
  # so stow links config.toml only
  mkdir -p ~/.config/herdr
  if [ -f ~/.config/herdr/config.toml ] && [ ! -L ~/.config/herdr/config.toml ]; then
    mv ~/.config/herdr/config.toml ~/.config/herdr/config.toml.bak.$(date +%s)
  fi

  cd "$REPO_NAME"
  stow tmux
  stow nvim
  stow starship
  stow git
  stow bash
  stow --no-folding claude
  stow --no-folding herdr

  # Ctrl+h/j/k/l across herdr panes and Neovim splits; the version matches the nvim plugin spec
  if command -v herdr &>/dev/null && ! herdr plugin list 2>/dev/null | grep -q "vim-herdr-navigation"; then
    herdr plugin install paulbkim-dev/vim-herdr-navigation --ref 7873100eb47212269005c693effb2a844986b30f
  fi
else
  echo "Failed to clone the repository."
  cd "$ORIGINAL_DIR"
  exit 1
fi
cd "$ORIGINAL_DIR"
