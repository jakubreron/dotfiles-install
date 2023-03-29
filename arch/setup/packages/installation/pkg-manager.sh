#!/bin/sh

install_pkg_manager_helper() {
  if ! command -v "$pkg_manager_helper" >/dev/null 2>&1; then
    log-pretty-message "Installing AUR helper: $pkg_manager_helper"
    path="$git_clone_path/$pkg_manager_helper"
    git clone "https://aur.archlinux.org/$pkg_manager_helper.git" "$path"
    cd "$path" || exit
    makepkg -si  
    cd ..
    rm -rf "$path"
  else
    log-pretty-message "AUR helper $pkg_manager_helper is already installed" ❌
  fi
}

get_fastest_mirrors() {
  if ! command -v reflector >/dev/null 2>&1; then
    log-pretty-message "Getting the fastest mirrors before the installation"
    sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist
  else
    log-pretty-message "Skipping getting the fastest mirrors, reflector not installed" ❌
  fi
}

install_pkglists() {
  if command -v "$pkg_manager_helper" >/dev/null 2>&1; then
    log-pretty-message "Installing dotfiles packages"
    install_pkg - < "$pkglists_dir/$pkgtype/pacman.txt";
  fi
}

install_node_packages() {
  if command -v "$npm_helper" >/dev/null 2>&1; then 
    log-pretty-message "Installing node packages"
    packages="$pkglists_dir/$pkgtype/yarn.txt"
    if [ "$npm_helper" = 'yarn' ]; then
      $npm_helper global add < "$packages"
    else
      $npm_helper install --global < "$packages"
    fi
  else
    log-pretty-message "There is no $npm_helper installed, skipping NPM packages" ❌
  fi
}

install_pkg_manager_helper
get_fastest_mirrors
install_node_packages
install_pkglists
