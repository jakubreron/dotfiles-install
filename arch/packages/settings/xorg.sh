#!/usr/bin/env bash

if command -v Xorg >/dev/null 2>&1; then
  log_progress "Xorg detected, setting up"

  setup_touchpad() {
    if laptop-detect >/dev/null 2>&1; then
      log_progress "Laptop detected, setting up the touchpad"
      printf 'Section "InputClass"
      Identifier "libinput touchpad catchall"
      MatchIsTouchpad "on"
      MatchDevicePath "/dev/input/event*"
      Driver "libinput"
      Option "Tapping" "on"
      Option "NaturalScrolling" "true"
      EndSection' | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf
    else
      log_progress "No laptop detected, skipping the touchpad settings"
    fi
  }

  setup_intel_hd_xorg() {
    if laptop-detect >/dev/null 2>&1; then
      log_progress "Laptop detected, setting up Intel HD Graphics on Xorg"
      printf 'Section "Device"
      Identifier "Intel Graphics"
      Driver "intel"
      Option      "TearFree"        "true"
      Option      "TripleBuffer"    "false"
      Option      "SwapbuffersWait" "false"
      EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf
    else
      log_status "No laptop detected, skipping Intel HD Graphics setup on Xorg"️
    fi
  }

  setup_intel_hd_xorg
  setup_touchpad
else
  log_status "No Xorg detected, skipping the configuration"️
fi
