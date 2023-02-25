#!/bin/sh

# TODO: only on laptops
# TODO: install https://github.com/AdnanHodzic/auto-cpufreq#auto-cpufreq-installer
# TODO: and setup into /etc/auto-cpufreq.conf https://github.com/AdnanHodzic/auto-cpufreq#auto-cpufreq-modes-and-options (min freq on battery and so on)
# TODO: also this: https://github.com/intel/dptf or use "thermald"
# install_auto_cpufreq() {
#   git clone https://github.com/AdnanHodzic/auto-cpufreq.git
#   cd auto-cpufreq && sudo ./auto-cpufreq-installer
#   sudo auto-cpufreq --install
# }

install_zap() {
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
}

install_keyd() {
  path="/home/$user/Downloads/keyd"
  git clone https://github.com/rvaiya/keyd "$path" || return 1
  cd "$path" || return 1
  make && sudo make install
  sudo systemctl enable keyd && sudo systemctl start keyd
  rm -rf "$path"
  global_config_path="/etc/keyd/defaulf.conf"
  echo "[ids]

*

[main]

capslock = overload(meta, esc)

# Remaps the escape key to capslock
esc = capslock" | sudo tee "$global_config_path"
}

setup_custom_packages() {
  [ -x "$(command -v "zap")" ] || install_zap
  [ -x "$(command -v "keyd")" ] || install_keyd
}
