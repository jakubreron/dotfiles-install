#!/usr/bin/env bash

pam_login_file="/etc/pam.d/login"

if ! command -v gnome-keyring-daemon >/dev/null 2>&1; then
  log_progress "Installing gnome-keyring"
  install_pkg gnome-keyring
fi

if command -v gnome-keyring-daemon >/dev/null 2>&1; then
  if grep -qs "pam_gnome_keyring" "$pam_login_file"; then
    log_status "The login keyring already unlocks at login, skipping"
  elif [[ ! -f "$pam_login_file" ]]; then
    log_warn "$pam_login_file not found, skipping the login keyring setup"
  else
    log_progress "Backing up $pam_login_file"
    sudo cp -n "$pam_login_file" "$pam_login_file.dotfiles-install.bak"

    log_progress "Unlocking the login keyring at login with pam_gnome_keyring.so"
    sudo sed -i \
      -e '/^auth[[:space:]]\+include[[:space:]]\+system-local-login/a -auth      optional     pam_gnome_keyring.so' \
      -e '/^password[[:space:]]\+include[[:space:]]\+system-local-login/a -password  optional     pam_gnome_keyring.so    use_authtok' \
      -e '/^session[[:space:]]\+include[[:space:]]\+system-local-login/a -session   optional     pam_gnome_keyring.so    auto_start' \
      "$pam_login_file"
  fi
fi
