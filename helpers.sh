#!/usr/bin/env bash

remove_db_lock() {
  if [[ -f /var/lib/pacman/db.lck ]] && ! pgrep -x pacman >/dev/null 2>&1; then
    log_status "Pacman DB lock file detected. Attempting to remove..."
    sudo rm -f /var/lib/pacman/db.lck || log_error "Failed to remove Pacman DB lock. Please resolve manually."
  fi
}

import_gpg_key() {
  local git_config_file="$1" gpg_key_file="$2" gpg_key_id
  gpg_key_id="$(git config -f "$git_config_file" user.signingkey)"

  if [[ -n "$gpg_key_id" ]] && ! gpg --list-secret-keys "$gpg_key_id" >/dev/null 2>&1; then
    if [[ -f "$gpg_key_file" ]]; then
      log_progress "Importing GPG key $gpg_key_id (passphrase is in Bitwarden)"
      gpg --import "$gpg_key_file"
    else
      log_warn "GPG key $gpg_key_id not found, restore it from Bitwarden and run: gpg --import <file>"
    fi
  fi
}

import_gpg_keys() {
  import_gpg_key "$HOME/.config/git/config" "$HOME/.config/git/personal-gpg-key.asc"
  import_gpg_key "$HOME/.config/git/config_work" "$HOME/.config/git/work-gpg-key.asc"
}

brew_install() {
  local pkg
  for pkg in "$@"; do
    if brew info --formula "$pkg" >/dev/null 2>&1; then
      brew install --formula "$pkg"
    elif brew info --cask "$pkg" >/dev/null 2>&1; then
      brew install --cask "$pkg"
    else
      brew install "$pkg"
    fi
  done
}

install_pkg() {
  case "$OS" in
  Linux)
    remove_db_lock

    if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
      "$DI_AUR_HELPER" --needed -S "$@"
    else
      sudo pacman --needed -S "$@"
    fi
    ;;
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      log_warn "Brew not detected, attempting to source it first..."
      eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
      log_error "Brew not installed, quitting..."
      exit 1
    fi

    brew_install "$@"
    ;;
  esac
}

log_message() {
  message="$1"
  emoji="${2:-⏳}"

  BOLD=$(tput bold)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)

  printf "%s${BLUE}${BOLD}$emoji $message...${RESET}\n"
}

log_progress() {
  message="$1"
  emoji="${2:-🕒}"

  log_message "$message" "$emoji"
}

log_status() {
  message="$1"
  emoji="${2:-✅}"

  log_message "$message" "$emoji"
}

log_warn() {
  message="$1"
  emoji="${2:-🟠}"

  log_message "$message" "$emoji"
}

log_error() {
  message="$1"
  emoji="${2:-❌}"

  log_message "$message" "$emoji"
}

clone_git_repo() {
  repo="$1"
  destination="$2"

  if [[ ! -d "$destination" ]]; then
    log_progress "$destination does not exist, cloning via git"
    git clone "$repo" "$destination"
  else
    log_status "Pulling latest changes in  $destination, the repository already existed"️
    git -C "$destination" pull
  fi

  if [[ -f "$destination/.gitmodules" ]]; then
    log_progress "[Background] Initializing submodules in $destination"
    git -C "$destination" submodule update --init --remote --recursive &
  fi
}
