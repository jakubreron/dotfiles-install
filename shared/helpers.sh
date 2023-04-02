#!/usr/bin/env bash

remove_db_lock() {
  [ -f /var/lib/pacman/db.lck ] && sudo rm /var/lib/pacman/db.lck
}

install_pkg() {
  case "$OS" in
    Linux)
      remove_db_lock

      if command -v "$DI_PKG_MANAGER_HELPER" >/dev/null 2>&1; then
        PKG_MANAGER="$DI_PKG_MANAGER_HELPER"
      else
        PKG_MANAGER="pacman"
      fi

      sudo "$PKG_MANAGER" --noconfirm --noprovides --needed -S "$1"
      ;;
    Darwin)
      brew install "$1"
      ;;
  esac
}

log_progress() {
  message="$1"
  emoji="${2:-⏳}"

  BOLD=$(tput bold)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)

  printf "%s${BLUE}${BOLD}$emoji $message...${RESET}\n"
}

log_status() {
  message="$1"
  emoji="${2:-✅}"

  BOLD=$(tput bold)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)

  printf "%s${BLUE}${BOLD}$emoji $message${RESET}\n"
}

clone_git_repo() {
  repo="$1"
  destination="$2"

  if [ -f "$destination" ] >/dev/null 2>&1; then
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
