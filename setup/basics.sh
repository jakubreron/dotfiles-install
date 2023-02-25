#!/bin/sh

setup_core_packages() {
  remove_db_lock
  sudo pacman --noconfirm --needed -Sy libnewt

  for x in curl ca-certificates base-devel git ntp zsh; do
    install_pkg "$x"
  done
}

# TODO: fix with sudo
setup_core_settings() {
  # Make pacman colorful, concurrent downloads and Pacman eye-candy.
  grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
  sed -Ei "s/^#(ParallelDownloads).*/\1 = 15/;/^#Color$/s/#//" /etc/pacman.conf

  # Use all cores for compilation.
  sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

  # Allow wheel users to sudo with password and allow several system commands
  # (like `shutdown` to run without password).
  echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/00-larbs-wheel-can-sudo
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/pacman -Syyuw --noconfirm,/usr/bin/pacman -S -u -y --config /etc/pacman.conf --,/usr/bin/pacman -S -y -u --config /etc/pacman.conf --" >/etc/sudoers.d/01-larbs-cmds-without-password
  echo "Defaults editor=/usr/bin/nvim" >/etc/sudoers.d/02-larbs-visudo-editor
  mkdir -p /etc/sysctl.d
  echo "kernel.dmesg_restrict = 0" > /etc/sysctl.d/dmesg.conf
}

create_dirs() {
  mkdir /home/$user/{Documents,Downloads,Music,Pictures,Videos,Cloud,Storage}
  mkdir -p /home/$user/.local/{bin,share,src}
  mkdir -p "$dotfiles_dir"
}

clone_dotfiles_repos() {
  git clone "$dotfiles_repo" "$dotfiles_dir/voidrice" || return 1
  git clone "$pkglists_repo" "$dotfiles_dir/pkglists" || return 1
}

replace_stow() {
  stow --adopt --target="/home/$user" --dir="$dotfiles_dir" voidrice
}

setup_basics() {
  setup_core_packages
  # setup_core_settings
  create_dirs
  clone_dotfiles_repos
  replace_stow
}
