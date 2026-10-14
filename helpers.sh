#!/usr/bin/env bash

remove_db_lock() {
  if [[ -f /var/lib/pacman/db.lck ]] && ! pgrep -x pacman >/dev/null 2>&1; then
    log_status "Pacman DB lock file detected. Attempting to remove..."
    sudo rm -f /var/lib/pacman/db.lck || log_error "Failed to remove Pacman DB lock. Please resolve manually."
  fi
}

gpg_key_missing() {
  local gpg_key_id
  gpg_key_id="$(git config -f "$1" user.signingkey)"

  [[ -n "$gpg_key_id" ]] && ! gpg --list-secret-keys "$gpg_key_id" >/dev/null 2>&1
}

import_gpg_key() {
  local git_config_file="$1" gpg_key_file="$2"

  if gpg_key_missing "$git_config_file"; then
    if [[ -f "$gpg_key_file" ]]; then
      log_progress "Importing GPG key from $gpg_key_file (passphrase is in Bitwarden)"
      gpg --import "$gpg_key_file"
    else
      log_warn "GPG key not found, restore it from Bitwarden and run: gpg --import <file>"
    fi
  fi
}

import_gpg_keys() {
  case "$OS" in
  Darwin)
    import_gpg_key "$HOME/.config/git/config_macos" "$HOME/.config/git/work-gpg-key.asc"
    ;;
  Linux)
    import_gpg_key "$HOME/.config/git/config_linux" "$HOME/.config/git/personal-gpg-key.asc"
    ;;
  esac
}

fetch_gpg_key_from_bitwarden() {
  local git_config_file bitwarden_item answer

  case "$OS" in
  Darwin)
    git_config_file="$HOME/.config/git/config_macos"
    bitwarden_item="work-git"
    ;;
  Linux)
    git_config_file="$HOME/.config/git/config_linux"
    bitwarden_item="personal-git"
    ;;
  esac

  gpg_key_missing "$git_config_file" || return 0
  command -v bw >/dev/null 2>&1 || return 0

  read -r -p "GPG key is missing, fetch it from Bitwarden item '$bitwarden_item' now? [y/N] " answer || return 0
  [[ "$answer" =~ ^[Yy]$ ]] || return 0

  bw login --check >/dev/null 2>&1 || bw login
  BW_SESSION="$(bw unlock --raw)" || return 0
  export BW_SESSION

  log_progress "Importing GPG key from Bitwarden item $bitwarden_item"
  bw get notes "$bitwarden_item" | gpg --import

  bw lock >/dev/null 2>&1
  unset BW_SESSION
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
