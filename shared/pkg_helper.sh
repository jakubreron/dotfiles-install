#!/usr/bin/env bash

case "$OS" in
  Linux)
    if ! command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
      log_progress "Installing AUR helper: $DI_AUR_HELPER"

      path="$DI_GIT_CLONE_PATH/$DI_AUR_HELPER"
      clone_git_repo "https://aur.archlinux.org/$DI_AUR_HELPER.git" "$path"

      (cd "$path" && makepkg -si "$path")
      rm -rf "$path"
    else
      log_status "AUR helper '$DI_AUR_HELPER' is already installed"️
    fi

    ;;
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      log_progress "Installing brew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      log_status "Brew is already installed"️
    fi
    ;;
esac
