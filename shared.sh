#!/usr/bin/env bash

log_progress "Creating common folders"

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

if ! command -v git >/dev/null 2>&1; then
  log_progress "Installing git"
  install_pkg git
fi

if command -v git >/dev/null 2>&1; then
  clone_git_repo "$DI_VOIDRICE_REPO" "$DI_VOIDRICE_DIR"
  clone_git_repo "$DI_PKGLISTS_REPO" "$DI_PKGLISTS_DIR"
  clone_git_repo "$DI_NVIM_REPO" "$DI_NVIM_DIR"
fi

if ! command -v stow >/dev/null 2>&1; then
  log_progress "Installing stow"
  install_pkg stow
fi

if command -v stow >/dev/null 2>&1; then
  log_progress "Creating dirs in $HOME/.local/bin to ensure correct stow"

  for dir in "$DI_DOTFILES_DIR"/.local/bin/*/; do
    dir_name=$(basename "$dir")
    mkdir -p "$HOME"/.local/bin/"$dir_name"
  done

  log_progress "Stowing the dotfiles"
  stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice
fi

if [ -d "$HOME/.ssh" ]; then
    chmod 400 "$HOME"/.ssh/{id_rsa_personal,id_rsa_work} &&
    eval "$(ssh-agent -s)" && ssh-add "$HOME"/.ssh/{id_rsa_personal,id_rsa_work}
fi

if ! command -v zsh >/dev/null 2>&1; then
  log_progress "Installing ZSH"
  install_pkg zsh
fi

if command -v zsh >/dev/null 2>&1; then
  mkdir -p "$HOME/.cache/zsh/"
  mkdir -p "$HOME/.config/zsh/"

  touch "$HOME/.cache/zsh/.zsh_history"

  if ! [[ "$SHELL" =~ .*'zsh' ]]; then
    log_progress "Changing default shell to ZSH"

    case "$OS" in
      Linux)
        chsh -s /usr/bin/zsh "$USER"
        ;;
      Darwin)
        chsh -s /bin/zsh "$USER"
        ;;
    esac
  else
    log_status "ZSH is already a default shell"️
  fi

  rm "$HOME/.config/zsh/.zcompdump"
fi

case "$OS" in
  Linux)
    if ! command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
      log_progress "Installing AUR helper: $DI_AUR_HELPER"

      path="$DI_GIT_CLONE_PATH/$DI_AUR_HELPER"
      clone_git_repo "https://aur.archlinux.org/$DI_AUR_HELPER.git" "$path"

      (cd "$path" && makepkg -si "$path")
      rm -rf "$path"
    else
      log_status "AUR helper '$DI_AUR_HELPER' is already installed"️
    fi

    ;;
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      log_progress "Installing brew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      log_status "Brew is already installed"️
    fi
    ;;
esac

if ! command -v zap >/dev/null 2>&1; then 
  log_progress "Setting up Zap"
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
else
  log_status "Zap is already installed"️
fi

if ! command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then 
  log_progress "Installing $DI_NPM_HELPER"
  install_pkg nodejs fnm "$DI_NPM_HELPER"
fi

if command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then 
  log_progress "Installing node packages via $DI_NPM_HELPER"

  packages="$DI_PKGLISTS_DIR/$DI_PKG_TYPE/$DI_NPM_HELPER.txt"

  if ! command -v xargs >/dev/null 2>&1; then
    log_progress "xargs not detected, installing"
    install_pkg xargs 
  fi

  if command -v xargs >/dev/null 2>&1; then
    cat "$packages" | xargs $DI_NPM_HELPER install --global
  fi
fi

if [[ -f "$HOME"/.local/bin/shortcuts ]]; then
  log_progress "Sourcing shortcuts from $HOME/.local/bin/shortcuts"

  "$HOME"/.local/bin/shortcuts
fi
