#!/usr/bin/env bash

update_system() {
  log_progress "Updating the system via pacman"

  remove_db_lock
  sudo pacman --noconfirm -Syu
}

install_core_packages() {
  log_progress "Installing core packages"
  install_pkg curl ca-certificates base-devel ntp laptop-detect reflector rsync git
}

get_fastest_mirrors() {
  if ! command -v reflector >/dev/null 2>&1; then
    log_progress "Installing reflector"
  fi

  if command -v reflector >/dev/null 2>&1; then
    reflector_state_file="$HOME/.cache/reflector_updated"

    if [ ! -f "$reflector_state_file" ] >/dev/null 2>&1; then
      log_progress "Getting the fastest mirrors before installing the dotfiles packages"
      sudo reflector -f 30 -l 30 -c Japan --number 10 --verbose --save /etc/pacman.d/mirrorlist

      echo "Reflector was already updated" >"$reflector_state_file"
    fi
  fi
}

install_pkglists() {
  if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
    log_progress "Installing dotfiles packages"
    install_pkg - <"$DI_PKGLISTS_DIR/$DI_PKG_TYPE/pacman.txt"
  else
    log_error "AUR Helper not detected, quitting"
    exit 1
  fi
}

update_system
install_core_packages
get_fastest_mirrors
install_pkglists
setup_postinstall_config
