#!/bin/sh

set_zsh_shell() {
  log_pretty_message "Setting up the ZSH"
  chsh -s /usr/bin/zsh "$user"
  mkdir -p "$HOME/.cache/zsh/"
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

set_zsh_shell
install_zap
install_lvim
