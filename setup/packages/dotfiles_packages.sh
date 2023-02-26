#!/bin/sh

install_aur_helper() {
  if ! command -v "$aur_helper" &> /dev/null; then
    path="$git_clone_path/$aur_helper"
    git clone "https://aur.archlinux.org/$aur_helper.git" "$path"
    cd "$path" || exit
    makepkg -si  
    cd ..
    rm -rf "$path"
  fi
}

get_fastest_mirrors() {
  sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist
}

install_pkglists() {
  if command -v "$aur_helper" &> /dev/null; then
    install_pkg - < "$pkglists_dir/$pkgtype/pacman.txt";
  fi
}

install_node_packages() {
  if command -v "$npm_helper" &> /dev/null; then 
    packages="$pkglists_dir/$pkgtype/yarn.txt"
    if [ "$npm_helper" = 'yarn' ]; then
      $npm_helper global add < "$packages"
    else
      $npm_helper install --global < "$packages"
    fi
  fi
}

setup_dotfiles_packages() {
  install_aur_helper
  get_fastest_mirrors
  install_node_packages
  install_pkglists
}
