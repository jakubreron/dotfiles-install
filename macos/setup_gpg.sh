#!/usr/bin/env bash

work_gpg_key_id="$(git config -f "$HOME/.config/git/config_work" user.signingkey)"
work_gpg_key_file="$HOME/.config/git/work-gpg-key.asc"
gpg_agent_conf="$HOME/.gnupg/gpg-agent.conf"

if ! command -v pinentry-mac >/dev/null 2>&1; then
  log_progress "Installing pinentry-mac"
  install_pkg pinentry-mac
fi

if command -v pinentry-mac >/dev/null 2>&1 && command -v gpg >/dev/null 2>&1; then
  if grep -qs "pinentry-mac" "$gpg_agent_conf"; then
    log_status "gpg-agent already uses pinentry-mac, skipping"
  else
    log_progress "Setting up gpg-agent with pinentry-mac and an 8 hour passphrase cache"
    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"
    cat >"$gpg_agent_conf" <<EOF
pinentry-program $(command -v pinentry-mac)
default-cache-ttl 28800
max-cache-ttl 28800
EOF
    gpgconf --kill gpg-agent
  fi

  if [[ -n "$work_gpg_key_id" ]] && ! gpg --list-secret-keys "$work_gpg_key_id" >/dev/null 2>&1; then
    if [[ -f "$work_gpg_key_file" ]]; then
      log_progress "Importing work GPG key (passphrase is in Bitwarden)"
      gpg --import "$work_gpg_key_file"
    else
      log_warn "Work GPG key $work_gpg_key_id not found, restore it from Bitwarden and run: gpg --import <file>"
    fi
  fi

  log_warn "On the first signed commit, tick 'Save in Keychain' in the passphrase prompt"
fi
