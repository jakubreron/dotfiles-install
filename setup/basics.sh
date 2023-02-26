#!/bin/sh
# TODO: setup infinite timeout for sudo
# TODO: setup grub options:
# ```sh
#   echo '
#     GRUB_FORCE_HIDDEN_MENU="true"
#     GRUB_HIDDEN_TIMEOUT="0"
#   ' | sudo tee -a /etc/default/grub
# ```
# sudo grub-mkconfig -o /boot/grub/grub.cfg

update_system() {
  remove_db_lock
  sudo pacman --noconfirm -Syu
}

setup_core_packages() {
  for package in curl ca-certificates base-devel git ntp zsh rust laptop-detect stow reflector rsync; do
    install_pkg "$package"
  done
}

setup_core_settings() {
  # Make pacman colorful, concurrent downloads and Pacman eye-candy.
  grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
  sudo sed -Ei "s/^#(ParallelDownloads).*/\1 = 15/;/^#Color$/s/#//" /etc/pacman.conf

  # Use all cores for compilation.
  sudo sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

  # Allow wheel users to sudo with password and allow several system commands
  # (like `shutdown` to run without password).
  echo "%wheel ALL=(ALL:ALL) ALL" | sudo tee /etc/sudoers.d/00-wheel-can-sudo
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/pacman -Syyuw --noconfirm,/usr/bin/pacman -S -u -y --config /etc/pacman.conf --,/usr/bin/pacman -S -y -u --config /etc/pacman.conf --" | sudo tee /etc/sudoers.d/01-cmds-without-password
  echo "Defaults editor=/usr/bin/nvim" | sudo tee /etc/sudoers.d/02-visudo-editor
  sudo mkdir -p /etc/sysctl.d
  echo "kernel.dmesg_restrict = 0" | sudo tee /etc/sysctl.d/dmesg.conf
}

create_dirs() {
  mkdir /home/$user/{Documents,Downloads,Music,Pictures,Videos,Cloud,Storage}
  mkdir -p /home/$user/.local/{bin,share,src}

  mkdir -p "$dotfiles_dir"
}

clone_dotfiles_repos() {
  git clone "$voidrice_repo" "$voidrice_dir"
  git clone "$pkglists_repo" "$pkglists_dir"

  git -C "$voidrice_dir" pull
  git -C "$voidrice_dir" submodule update --init --remote --recursive

  git -C "$pkglists_repo" pull
}

replace_stow() {
  stow --adopt --target="/home/$user" --dir="$dotfiles_dir" voidrice
}

set_zsh_shell() {
  chsh -s /bin/zsh "$user" >/dev/null 2>&1
  mkdir -p "/home/$user/.cache/zsh/"
}

setup_basics() {
  update_system
  setup_core_packages
  setup_core_settings
  create_dirs
  clone_dotfiles_repos
  replace_stow
  set_zsh_shell
}
