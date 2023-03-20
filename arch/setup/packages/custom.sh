#!/bin/sh

# TODO: setup intel/dptf or thermald on laptop

install_auto_cpufreq() {
  if laptop-detect -s > /dev/null; then
    echo "Running on a laptop"
    path="$git_clone_path/auto-cpufreq"
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git "$path"
    cd "$path" && sudo ./auto-cpufreq-installer
    sudo auto-cpufreq --install
    sudo systemctl enable --now auto-cpufreq.service
    sudo systemctl mask power-profiles-daemon.service
    curl -sL "https://raw.githubusercontent.com/AdnanHodzic/auto-cpufreq/master/auto-cpufreq.conf-example" | sudo tee /etc/auto-cpufreq.conf
    sudo sed -i '/^\[battery\]/,/^\[/s/^# scaling_min_freq = 800000/scaling_min_freq = 1600000/' /etc/auto-cpufreq.conf
    sudo systemctl restart auto-cpufreq.service
    rm -rf "$path"
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
esc = capslock
rightalt = alt" | sudo tee "$global_config_path"
  fi
}

install_auto_cpufreq
install_keyd
