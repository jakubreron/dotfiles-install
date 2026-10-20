#!/usr/bin/env bash

mkdir -p $HOME/{Documents,Downloads,Music,Pictures}
mkdir -p $HOME/Documents/Projects/{personal,work}
mkdir -p $HOME/.local/{bin,share,src}

case "$OS" in
Linux)
  log_progress "Disabling debug packages for AUR builds in $HOME/.config/pacman/makepkg.conf"
  mkdir -p "$HOME/.config/pacman"
  grep -qsF 'OPTIONS+=(!debug)' "$HOME/.config/pacman/makepkg.conf" || echo 'OPTIONS+=(!debug)' >>"$HOME/.config/pacman/makepkg.conf"

  if ! command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
    log_progress "Installing AUR helper $DI_AUR_HELPER, prerequisites first"
    install_pkg git base-devel

    aur_helper_path="$DI_GIT_CLONE_PATH/$DI_AUR_HELPER"
    log_progress "Cloning $DI_AUR_HELPER from the AUR"
    clone_git_repo "https://aur.archlinux.org/$DI_AUR_HELPER.git" "$aur_helper_path"

    log_progress "Building and installing $DI_AUR_HELPER with makepkg"
    (cd "$aur_helper_path" && makepkg -si --noconfirm)

    rm -rf "$aur_helper_path"

    if ! command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
      log_error "$DI_AUR_HELPER failed to build, see the output above"
      exit 1
    fi
    log_status "$DI_AUR_HELPER installed"
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
    homebrew_installer="$(curl -fsSL --retry "$DI_DOWNLOAD_RETRIES" --connect-timeout "$DI_NETWORK_TIMEOUT_SECONDS" --max-time "$DI_DOWNLOAD_MAX_SECONDS" "$DI_HOMEBREW_INSTALLER_URL")"
    if [[ -z "$homebrew_installer" ]]; then
      log_error "Could not download the Homebrew installer from $DI_HOMEBREW_INSTALLER_URL"
      exit 1
    fi
    NONINTERACTIVE=1 /bin/bash -c "$homebrew_installer"

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
mkdir -p "$DI_SCRIPT_STATE_DIR"

if ! command -v git >/dev/null 2>&1; then
  log_progress "Installing git"
  install_pkg git
else
  log_status "git is already installed"
fi

if ! command -v git >/dev/null 2>&1; then
  log_error "git not installed, quitting"
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  log_progress "Installing stow"
  install_pkg stow
else
  log_status "stow is already installed"
fi

if ! command -v stow >/dev/null 2>&1; then
  log_error "stow not installed, quitting"
  exit 1
fi

if [[ -d "$DI_UNIVERSAL_DIR" ]]; then
  log_progress "Stowing the dotfiles (universal)"
  stow_dotfiles universal

  if [[ ! -d "$DI_UNIVERSAL_DIR/.git" ]]; then
    if ! command -v git-credential-manager >/dev/null 2>&1; then
      log_progress "Installing git credential manager"
      install_pkg git-credential-manager
    else
      log_status "git credential manager is already installed"
    fi

    case "$OS" in
      Darwin)
        if ! command -v defaultbrowser >/dev/null 2>&1; then
          log_progress "Installing defaultbrowser util (macos)"
          install_pkg defaultbrowser
        else
          log_status "defaultbrowser is already installed"
        fi

        if [[ ! -d "/Applications/Firefox.app" ]]; then
          log_progress "Installing firefox (macos)"
          install_pkg firefox
        else
          log_status "firefox is already installed"
        fi

        if command -v defaultbrowser >/dev/null 2>&1 && [[ -d "/Applications/Firefox.app" ]]; then
          log_progress "Setting firefox as default browser (macos)"
          defaultbrowser firefox
        fi
      ;;
    esac

    if command -v git-credential-manager >/dev/null 2>&1; then
      log_progress "Re-adding universal repo with git-credential-manager"
      clone_git_repo $DI_UNIVERSAL_REPO $DI_DOTFILES_DIR/universal_temp

      if [[ -d "$DI_DOTFILES_DIR/universal_temp" ]]; then
        log_progress "Replacing $DI_UNIVERSAL_DIR with the fresh clone"
        rm -rf $DI_UNIVERSAL_DIR && mv $DI_DOTFILES_DIR/universal_temp $DI_UNIVERSAL_DIR
      fi
    else
      log_warn "git-credential-manager not installed, skipping universal repo re-add"
    fi
  else
    log_status "The universal repo already has git history, skipping the re-add"
  fi

  for private_key in ~/.ssh/id_rsa_personal ~/.ssh/id_rsa_work; do
    [[ -f "$private_key" ]] && chmod 400 "$private_key" # 400 for owner read-only, I don't want to modify these files, other users cannot access any file
  done
  chmod 600 ~/.ssh/config # 600 for ~/.ssh/config, it's a normal file, needs read/write, but no execute
  chmod 700 ~/.ssh # 700 for ~/.ssh, read/write/execute to make sure ssh works correctly, no access to other users
