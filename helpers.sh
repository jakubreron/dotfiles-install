#!/usr/bin/env bash

remove_db_lock() {
  log_status "Pacman DB lock file detected. Attempting to remove..."
  sudo rm -f /var/lib/pacman/db.lck || log_error "Failed to remove Pacman DB lock. Please resolve manually."
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
    if command -v brew >/dev/null 2>&1; then
      brew install "$@"
    else 
      log_error "Brew not detected, restart the terminal"
      exit 1
    fi
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
  emoji="${2:-⏳}"

  log_message "$message" "$emoji"
}

log_status() {
  message="$1"
  emoji="${2:-✅}"

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
