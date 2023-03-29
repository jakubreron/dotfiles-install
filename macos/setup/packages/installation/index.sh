install_pkglists() {
  if command -v "$di_pkg_manager_helper" >/dev/null 2>&1; then
    log_pretty_message "Installing dotfiles packages"
    cat "$pkglists_dir/$di_pkg_type/brew.txt" | xargs pkg_install
    cat "$pkglists_dir/$di_pkg_type/brew-casks.txt" | xargs pkg_install -- --cask
  fi
}

install_pkglists
