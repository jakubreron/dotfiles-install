#!/usr/bin/env bash

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

  import_work_gpg_key

  log_warn "On the first signed commit, tick 'Save in Keychain' in the passphrase prompt"
fi
