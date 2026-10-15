#!/usr/bin/env bash

setup_cache_management() {
  log_progress "Setting up the cache management"
  log_progress "Vacuuming the systemd journal to 4 weeks"
  sudo journalctl --vacuum-time=4weeks

  if ! [ -f /etc/systemd/system/paccache.timer ] >/dev/null 2>&1; then
    log_progress "Writing the paccache timer"
    echo '[Unit]
Description=Clean-up old pacman pkg

[Timer]
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/paccache.timer
  else
    log_status "The paccache timer already exists, skipping"
  fi

  if ! [ -f /usr/share/libalpm/hooks/paccache.hook ] >/dev/null 2>&1; then
    log_progress "Writing the paccache pacman hook"
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
  else
    log_status "The paccache pacman hook already exists, skipping"
  fi
}

setup_mpd() {
  if ! command -v mpd >/dev/null 2>&1; then
    log_progress "Installing mpd"
    install_pkg mpd
  else
    log_status "mpd is already installed"
  fi

  if command -v mpd >/dev/null 2>&1; then
    log_progress "Setting up mpd"

    local config_path="$HOME/.config/mpd"
    log_progress "Creating the mpd config files in $config_path"
    mkdir -p "$config_path/playlists"
    touch $config_path/{database,mpdstate}

    log_progress "Enabling the mpd user service"
    systemctl --user enable --now mpd.service
  fi
}

setup_darkman() {
  if ! pacman -Q geoclue >/dev/null 2>&1; then
    log_progress "Installing geoclue"
    install_pkg geoclue
  else
    log_status "geoclue is already installed"
  fi

  if ! command -v darkman >/dev/null 2>&1; then
    log_progress "Installing darkman"
    install_pkg darkman
  else
    log_status "darkman is already installed"
  fi

  if command -v darkman >/dev/null 2>&1 && pacman -Q geoclue >/dev/null 2>&1; then
    log_progress "Setting up darkman"
    log_progress "Enabling the geoclue agent user service"
    systemctl --user enable --now geoclue-agent.service
  fi
}

setup_mpris_proxy() {
  if ! command -v playerctl >/dev/null 2>&1; then
    log_progress "Installing playerctl (to enable mpris_proxy)"
    install_pkg playerctl
  else
    log_status "playerctl is already installed"
  fi

  if command -v playerctl >/dev/null 2>&1; then
    log_progress "Setting up mpris-proxy"

    log_progress "Reloading systemd user units and enabling mpris-proxy"
    systemctl --user daemon-reload
    systemctl --user enable --now mpris-proxy.service
  fi
}

setup_cache_management
setup_mpd
setup_darkman
setup_mpris_proxy
