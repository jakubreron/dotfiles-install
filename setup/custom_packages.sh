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
  [ -x "$(command -v "zap")" ] || zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
}

install_keyd() {
  if command -v keyd &> /dev/null; then 
    path="/home/$user/Downloads/keyd"
    git clone https://github.com/rvaiya/keyd "$path" || exit
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

setup_custom_packages() {
  install_zap
  install_keyd
}
