#!/usr/bin/env bash

remove_db_lock() {
  [ -f /var/lib/pacman/db.lck ] && sudo rm /var/lib/pacman/db.lck
}

install_pkg() {
  case "$OS" in
    Linux)
      remove_db_lock

      if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
        "$DI_AUR_HELPER" --needed -S "$1"
      else
        pacman --needed -S "$1"
      fi
      ;;
    Darwin)
      brew install "$1"
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

  if [ ! -f "$destination" ] >/dev/null 2>&1; then
    log_progress "$destination does not exist, cloning via git"
    git clone "$repo" "$destination"
  else
    log_status "Skipping $destination, the repository already exists"️
  fi
}
