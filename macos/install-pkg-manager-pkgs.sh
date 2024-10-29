#!/usr/bin/env bash

update_system() {
  log_progress "Updating software packages via softwareupdate"
  softwareupdate -i -a
}

install_pkglists() {
  if command -v "brew" >/dev/null 2>&1; then
    log_progress "Installing dotfiles packages"

    cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew.txt" | xargs brew install
    cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew-casks.txt" | xargs brew install -- --cask
  fi
}

update_system
install_pkglists
