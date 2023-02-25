#!/bin/sh

install_aur_helper() {
  mkdir "/home/$user/Downloads/_cloned-repos"
  cd "/home/$user/Downloads/_cloned-repos" || exit
  git clone https://aur.archlinux.org/paru.git
  cd paru || exit
  makepkg -si  
}

install_pkglists() {
  paru --noconfirm --needed -S - < "$dotfiles_dir/pkglists/$pkgtype/pacman.txt";
}

setup_dotfiles_packages() {
  install_aur_helper
  install_pkglists
}
