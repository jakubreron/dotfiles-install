#!/usr/bin/env bash

get_fastest_mirrors() {
  if ! command -v reflector >/dev/null 2>&1; then
    log_progress "Installing reflector"
  fi

  log_progress "Getting the fastest mirrors before installing the dotfiles packages"
  sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist
}

install_pkglists() {
  if command -v "$DI_PKG_MANAGER_HELPER" >/dev/null 2>&1; then
    log_progress "Installing dotfiles packages"
    install_pkg - < "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/pacman.txt";
  fi
}

get_fastest_mirrors
install_pkglists
