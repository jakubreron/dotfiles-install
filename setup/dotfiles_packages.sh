#!/bin/sh

aur_helper="paru"
install_aur_helper() {
  if ! command -v $aur_helper &> /dev/null; then
    path="$git_clone_path/$aur_helper"
    git clone "https://aur.archlinux.org/$aur_helper.git" "$path"
    cd "$path" || exit
    makepkg -si  
    cd ..
    rm -rf "$path"
  fi
}

install_pkglists() {
  if command -v $aur_helper &> /dev/null; then
    install_pkg - < "$pkglists_dir/$pkgtype/pacman.txt";
  fi
}

setup_dotfiles_packages() {
  install_aur_helper
  install_pkglists
}