else
  log_error "Clone universal repo into $DI_UNIVERSAL_DIR first"
  exit 1
fi

if command -v git >/dev/null 2>&1; then
  clone_git_repo "$DI_VOIDRICE_REPO" "$DI_VOIDRICE_DIR"
  clone_git_repo "$DI_PKGLISTS_REPO" "$DI_PKGLISTS_DIR"
  clone_git_repo "$DI_NVIM_REPO" "$DI_NVIM_DIR"

  for dir in $DI_VOIDRICE_DIR/.local/bin/*/; do
    dir_name=$(basename "$dir")
    mkdir -p $HOME/.local/bin/$dir_name
  done

  log_progress "Stowing the dotfiles (voidrice)"
  stow_dotfiles voidrice
fi

if ! command -v zsh >/dev/null 2>&1; then
  log_progress "Installing ZSH"
  install_pkg zsh
else
  log_status "ZSH is already installed"
fi

if command -v zsh >/dev/null 2>&1; then
  mkdir -p "$HOME/.cache/zsh/"
  mkdir -p "$HOME/.config/zsh/"

  touch "$HOME/.cache/zsh/.zsh_history"

  if ! [[ "$SHELL" =~ .*'zsh' ]]; then
    log_progress "Changing default shell to ZSH"

    case "$OS" in
      Linux)
        sudo chsh -s /usr/bin/zsh "$USER"
        ;;
    Darwin)
      sudo chsh -s /bin/zsh "$USER"
      ;;
    esac
  else
    log_status "ZSH is already a default shell"️
  fi

  rm -f "$HOME/.config/zsh/.zcompdump"
fi

if ! command -v fnm >/dev/null 2>&1; then
  log_progress "Installing fnm"
  install_pkg fnm
else
  log_status "fnm is already installed"
fi

if command -v fnm >/dev/null 2>&1; then
  log_progress "Installing the latest LTS node with fnm"
  fnm install --lts
  fnm default lts-latest
  eval "$(fnm env --shell bash)"
  fnm use lts-latest
  log_status "Using node $(node --version) from fnm"
fi

if ! command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then
  log_progress "Installing $DI_NPM_HELPER"
  install_pkg nodejs fnm "$DI_NPM_HELPER"
else
  log_status "$DI_NPM_HELPER is already installed"
fi

if command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then
  log_progress "Installing node packages via $DI_NPM_HELPER"

  packages="$DI_PKGLISTS_DIR/$DI_PKG_TYPE/$DI_NPM_HELPER.txt"

  if [[ -f "$packages" ]]; then
    case "$OS" in
    Linux)
      export NPM_CONFIG_PREFIX="$HOME/.local"
      ;;
    esac

    log_progress "Installing the global packages listed in $packages"
    xargs $DI_NPM_HELPER install --global <"$packages"
  else
    log_warn "No $DI_NPM_HELPER package list at $packages, skipping"
  fi
fi

source "$DI_VOIDRICE_DIR/.config/zsh/profile/profile.paths"

bin_dotfiles_shortcuts="$HOME/.local/bin/generate-shell-shortcuts"
repo_dotfiles_shortcuts="$HOME/.config/dotfiles/voidrice/.local/bin/generate-shell-shortcuts"

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
