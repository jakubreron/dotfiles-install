#!/bin/sh

case "$(uname -s)" in
  Linux*)
    if ! command -v "$di_pkg_manager_helper" >/dev/null 2>&1; then
      log_pretty_message "Installing AUR helper: $di_pkg_manager_helper"

      path="$git_clone_path/$di_pkg_manager_helper"
      clone_git_repo "https://aur.archlinux.org/$di_pkg_manager_helper.git" "$path"

      makepkg -si -p "$path"
      rm -rf "$path"
    else
      log_pretty_message "AUR helper $di_pkg_manager_helper is already installed" ℹ️
    fi

    ;;
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      log_pretty_message "Installing brew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      log_pretty_message "Brew is already installed" ℹ️
    fi
    ;;
esac

set_zsh_shell() {
  if ! command -v zsh >/dev/null 2>&1; then
    log_pretty_message "Installing ZSH"
    install_pkg zsh zsh-completions
  fi

  mkdir -p "$HOME/.cache/zsh/"

  if ! [[  "$SHELL" =~ .*'zsh' ]]; then
    log_pretty_message "Changing default shell to ZSH"

    case "$(uname -s)" in
      Linux*)
        chsh -s /usr/bin/zsh "$di_user"
        ;;
      Darwin)
        chsh -s /bin/zsh "$di_user"
        ;;
    esac
  else
    log_pretty_message "ZSH is already a default shell" ℹ️
  fi
}

install_zap() {
  if ! [ -d "$HOME/.local/share/zap" ]; then 
    log_pretty_message "Setting up ZAP for ZSH"
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
  else
    log_pretty_message "ZAP for ZSH is already installed" ℹ️
  fi
}

install_lvim() {
  if ! command -v lvim >/dev/null 2>&1; then
    log_pretty_message "Installing LunarVim"
    bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

    log_pretty_message "Replacing default LunarVim config with dotfiles config"
    config_dir="$HOME/.config/lvim"
    rm -rf "$config_dir"
    git clone https://github.com/jakubreron/lvim "$config_dir"
  else
    log_pretty_message "LunarVim is already installed" ℹ️
  fi
}

install_node_packages() {
  if ! command -v "$npm_helper" >/dev/null 2>&1; then 
    log_pretty_message "Installing $npm_helper"
    install_pkg node fnm "$npm_helper"
  fi

  log_pretty_message "Installing node packages via $npm_helper"
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
