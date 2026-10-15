#!/usr/bin/env bash

remove_db_lock() {
  if [[ -f /var/lib/pacman/db.lck ]] && ! pgrep -x pacman >/dev/null 2>&1; then
    log_warn "Pacman DB lock file detected, attempting to remove it"
    if sudo rm -f /var/lib/pacman/db.lck; then
      log_status "Pacman DB lock removed"
    else
      log_error "Failed to remove Pacman DB lock, please resolve manually"
    fi
  fi
}

firefox_profile_exists() {
  local profile_dir

  for profile_dir in "$@"; do
    grep -qs "default-release" "$profile_dir/profiles.ini" && return 0
  done

  return 1
}

ensure_firefox_profile() {
  local firefox_bin firefox_pid
  local -a profile_dirs

  case "$OS" in
  Linux)
    firefox_bin="$(command -v firefox)"
    profile_dirs=("${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox" "$HOME/.mozilla/firefox")
    ;;
  Darwin)
    firefox_bin="/Applications/Firefox.app/Contents/MacOS/firefox"
    profile_dirs=("$HOME/Library/Application Support/Firefox")
    ;;
  esac

  log_progress "Checking whether a Firefox profile already exists"
  if firefox_profile_exists "${profile_dirs[@]}"; then
    log_status "Firefox profile already exists, skipping"
    return 0
  fi

  if [[ -z "$firefox_bin" || ! -x "$firefox_bin" ]]; then
    log_warn "Firefox is not installed, cannot create its profile"
    return 0
  fi

  log_progress "Starting Firefox headless once to create its profile"
  "$firefox_bin" --headless --no-remote about:blank >/dev/null 2>&1 &
  firefox_pid=$!

  for _ in $(seq 1 30); do
    firefox_profile_exists "${profile_dirs[@]}" && break
    sleep 1
  done

  log_progress "Stopping the headless Firefox"
  kill "$firefox_pid" 2>/dev/null
  wait "$firefox_pid" 2>/dev/null

  if firefox_profile_exists "${profile_dirs[@]}"; then
    log_status "Firefox profile created"
  else
    log_warn "Firefox did not create a profile within 30 seconds, the user.js merge will be skipped"
  fi
}

gpg_key_missing() {
  local gpg_key_id
  gpg_key_id="$(git config -f "$1" user.signingkey)"

  [[ -n "$gpg_key_id" ]] && ! gpg --list-secret-keys "$gpg_key_id" >/dev/null 2>&1
}

import_gpg_key() {
  local git_config_file="$1" gpg_key_file="$2"

  log_progress "Checking the GPG key configured in $git_config_file"
  if gpg_key_missing "$git_config_file"; then
    if [[ -f "$gpg_key_file" ]]; then
      log_progress "Importing GPG key from $gpg_key_file (passphrase is in Bitwarden)"
      gpg --import "$gpg_key_file"
    else
      log_warn "GPG key not found, restore it from Bitwarden and run: gpg --import <file>"
    fi
  else
    log_status "GPG key is already in the keyring or not configured, skipping"
  fi
}

import_gpg_keys() {
  log_progress "Importing GPG keys for $OS"

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

  log_progress "Checking whether the GPG key needs to be fetched from Bitwarden"
  if ! gpg_key_missing "$git_config_file"; then
    log_status "GPG key is already in the keyring or not configured, skipping the Bitwarden fetch"
    return 0
  fi

  if ! command -v bw >/dev/null 2>&1; then
    log_warn "Bitwarden CLI (bw) is not installed, skipping the Bitwarden fetch"
    return 0
  fi

  read -r -p "GPG key is missing, fetch it from Bitwarden item '$bitwarden_item' now? [y/N] " answer || {
    log_status "No input available, skipping the Bitwarden fetch"
    return 0
  }
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    log_status "Skipping the Bitwarden fetch"
    return 0
  fi

  if ! bw login --check >/dev/null 2>&1; then
    log_progress "Logging into Bitwarden"
    bw login
  fi

  log_progress "Unlocking the Bitwarden vault"
  BW_SESSION="$(bw unlock --raw)" || {
    log_error "Could not unlock the Bitwarden vault"
    return 0
  }
  export BW_SESSION

  log_progress "Importing GPG key from Bitwarden item $bitwarden_item"
  bw get notes "$bitwarden_item" | gpg --import

  log_progress "Locking the Bitwarden vault"
  bw lock >/dev/null 2>&1
  unset BW_SESSION
}

brew_install() {
  local pkg
  for pkg in "$@"; do
    if brew info --formula "$pkg" >/dev/null 2>&1; then
      log_progress "Installing $pkg with brew (formula)"
      brew install --formula "$pkg"
    elif brew info --cask "$pkg" >/dev/null 2>&1; then
      log_progress "Installing $pkg with brew (cask)"
      brew install --cask "$pkg"
    else
      log_progress "Installing $pkg with brew (not found as formula or cask, trying as is)"
      brew install "$pkg"
    fi
  done
}

install_pkg() {
  case "$OS" in
  Linux)
    remove_db_lock

    if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
      log_progress "Installing with $DI_AUR_HELPER: $*"
      "$DI_AUR_HELPER" --needed -S "$@"
    else
      log_progress "Installing with pacman: $*"
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

    log_progress "Installing with brew: $*"
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
    log_progress "$destination does not exist, cloning $repo via git"
    git clone "$repo" "$destination"
    log_status "Cloned $repo into $destination"
  else
    log_status "Pulling latest changes in  $destination, the repository already existed"️
    git -C "$destination" pull
  fi

  if [[ -f "$destination/.gitmodules" ]]; then
    log_progress "[Background] Initializing submodules in $destination"
    git -C "$destination" submodule update --init --remote --recursive &
  fi
}
