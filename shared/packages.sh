#!/bin/sh

set_zsh_shell() {
  chsh -s /usr/bin/zsh "$user"
  mkdir -p "$HOME/.cache/zsh/"
}

install_zap() {
  if ! command -v zap >/dev/null 2>&1; then 
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
  fi
}

install_lvim() {
  config_dir="$HOME/.config/lvim"

  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

  rm -rf "$config_dir"
  git clone https://github.com/jakubreron/lvim "$config_dir"
}

install_zap
install_lvim
