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
    log_pretty_message "Installing git"
    install_pkg git
  fi

  clone_git_repo "$voidrice_repo" "$voidrice_dir"
  clone_git_repo "$pkglists_repo" "$pkglists_dir"

  log_pretty_message "Pulling latest changes"
  git --git-dir "$voidrice_dir" pull
  git --git-dir "$pkglists_dir" pull

  log_pretty_message "Initializing submodules"
  git --git-dir "$voidrice_dir" submodule update --init --remote --recursive
}

replace_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    log_pretty_message "Installing stow"
    install_pkg stow
  fi

  log_pretty_message "Stowing dotfiles"
  stow --adopt --target="$HOME" --dir="$dotfiles_dir" voidrice
}

create_dirs
clone_dotfiles_repos
replace_stow
