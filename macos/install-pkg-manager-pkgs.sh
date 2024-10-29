#!/usr/bin/env bash

update_system() {
  log_progress "Updating software packages"
  softwareupdate -i -a
}

install_pkglists() {
  log_progress "Installing dotfiles packages"
  cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew.txt" | xargs brew install

  log_progress "Installing dotfiles packages (casks)"
  cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew-casks.txt" | xargs brew install --cask
}

update_system
install_pkglists
