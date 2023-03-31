#!/bin/sh

case "$(uname -s)" in
  Linux*)
    if ! command -v "$di_pkg_manager_helper" >/dev/null 2>&1; then
      log_progress "Installing AUR helper: $di_pkg_manager_helper"

      path="$git_clone_path/$di_pkg_manager_helper"
      clone_git_repo "https://aur.archlinux.org/$di_pkg_manager_helper.git" "$path"

      makepkg -si -p "$path"
      rm -rf "$path"
    else
      log_status "AUR helper $di_pkg_manager_helper is already installed"️
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

set_zsh_shell() {
  if ! command -v zsh >/dev/null 2>&1; then
    log_progress "Installing ZSH"
    install_pkg zsh zsh-completions
  fi

  mkdir -p "$HOME/.cache/zsh/"

  if ! [[  "$SHELL" =~ .*'zsh' ]]; then
    log_progress "Changing default shell to ZSH"

    case "$(uname -s)" in
      Linux*)
        chsh -s /usr/bin/zsh "$di_user"
        ;;
      Darwin)
        chsh -s /bin/zsh "$di_user"
        ;;
    esac
  else
    log_status "ZSH is already a default shell"️
  fi
}

install_zap() {
  if ! [ -d "$HOME/.local/share/zap" ]; then 
    log_progress "Setting up ZAP for ZSH"
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
  else
    log_status "ZAP for ZSH is already installed"️
  fi
}

install_lvim() {
  if ! command -v lvim >/dev/null 2>&1; then
    log_progress "Installing LunarVim"
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

    log_progress "Replacing default LunarVim config with dotfiles config"
    config_dir="$HOME/.config/lvim"
    rm -rf "$config_dir"
    git clone https://github.com/jakubreron/lvim "$config_dir"
  else
    log_status "LunarVim is already installed"️
  fi
}

install_node_packages() {
  if ! command -v "$npm_helper" >/dev/null 2>&1; then 
    log_progress "Installing $npm_helper"
    install_pkg node fnm "$npm_helper"
  fi

  log_progress "Installing node packages via $npm_helper"
  packages="$pkglists_dir/$di_pkg_type/yarn.txt"
  if [ "$npm_helper" = 'yarn' ]; then
    $npm_helper global add < "$packages"
  else
    $npm_helper install --global < "$packages"
  fi
}


set_zsh_shell
install_zap
install_lvim
install_node_packages
