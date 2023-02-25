#!/bin/sh

install_aur_helper() {
  path="/home/$user/Downloads/paru"
  git clone https://aur.archlinux.org/paru.git "$path" || exit
  cd "$path" || exit
  makepkg -si  
  cd ..
  rm -rf "$path"
}

install_pkglists() {
  install_pkg - < "$dotfiles_dir/pkglists/$pkgtype/pacman.txt";
}

setup_dotfiles_packages() {
  install_aur_helper
  install_pkglists
}
