#!/usr/bin/env bash

create_dirs() {
  log_progress "Creating common folders in $HOME"
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

  mkdir -p "$DI_DOTFILES_DIR"
}

clone_dotfiles_repos() {
  if ! command -v git >/dev/null 2>&1; then
    log_progress "Installing git"
    install_pkg git
  fi

  clone_git_repo "$DI_VOIDRICE_REPO" "$DI_VOIDRICE_DIR"
  clone_git_repo "$DI_PKGLISTS_REPO" "$DI_PKGLISTS_DIR"

  log_progress "[Background] Pulling latest changes in $DI_VOIDRICE_DIR, $DI_PKGLISTS_DIR"
  git -C "$DI_VOIDRICE_DIR" pull &
  git -C "$DI_PKGLISTS_DIR" pull &

  log_progress "[Background] Initializing submodules in $DI_VOIDRICE_DIR"
  git -C "$DI_VOIDRICE_DIR" submodule update --init --remote --recursive &
}

replace_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    log_progress "Installing stow"
    install_pkg stow
  fi

  log_progress "Stowing voidrice dotfiles"
  stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice
}

create_dirs
clone_dotfiles_repos
replace_stow
