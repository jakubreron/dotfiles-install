#!/usr/bin/env bash

setup_user() {
  case "$OS" in
    Linux)
      log_progress "Preparing the user permissions"

      mkdir -p "$HOME"
      sudo usermod -aG wheel "$DI_USER"
      sudo chown "$DI_USER":wheel "$HOME"
      ;;
  esac
}

create_dirs() {
  log_progress "Creating common folders in $HOME"
  mkdir -p "$HOME"/{Documents,Downloads,Music,Pictures}
  mkdir -p "$HOME"/Documents/Projects/{personal,work}
  mkdir -p "$HOME"/.local/{bin,share,src}

  case "$OS" in
    Linux)
      mkdir -p "$HOME"/{Videos,Cloud}
      mkdir -p "$HOME"/Documents/Torrents "$HOME"/Videos/Recordings "$HOME"/Pictures/Screenshots
      ;;
  esac

  mkdir -p "$DI_GIT_CLONE_PATH"
  mkdir -p "$DI_DOTFILES_DIR"
}

clone_dotfiles_repos() {
  if ! command -v git >/dev/null 2>&1; then
    log_progress "Installing git"
    install_pkg git
  fi


  if command -v git >/dev/null 2>&1; then
    clone_git_repo "$DI_VOIDRICE_REPO" "$DI_VOIDRICE_DIR"
    clone_git_repo "$DI_PKGLISTS_REPO" "$DI_PKGLISTS_DIR"

    log_progress "[Background] Pulling latest changes in $DI_VOIDRICE_DIR, $DI_PKGLISTS_DIR"
    git -C "$DI_VOIDRICE_DIR" pull &
    git -C "$DI_PKGLISTS_DIR" pull &

    log_progress "[Background] Initializing submodules in $DI_VOIDRICE_DIR"
    git -C "$DI_VOIDRICE_DIR" submodule update --init --remote --recursive &
  fi
}

replace_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    log_progress "Installing stow"
    install_pkg stow
  fi

  if command -v stow >/dev/null 2>&1; then
    log_progress "Creating dirs in $HOME/.local/bin to ensure correct stow"
    for dir in "$HOME"/.config/dotfiles/voidrice/.local/bin/*/; do
      dir_name=$(basename "$dir")
      mkdir -p "$HOME"/.local/bin/"$dir_name"
    done

    log_progress "Stowing the dotfiles"
    stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice
  fi
}

setup_user
create_dirs
clone_dotfiles_repos
replace_stow
