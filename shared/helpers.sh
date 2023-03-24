#!/bin/sh

log_pretty_message() {
  message="$1"
  emoji="${2:-⏳}"

  BOLD=$(tput bold)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)

  printf "%s${BLUE}${BOLD}$emoji $message...${RESET}\n"
}

compile() {
  path="$1"
  log-pretty-message "Compiling $path"
  [ -d "$path" ] && sudo make -C "$path" && sudo make install -C "$path"
}

compile_from_git_path() {
  repo="https://github.com/jakubreron/$1"
  destination="$HOME/.local/src/$1"

  [ ! -d "$path" ] && git clone "$repo" "$destination"

  # TODO: switch to "laptop" branch if the script is run on laptop and if the branch exists
  # if laptop-detect -s /dev/null; then
  #   git -C "$destination" 
  # fi

  compile "$destination"
}
