#!/bin/sh

set_zsh_shell() {
  chsh -s /usr/bin/zsh "$user"
  mkdir -p "~/.cache/zsh/"
}

install_zap() {
  if ! command -v zap &> /dev/null; then 
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
  fi
}

install_lvim() {
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
}

install_zap
install_lvim
