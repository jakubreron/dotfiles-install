#!/usr/bin/env bash

update_system() {
  log_progress "Updating the system via pacman"
  remove_db_lock
  sudo pacman --noconfirm -Syu
}

install_core_packages() {
  for package in curl ca-certificates base-devel ntp laptop-detect reflector rsync; do
    install_pkg "$package"
  done
}

get_fastest_mirrors() {
  if ! command -v reflector >/dev/null 2>&1; then
    log_progress "Installing reflector"
  fi

  if command -v reflector >/dev/null 2>&1; then
    log_progress "Getting the fastest mirrors before installing the dotfiles packages"
    sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist
  fi
}

if laptop-detect > /dev/null; then
  if ! command -v thermald >/dev/null 2>&1; then
    log_progress "Laptop detected, installing thermald"
    install_pkg thermald 
  fi

  if command -v thermald >/dev/null 2>&1; then
    sudo systemctl enable thermald --now
  fi
fi

install_pkglists() {
  if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
    log_progress "Installing dotfiles packages"
    install_pkg - < "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/pacman.txt";
  else
    log_error "AUR Helper not detected, quitting"
    exit
  fi
}

update_system
install_core_packages
get_fastest_mirrors
install_pkglists
