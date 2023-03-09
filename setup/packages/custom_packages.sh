#!/bin/sh

# TODO: setup intel/dptf or thermald on laptop

install_auto_cpufreq() {
  if laptop-detect -s > /dev/null; then
    echo "Running on a laptop"
    path="$git_clone_path/auto-cpufreq"
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git "$path"
    cd "$path" && sudo ./auto-cpufreq-installer
    sudo auto-cpufreq --install
    rm -rf "$path"
  fi
}

install_zap() {
  if ! command -v zap &> /dev/null; then 
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
  fi
}

install_keyd() {
  if ! command -v keyd &> /dev/null; then 
    path="$git_clone_path/keyd"
    git clone https://github.com/rvaiya/keyd "$path"
    cd "$path" || exit
    make && sudo make install
    sudo systemctl enable keyd && sudo systemctl start keyd
    cd ..
    rm -rf "$path"
    global_config_path="/etc/keyd/defaulf.conf"
    echo "[ids]

*

[main]

capslock = overload(meta, esc)

# Remaps the escape key to capslock
esc = capslock" | sudo tee "$global_config_path"
  fi
}

install_lvim() {
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
}

setup_custom_packages() {
  install_auto_cpufreq
  install_zap
  install_keyd
  install_lvim
}
