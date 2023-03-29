install_pkglists() {
  if command -v "$pkg_manager_helper" >/dev/null 2>&1; then
    log_pretty_message "Installing dotfiles packages"
    install_pkg - < "$pkglists_dir/$pkgtype/pacman.txt";
  fi
}

install_pkglists
