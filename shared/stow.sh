#!/usr/bin/env bash

if ! command -v stow >/dev/null 2>&1; then
  log_progress "Installing stow"
  install_pkg stow
fi

if command -v stow >/dev/null 2>&1; then
  log_progress "Creating dirs in $HOME/.local/bin to ensure correct stow"

  for dir in "$DI_DOTFILES_DIR"/.local/bin/*/; do
    dir_name=$(basename "$dir")
    mkdir -p "$HOME"/.local/bin/"$dir_name"
  done

  log_progress "Stowing the dotfiles"
  stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice
fi
