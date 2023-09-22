#!/usr/bin/env bash

remove_db_lock() {
  [ -f /var/lib/pacman/db.lck ] && sudo rm /var/lib/pacman/db.lck
}

install_pkg() {
  case "$OS" in
    Linux)
      remove_db_lock

      if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
        "$DI_AUR_HELPER" --noconfirm --noprovides --needed -S "$1"
      else
        "$DI_AUR_HELPER" --noconfirm --needed -S "$1"
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

compile() {
  path="$1"
  log_progress "Compiling $path"
  [ -d "$path" ] && sudo make -C "$path" && sudo make install -C "$path"
}

compile_from_git_path() {
  repo="https://github.com/jakubreron/$1"
  path="$HOME/.local/src/$1"

  [ ! -d "$path" ] && git clone "$repo" "$path"

  if laptop-detect >/dev/null 2>&1; then
    git -C "$path" fetch origin laptop:laptop 2>/dev/null
    if git -C "$path" fetch origin laptop:laptop 2>/dev/null; then
      git -C "$path" checkout laptop
    fi
  fi

  compile "$path"
}
