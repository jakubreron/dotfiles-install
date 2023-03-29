#!/bin/sh

create_dirs() {
  log_pretty_message "Creating common folders in $HOME"
  mkdir "$HOME"/{Documents,Downloads,Music,Pictures,Videos,Cloud}

  mkdir "$HOME"/Documents/Projects/{personal,work}

  mkdir -p "$HOME"/.local/{bin,share,src}
  mkdir -p "$HOME"/.local/bin/{dmenu,entr,git,layouts,music,qemu,rofi,statusbar,tmux,update,volume}

  case "$(uname -s)" in
    Linux*)
        mkdir -p "$HOME"/Documents/Torrents "$HOME"/Videos/Recordings "$HOME"/Pictures/Screenshots
      ;;
    Darwin)
      ;;
  esac

  mkdir -p "$dotfiles_dir"
}

clone_dotfiles_repos() {
  if ! command -v git >/dev/null 2>&1; then
    log_pretty_message "Cloning repositories"
    git clone "$voidrice_repo" "$voidrice_dir"
    git clone "$pkglists_repo" "$pkglists_dir"

    log_pretty_message "Pulling latest changes"
    git --git-dir "$voidrice_dir" pull
    git --git-dir "$pkglists_dir" pull

    log_pretty_message "Initializing submodules"
    git --git-dir "$voidrice_dir" submodule update --init --remote --recursive
  else
    log_pretty_message "Unable to clone repositories, install git first"
  fi
}

replace_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    log_pretty_message "Stowing dotfiles"
    stow --adopt --target="$HOME" --dir="$dotfiles_dir" voidrice
  else
    log_pretty_message "Unable to stow dotfiles, install stow first" ❌
  fi
}

create_dirs
clone_dotfiles_repos
replace_stow
