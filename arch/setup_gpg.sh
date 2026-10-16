#!/usr/bin/env bash

gpg_agent_conf="$HOME/.gnupg/gpg-agent.conf"

if ! command -v gpg >/dev/null 2>&1; then
  log_progress "Installing gnupg"
  install_pkg gnupg
else
  log_status "gnupg is already installed"
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
    log_progress "Restarting gpg-agent"
    gpgconf --kill gpg-agent
  fi

  if ! command -v pinentry-curses >/dev/null 2>&1; then
    log_progress "Installing pinentry"
    install_pkg pinentry
  fi

  if ! command -v pinentry-curses >/dev/null 2>&1; then
    log_warn "pinentry-curses is not installed, skipping the terminal passphrase prompt setup"
  elif grep -qs "pinentry-program" "$gpg_agent_conf"; then
    log_status "gpg-agent already has a pinentry program, skipping"
  else
    log_progress "Setting gpg-agent to ask for the passphrase in the terminal"
    mkdir -p "$HOME/.gnupg"
    chmod 700 "$HOME/.gnupg"
    echo "pinentry-program $(command -v pinentry-curses)" >>"$gpg_agent_conf"
    log_progress "Restarting gpg-agent"
    gpgconf --kill gpg-agent
  fi

  import_gpg_keys
fi
