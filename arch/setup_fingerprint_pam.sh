#!/usr/bin/env bash

pam_system_auth_file="/etc/pam.d/system-auth"

if command -v fprintd-enroll >/dev/null 2>&1; then
  if grep -qs "pam_fprintd" "$pam_system_auth_file"; then
    log_status "Fingerprint authentication is already in $pam_system_auth_file, skipping"
  elif [[ ! -f "$pam_system_auth_file" ]]; then
    log_warn "$pam_system_auth_file not found, skipping the fingerprint PAM setup"
  else
    log_progress "Backing up $pam_system_auth_file"
    sudo cp -n "$pam_system_auth_file" "$pam_system_auth_file.dotfiles-install.bak"

    # NOTE: system-auth is included by login, sudo, su and polkit, so one line covers them all, "sufficient" falls back to the password
    log_progress "Enabling fingerprint authentication with pam_fprintd.so"
    sudo sed -i '0,/^auth/s//auth      sufficient   pam_fprintd.so\n&/' "$pam_system_auth_file"
  fi
else
  log_warn "fprintd is not installed, skipping the fingerprint PAM setup"
fi
