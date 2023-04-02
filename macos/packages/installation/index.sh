#!/usr/bin/env bash

install_pkglists() {
  if command -v "$DI_PKG_MANAGER_HELPER" >/dev/null 2>&1; then
    log_progress "Installing dotfiles packages"
    cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew.txt" | xargs pkg_install
    cat "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/brew-casks.txt" | xargs pkg_install -- --cask
  fi
}

install_pkglists
