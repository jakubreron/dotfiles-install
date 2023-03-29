#!/bin/sh

remove_db_lock() {
  [ -f /var/lib/pacman/db.lck ] && sudo rm /var/lib/pacman/db.lck
}

install_pkg() {
  case "$(uname -s)" in
    Linux*)
      remove_db_lock

      if command -v "$di_pkg_manager_helper" >/dev/null 2>&1; then
        pkg_manager="$di_pkg_manager_helper"
      else
        pkg_manager=pacman
      fi

      sudo $pkg_manager --noconfirm --noprovides --needed -S "$1"
      ;;
    Darwin)
      brew install "$1"
      ;;
  esac
}

log_pretty_message() {
  message="$1"
  emoji="${2:-⏳}"

  BOLD=$(tput bold)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)

  printf "%s${BLUE}${BOLD}$emoji $message...${RESET}\n\n"
}

clone_git_repo() {
  repo="$1"
  destination="$2"

  if [ -f "$destination" ] >/dev/null 2>&1; then
    log_pretty_message "$destination does not exist, cloning via git"
    git clone "$repo" "$destination"
  else
    log_pretty_message "Skipping $destination, the repository already exists" ℹ️
  fi
}

compile() {
  path="$1"
  log_pretty_message "Compiling $path"
  [ -d "$path" ] && sudo make -C "$path" && sudo make install -C "$path"
}

compile_from_git_path() {
  repo="https://github.com/jakubreron/$1"
  destination="$HOME/.local/src/$1"

  [ ! -d "$path" ] && git clone "$repo" "$destination"

  # TODO: switch to "laptop" branch if the script is run on laptop and if the branch exists
  # if laptop-detect /dev/null; then
  #   git -C "$destination" 
  # fi

  compile "$destination"
}
