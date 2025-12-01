#!/usr/bin/env bash

log_progress "Creating common folders"

mkdir -p $HOME/{Documents,Downloads,Music,Pictures}
mkdir -p $HOME/Documents/Projects/{personal,work}
mkdir -p $HOME/.local/{bin,share,src}

case "$OS" in
Linux)
  if ! command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
    log_progress "Installing AUR helper: $DI_AUR_HELPER"

    local aur_helper_path="$DI_GIT_CLONE_PATH/$DI_AUR_HELPER"
    clone_git_repo "https://aur.archlinux.org/$DI_AUR_HELPER.git" "$aur_helper_path"

    (cd "$aur_helper_path" && makepkg -si --noconfirm "$aur_helper_path")
    rm -rf "$aur_helper_path"
  else
    log_status "AUR helper '$DI_AUR_HELPER' is already installed"️
  fi

  ;;
Darwin)
  if ! command -v brew >/dev/null 2>&1; then
    if ! xcode-select -p >/dev/null 2>&1; then # More robust check for Xcode tools
      log_progress "Installing XCode Command Line Tools (required for Git & Homebrew)"
      xcode-select --install
    fi

    log_progress "Installing brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH immediately for this script to use it in current session
    eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    log_status "PATH updated for current session"
  else
    # Ensure brew is in PATH even if already installed (e.g., new terminal)
    eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    log_status "Brew is already installed, updating PATH for current session"️
  fi
  ;;
esac

case "$OS" in
Linux)
  mkdir -p "$HOME/Videos" "$HOME/Documents/Torrents" "$HOME/Videos/Recordings" "$HOME/Pictures/Screenshots"
  ;;
esac

mkdir -p "$DI_GIT_CLONE_PATH"
mkdir -p "$DI_DOTFILES_DIR"

if ! command -v git >/dev/null 2>&1; then
  log_progress "Installing git"
  install_pkg git
fi

if ! command -v stow >/dev/null 2>&1; then
  log_progress "Installing stow"
  install_pkg stow
fi

if [[ -d "$DI_UNIVERSAL_DIR" ]]; then
  log_progress "Stowing the dotfiles (universal)"
  stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" universal

  if [[ ! -d "$DI_UNIVERSAL_DIR/.git" ]]; then
    if ! command -v git-credential-manager >/dev/null 2>&1; then
      log_progress "Installing git credential manager"
      install_pkg git-credential-manager
    fi

    case "$OS" in
      Darwin)
        if ! command -v defaultbrowser >/dev/null 2>&1; then
          log_progress "Installing defaultbrowser util (macos)"
          install_pkg defaultbrowser

          log_progress "Setting firefox as default browser (macos)"
          defaultbrowser firefox
        fi
      ;;
    esac

    log_progress "Re-adding universal repo with git-credential-manager"
    clone_git_repo $DI_UNVIERSAL_REPO $DI_DOTFILES_DIR/universal_temp

    if [[ -d "$DI_DOTFILES_DIR/universal_temp" ]]; then
      rm -rf $DI_UNIVERSAL_DIR && mv $DI_DOTFILES_DIR/universal_temp $DI_UNIVERSAL_DIR 
    fi

    chmod 400 ~/.ssh/{id_rsa_personal,id_rsa_work} # 400 for owner read-only, I don't want to modify these files, other users cannot access any file
    chmod 644 ~/.ssh/{id_rsa_personal.pub,id_rsa_work.pub} # 644 for .pub (public) keys, I can read-write, other users can read
    chmod 600 ~/.ssh/config # 600 for ~/.ssh/config, it's a normal file, needs read/write, but no execute
    chmod 700 ~/.ssh # 700 for ~/.ssh, read/write/execute to make sure ssh works correctly, no access to other users
    eval "$(ssh-agent -s)" && ssh-add ~/.ssh/{id_rsa_personal,id_rsa_work}
  fi
else
  log_error "$DI_UNIVERSAL_DIR not found. Exiting."
  exit 1
fi

if command -v git >/dev/null 2>&1; then
  log_progress "Cloning dotfiles"

  clone_git_repo "$DI_VOIDRICE_REPO" "$DI_VOIDRICE_DIR"
  clone_git_repo "$DI_PKGLISTS_REPO" "$DI_PKGLISTS_DIR"
  clone_git_repo "$DI_MACOS_REPO" "$DI_MACOS_DIR"
  clone_git_repo "$DI_NVIM_REPO" "$DI_NVIM_DIR"

  log_progress "Creating dirs in $HOME/.local/bin to ensure correct stow"
  for dir in $DI_VOIDRICE_DIR/.local/bin/*/; do
    dir_name=$(basename "$dir")
    mkdir -p $HOME/.local/bin/$dir_name
  done

  log_progress "Stowing the dotfiles (voidrice, macos)"
  stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice macos
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

  rm -f "$HOME/.config/zsh/.zcompdump"
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

bin_dotfiles_shortcuts="$HOME/.local/bin/dotfiles-shortcuts"
repo_dotfiles_shortcuts="$HOME/.config/dotfiles/voidrice/.local/bin/dotfiles-shortcuts"

if [[ -f "$bin_dotfiles_shortcuts" ]]; then
  log_progress "Sourcing shortcuts from $bin_dotfiles_shortcuts"
  command $bin_dotfiles_shortcuts
elif [[ -f "$repo_dotfiles_shortcuts" ]]; then
  log_warn "Shortcuts not found in $bin_dotfiles_shortcuts"
  log_progress "Attempting to source shortcuts from $repo_dotfiles_shortcuts"
  command $repo_dotfiles_shortcuts
else
  log_error "No shortcuts script detected, skipping shortcuts sourcing"️
fi
