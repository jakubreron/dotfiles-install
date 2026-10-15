#!/usr/bin/env bash

install_tlp() {
  if ! command -v tlp >/dev/null 2>&1; then
    log_progress "Installing and setting up tlp"
    install_pkg tlp
  else
    log_status "tlp is already installed"
  fi

  if command -v tlp >/dev/null 2>&1; then
    log_progress "Setting up tlp"
    sudo systemctl enable --now tlp
  fi
}

install_keyd() {
  if ! command -v keyd >/dev/null 2>&1; then
    log_progress "Installing and setting up keyd"
    install_pkg keyd
  else
    log_status "keyd is already installed"
  fi

  if command -v keyd >/dev/null 2>&1; then
    log_status "keyd is already installed, performing the setup"️

    log_progress "Adding $USER to the keyd group and enabling the keyd service"
    sudo usermod -aG keyd "$USER"
    sudo systemctl enable keyd --now

    log_progress "Writing /etc/keyd/default.conf"
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

install_powertop() {
  if ! command -v powertop >/dev/null 2>&1; then
    log_progress "Installing and setting up powertop"
    install_pkg powertop
  else
    log_status "powertop is already installed"
  fi

  if command -v powertop >/dev/null 2>&1; then
    log_progress "Setting up powertop"
    sudo powertop --auto-tune
  fi
}

install_tlp
install_keyd
install_powertop
