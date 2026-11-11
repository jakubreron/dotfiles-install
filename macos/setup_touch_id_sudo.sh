#!/usr/bin/env bash

pam_sudo_local_file="/etc/pam.d/sudo_local" # Survives macOS updates, unlike /etc/pam.d/sudo

if grep -qs "^auth.*pam_tid.so" "$pam_sudo_local_file"; then
  log_status "Touch ID for sudo is already enabled, skipping"
else
  if ! brew list pam-reattach >/dev/null 2>&1; then
    log_progress "Installing pam-reattach, Touch ID does not work in tmux without it"
    install_pkg pam-reattach
  fi

  if [[ -f "$pam_sudo_local_file" ]]; then
    log_progress "Backing up $pam_sudo_local_file"
    sudo cp -n "$pam_sudo_local_file" "$pam_sudo_local_file.dotfiles-install.bak"
  fi

  pam_reattach_module="$(brew --prefix)/lib/pam/pam_reattach.so"
  if [[ -f "$pam_reattach_module" ]]; then
    log_progress "Enabling Touch ID for sudo, also inside tmux"
    # NOTE: pam_reattach must come before pam_tid, "optional" keeps sudo working when it fails
    printf 'auth       optional       %s ignore_ssh\n' "$pam_reattach_module" | sudo tee -a "$pam_sudo_local_file" >/dev/null
  else
    log_progress "Enabling Touch ID for sudo, without tmux support"
  fi
  # NOTE: "sufficient" skips the password after a successful fingerprint and falls back to it otherwise
  printf 'auth       sufficient     pam_tid.so\n' | sudo tee -a "$pam_sudo_local_file" >/dev/null
fi
