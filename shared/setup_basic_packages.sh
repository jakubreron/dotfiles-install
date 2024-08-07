#!/usr/bin/env bash

install_and_setup_zsh() {
  if ! command -v zsh >/dev/null 2>&1; then
    log_progress "Installing ZSH"
    install_pkg zsh zsh-completions
  fi

  if command -v zsh >/dev/null 2>&1; then
    mkdir -p "$HOME/.cache/zsh/"
    mkdir -p "$HOME/.config/zsh/"

    touch "$HOME/.config/zsh/.zsh_history"

    if ! [[  "$SHELL" =~ .*'zsh' ]]; then
      log_progress "Changing default shell to ZSH"

      case "$OS" in
        Linux)
          chsh -s /usr/bin/zsh "$DI_USER"
          ;;
        Darwin)
          chsh -s /bin/zsh "$DI_USER"
          ;;
      esac
    else
      log_status "ZSH is already a default shell"️
    fi
  fi
}

install_pkg_helper() {
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
}

install_zap() {
  if ! command -v zap >/dev/null 2>&1 ||  [ ! -d "$HOME/.local/share/zap" ]; then 
    log_progress "Setting up Zap"
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
  else
    log_status "Zap is already installed"️
  fi
}

install_node_packages() {
  if ! command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then 
    log_progress "Installing $DI_NPM_HELPER"
    install_pkg nodejs fnm "$DI_NPM_HELPER"
  fi

  if command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then 
    log_progress "Installing node packages via $DI_NPM_HELPER"

    packages="$DI_PKGLISTS_DIR/$DI_PKG_TYPE/yarn.txt"
    if [ "$DI_NPM_HELPER" = 'yarn' ]; then
      $DI_NPM_HELPER global add < "$packages"
    else
      $DI_NPM_HELPER install --global < "$packages"
    fi
  fi
}


install_and_setup_zsh
install_pkg_helper
install_zap
install_node_packages
