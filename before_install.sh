#!/usr/bin/env bash

log_progress "Creating common folders"

mkdir -p $HOME/{Documents,Downloads,Music,Pictures}
mkdir -p $HOME/Documents/Projects/{personal,work}
mkdir -p $HOME/.local/{bin,share,src}

case "$OS" in
Linux)
  mkdir -p $HOME/{Videos} $HOME/Documents/Torrents $HOME/Videos/Recordings $HOME/Pictures/Screenshots
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
  clone_git_repo "$DI_MACOS_REPO" "$DI_MACOS_DIR"
  clone_git_repo "$DI_NVIM_REPO" "$DI_NVIM_DIR"
fi

if ! command -v stow >/dev/null 2>&1; then
  log_progress "Installing stow"
  install_pkg stow
fi

if command -v stow >/dev/null 2>&1; then
  log_progress "Creating dirs in $HOME/.local/bin to ensure correct stow"

  for dir in $DI_DOTFILES_DIR/.local/bin/*/; do
    dir_name=$(basename "$dir")
    mkdir -p $HOME/.local/bin/$dir_name
  done

  log_progress "Stowing the dotfiles (voidrice, macos)"
  stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice macos

  if [[ -d "$DI_DOTFILES_DIR/universal" ]]; then
    log_progress "Stowing the dotfiles (universal)"
    stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" universal
  fi
fi

evaluate_ssh_agents() {
  if [[ -d "$HOME/.ssh" ]]; then
    chmod 400 ~/.ssh/{id_rsa_personal,id_rsa_work} # 400 for owner read-only, I don't want to modify these files, other users cannot access any file
    chmod 644 ~/.ssh/{id_rsa_personal.pub,id_rsa_work.pub} # 644 for .pub (public) keys, I can read-write, other users can read
    chmod 600 ~/.ssh/config # 600 for ~/.ssh/config, it's a normal file, needs read/write, but no execute
    chmod 700 ~/.ssh # 700 for ~/.ssh, read/write/execute to make sure ssh works correctly, no access to other users
    eval "$(ssh-agent -s)" && ssh-add ~/.ssh/{id_rsa_personal,id_rsa_work}
  fi
}
evaluate_ssh_agents

clone_git_repo git@github.com:jakubreron/universal.git "$DI_UNIVERSAL_DIR/universal_temp"
rm -rf $DI_UNIVERSAL_DIR/universal && mv universal_temp universal
# re-evaluate since the repo was overriden from zip package to a normal repo, no need to re-stow
evaluate_ssh_agents 

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

bin_shortcuts="$HOME/.local/bin/shortcuts"
dotfiles_shortcuts="$HOME/.config/dotfiles/voidrice/.local/bin/shortcuts"

if [[ -f "$bin_shortcuts" ]]; then
  log_progress "Sourcing shortcuts from $bin_shortcuts"
  $bin_shortcuts
elif [[ -f "$dotfiles_shortcuts" ]]; then
  log_status "not found on $bin_shortcuts"
  log_progress "Sourcing shortcuts from $dotfiles_shortcuts"
  $dotfiles_shortcuts
else
  log_status "No shortcuts script detected, skipping shortcuts sourcing"️
fi
