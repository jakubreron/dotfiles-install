#!/bin/sh

remove_db_lock() {
  [ -f /var/lib/pacman/db.lck ] && sudo rm /var/lib/pacman/db.lck
}

install_pkg() {
  remove_db_lock

  if command -v paru &> /dev/null; then
    pkg_manager=paru
  elif command -v yay &> /dev/null; then
    pkg_manager=yay
  else
    pkg_manager=pacman
  fi

	sudo $pkg_manager --noconfirm --needed -S "$1"
}
