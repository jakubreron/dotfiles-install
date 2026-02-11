#!/usr/bin/env bash

setup_cache_management() {
  log_progress "Setting up the cache management"
  sudo journalctl --vacuum-time=4weeks

  if ! [ -f /etc/systemd/system/paccache.timer ] >/dev/null 2>&1; then
    echo '[Unit]
Description=Clean-up old pacman pkg

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/paccache.timer
  fi

  if ! [ -f /usr/share/libalpm/hooks/paccache.hook ] >/dev/null 2>&1; then
    echo '[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning pacman cache with paccache …
When = PostTransaction
Exec = /usr/bin/paccache -r' | sudo tee /usr/share/libalpm/hooks/paccache.hook
  fi
}

setup_mpd() {
  if ! command -v mpd >/dev/null 2>&1; then
    log_progress "Installing mpd"
    install_pkg mpd
  fi

  if command -v mpd >/dev/null 2>&1; then
    log_progress "Setting up mpd"

    local config_path="$HOME/.config/mpd"
    mkdir -p "$config_path/playlists"
    touch $config_path/{database,mpdstate}

    systemctl --user enable --now mpd.service
  fi
}

setup_darkman() {
  log_progress "Installing geoclue"
  install_pkg geoclue

  log_progress "Enabling geoclue"
  sudo systemctl enable --now geoclue.service

  log_progress "Configuring geoclue to allow access for darkman"
  echo "
[darkman]
allowed=true
system=false
users=" | sudo tee /etc/geoclue/geoclue.conf
  sudo systemctl restart --now geoclue.service

  if ! command -v darkman >/dev/null 2>&1; then
    log_progress "Installing darkman"
    install_pkg darkman
  fi

  if command -v darkman >/dev/null 2>&1; then
    log_progress "Setting up darkman"
    sudo systemctl enable --now avahi-daemon.service
    sudo systemctl enable --now geoclue.service
  fi
}

setup_mpris_proxy() {
  if ! command -v playerctl >/dev/null 2>&1; then
    log_progress "Installing playerctl (to enable mpris_proxy)"
    install_pkg playerctl
  fi

  if command -v playerctl >/dev/null 2>&1; then
    log_progress "Setting up mpris-proxy"

    systemctl --user daemon-reload
    systemctl --user enable --now mpris-proxy.service
  fi
}

setup_cache_management
setup_mpd
setup_darkman
setup_mpris_proxy
