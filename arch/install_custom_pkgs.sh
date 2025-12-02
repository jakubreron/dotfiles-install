#!/usr/bin/env bash

install_auto_cpufreq() {
  if laptop-detect >/dev/null; then
    if ! command -v auto-cpufreq >/dev/null 2>&1; then
      log_progress "Laptop detected, installing auto_cpufreq"
      install_pkg auto-cpufreq
      sudo auto-cpufreq --install
    fi

    sudo systemctl enable --now auto-cpufreq.service
    sudo systemctl mask power-profiles-daemon.service
    curl -sL "https://raw.githubusercontent.com/AdnanHodzic/auto-cpufreq/master/auto-cpufreq.conf-example" | sudo tee /etc/auto-cpufreq.conf
    sudo systemctl restart auto-cpufreq.service
  else
    log_status "No laptop detected, skipping auto_cpufreq installation"️
  fi
}

install_keyd() {
  if ! command -v keyd >/dev/null 2>&1; then
    log_progress "Installing and setting up keyd"
    install_pkg keyd
  fi

  if command -v keyd >/dev/null 2>&1; then
    log_status "keyd is already installed, performing the setup"️

    sudo usermod -aG keyd "$USER"
    sudo systemctl enable keyd --now

    echo "[ids]
*

[main]
control = layer(emacs_control)
leftalt = layer(mac_meta)
leftmeta = layer(mac_option)
compose = layer(mac_option)

capslock = overload(meta, esc)
esc = capslock

[emacs_control:C]
b = left
f = right 
p = up
n = down
h = backspace
a = home
e = end
m = enter
w = C-backspace
d = delete
S-m = S-enter

[mac_option:A]

b = C-left
f = C-right

[mac_meta:C]
# Switch directly to an open tab (e.g. Firefox, VS code)
1 = A-1
2 = A-2
3 = A-3
4 = A-4
5 = A-5
6 = A-6
7 = A-7
8 = A-8
9 = A-9

# Copy
# c = C-insert
# Paste
# v = S-insert
# Cut
# x = S-delete

# Move cursor to beginning of line
left = home
# Move cursor to end of Line
right = end" | sudo tee "/etc/keyd/default.conf"
  fi
}

install_auto_cpufreq
install_keyd
