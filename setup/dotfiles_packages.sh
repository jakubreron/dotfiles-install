#!/bin/sh

aur_helper="paru"

install_aur_helper() {
  if command -v $aur_helper &> /dev/null; then
    path="/home/$user/Downloads/$aur_helper"
    git clone "https://aur.archlinux.org/$aur_helper.git" "$path" || exit
    cd "$path" || exit
    makepkg -si  
    cd ..
    rm -rf "$path"
  fi
}

install_pkglists() {
  if command -v $aur_helper &> /dev/null; then
    install_pkg - < "$dotfiles_dir/pkglists/$pkgtype/pacman.txt";
  fi
}

setup_dotfiles_packages() {
  install_aur_helper
  install_pkglists
}
