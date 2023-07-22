#!/usr/bin/env bash

log_progress "Updating the system via pacman"
remove_db_lock
sudo pacman --noconfirm -Syu


for package in curl ca-certificates base-devel ntp laptop-detect reflector rsync; do
  install_pkg "$package"
done


if ! command -v reflector >/dev/null 2>&1; then
  log_progress "Installing reflector"
fi
log_progress "Getting the fastest mirrors before installing the dotfiles packages"
sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist


if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
  log_progress "Installing dotfiles packages"
  install_pkg - < "$DI_PKGLISTS_DIR/$DI_PKG_TYPE/pacman.txt";
fi
