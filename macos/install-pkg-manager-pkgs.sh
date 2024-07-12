#!/usr/bin/env bash

update_system() {
  log_progress "Updating software packages via softwareupdate"
  softwareupdate -i -a
}

install_pkglists() {
  if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
    log_progress "Installing dotfiles packages"

    cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew.txt" | xargs install_pkg
    cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew-casks.txt" | xargs install_pkg -- --cask
  fi
}

update_system
install_pkglists
