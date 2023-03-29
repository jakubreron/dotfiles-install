#!/bin/sh

set_zsh_shell() {
  if ! command -v zsh >/dev/null 2>&1; then
    log_pretty_message "Installing ZSH"
    install_pkg zsh zsh-completions
  fi

  if ! [[  "$SHELL" =~ .*'zsh' ]]; then
    log_pretty_message "Changing default shell to ZSH"

    case "$(uname -s)" in
      Linux*)
        chsh -s /usr/bin/zsh "$user"
        ;;
      Darwin)
        chsh -s /bin/zsh "$user"
        ;;
    esac

    mkdir -p "$HOME/.cache/zsh/"
  fi
}

install_zap() {
  if ! command -v zap >/dev/null 2>&1; then 
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
  if command -v "$npm_helper" >/dev/null 2>&1; then 
    log_pretty_message "There is no $npm_helper installed, installing $npm_helper"
    install_pkg node fnm "$npm_helper"
  fi

  log_pretty_message "Installing node packages via $npm_helper"
  packages="$pkglists_dir/$pkgtype/yarn.txt"
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
