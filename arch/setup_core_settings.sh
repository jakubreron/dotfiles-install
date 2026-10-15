#!/usr/bin/env bash

setup_core_settings() {
  log_progress "Setting up core settings"

  sudo usermod -aG wheel "$USER" # sudo
  sudo usermod -aG video "$USER" # backlight

  # show  C o o o, instead of #### in progress
  grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

  # Enable multilib
  sudo sed -i '/^#\[multilib\]$/,/^#Include = \/etc\/pacman\.d\/mirrorlist$/s/^#//' /etc/pacman.conf

  sudo sed -Ei "s/^#(ParallelDownloads).*/\1 = 15/;/^#Color$/s/#//" /etc/pacman.conf

  # Allow wheel users to sudo with password and allow several system commands
  # (like `shutdown` to run without password).
  echo "%wheel ALL=(ALL:ALL) ALL" | sudo tee /etc/sudoers.d/00-wheel-can-sudo
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/pacman -Syyuw --noconfirm,/usr/bin/pacman -S -u -y --config /etc/pacman.conf --,/usr/bin/pacman -S -y -u --config /etc/pacman.conf --" | sudo tee /etc/sudoers.d/01-cmds-without-password
  echo "Defaults editor=/usr/bin/nvim" | sudo tee /etc/sudoers.d/02-visudo-editor
  echo "Defaults timestamp_timeout=1440" | sudo tee /etc/sudoers.d/03-sudo-timeout

  sudo mkdir -p /etc/sysctl.d
  echo "kernel.dmesg_restrict = 0" | sudo tee /etc/sysctl.d/dmesg.conf
  echo "export \$(dbus-launch)" | sudo tee /etc/profile.d/dbus.sh
}

setup_core_settings
