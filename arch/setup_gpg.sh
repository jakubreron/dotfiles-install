#!/usr/bin/env bash

gpg_agent_conf="$HOME/.gnupg/gpg-agent.conf"

if ! command -v gpg >/dev/null 2>&1; then
  log_progress "Installing gnupg"
  install_pkg gnupg
fi

if command -v gpg >/dev/null 2>&1; then
  if grep -qs "default-cache-ttl" "$gpg_agent_conf"; then
    log_status "gpg-agent cache already configured, skipping"
  else
    log_progress "Setting up gpg-agent with an 8 hour passphrase cache"
    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"
    cat >>"$gpg_agent_conf" <<EOF
default-cache-ttl 28800
max-cache-ttl 28800
EOF
    gpgconf --kill gpg-agent
  fi

  import_gpg_keys
fi
