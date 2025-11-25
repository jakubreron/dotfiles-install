#!/usr/bin/env bash

log_progress "Updating software packages"
sudo softwareupdate -ia --background

log_progress "Installing dotfiles packages"
brew bundle install --file "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/Brewfile"
