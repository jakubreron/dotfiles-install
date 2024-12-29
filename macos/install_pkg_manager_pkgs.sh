#!/usr/bin/env bash

update_system() {
  log_progress "Updating software packages"
  softwareupdate -i -a
}

install_pkglists() {
  log_progress "Installing dotfiles packages"
  brew bundle install --file "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/Brewfile"
}

update_system
install_pkglists
