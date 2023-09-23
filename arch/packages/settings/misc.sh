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

setup_userjs(){
  if ! command -v "$DI_BROWSER" >/dev/null 2>&1; then
    log_progress "Installing $DI_BROWSER"
    install_pkg "$DI_BROWSER"
  fi

  if command -v "$DI_BROWSER" >/dev/null 2>&1; then
    log_progress "Launching headless $DI_BROWSER for profile generation"
    sudo -u "$DI_USER" "$DI_BROWSER" --headless >/dev/null 2>&1 &
    sleep 1

    browser_dir="$HOME/.mozilla/firefox"
    browser_profiles_ini_dir="$browser_dir/profiles.ini"
    profile="$(sed -n "/Default=.*.dev-edition-default/ s/.*=//p" "$browser_profiles_ini_dir")"
    browser_profile_dir="$browser_dir/$profile"

    if [ -d "$browser_profile_dir" ]; then
      log_progress "Creating and deploying user.js file for firefox"
      arkenfox="$browser_profile_dir/arkenfox.js"
      overrides="$browser_profile_dir/user-overrides.js"
      userjs="$browser_profile_dir/user.js"
      ln -fs "$HOME/.config/firefox/larbs.js" "$overrides"
      [ ! -f "$arkenfox" ] && curl -sL "https://raw.githubusercontent.com/arkenfox/user.js/master/user.js" > "$arkenfox"
      cat "$arkenfox" "$overrides" > "$userjs"
      sudo chown "$user:wheel" "$arkenfox" "$userjs"

      # Install the updating script.
      sudo mkdir -p /usr/local/lib /etc/pacman.d/hooks
      sudo cp "$HOME/.local/bin/arkenfox-auto-update" /usr/local/lib/
      sudo chown root:root /usr/local/lib/arkenfox-auto-update
      sudo chmod 755 /usr/local/lib/arkenfox-auto-update

      # Trigger the update when needed via a pacman hook.
      echo "[Trigger]
  Operation = Upgrade
  Type = Package
  Target = firefox
  Target = firefox-developer-edition
  Target = librewolf
  Target = librewolf-bin
  [Action]
  Description=Update Arkenfox user.js
  When=PostTransaction
  Depends=arkenfox-user.js
  Exec=/usr/local/lib/arkenfox-auto-update" | sudo tee /etc/pacman.d/hooks/arkenfox.hook

      sudo pkill -u "$DI_USER" "$DI_BROWSER"
    fi
  fi
}

setup_mpd() {
  if ! command -v mpd >/dev/null 2>&1; then
    log_progress "Installing mpd"
    install_pkg mpd
  fi

  if command -v mpd >/dev/null 2>&1; then
    log_progress "Setting up mpd"

    config_path="$HOME/.config/mpd" 
    mkdir -p "$config_path/playlists"
    touch "$config_path"/{database,mpdstate}

    systemctl --user enable --now mpd.service
  fi
}

setup_darkman() {
  if ! command -v darkman >/dev/null 2>&1; then
    log_progress "Installing darkman"
    install_pkg darkman
  fi

  if command -v darkman >/dev/null 2>&1; then
    log_progress "Setting up darkman"
    sudo systemctl enable --now avahi-daemon.service
    sudo systemctl restart geoclue.service

    # NOTE: on hyprland, it's launched via the config file
    if ! command -v Hyprland >/dev/null 2>&1; then
      systemctl --user enable --now darkman.service
    fi
  fi
}

setup_nightlight() {
  if ! command -v gammastep >/dev/null 2>&1; then
    log_progress "Installing nightlight"
    install_pkg gammastep
  fi

  # NOTE: on hyprland, it's launched via the config file
  if command -v gammastep >/dev/null 2>&1 && ! command -v Hyprland >/dev/null 2>&1; then
    log_progress "Setting up nightlight"
    systemctl --user enable gammastep.service --now
  fi
}

setup_display_brightness_util() {
  if ! command -v ddcutil >/dev/null 2>&1; then
    log_progress "Installing display brightness management util (ddcutil)"
    install_pkg ddcutil
  fi

  log_progress "Setting up display brightness management util (ddcutil)"

  sudo gpasswd --add "$DI_USER" i2c
  echo 'i2c_dev' | sudo tee /etc/modules-load.d/i2c_dev.conf
}

# TODO: add more integration steps
# setup_cloud() {
#   if ! command -v grive >/dev/null 2>&1; then
#     log_progress "Installing grive"
#     install_pkg grive
#   fi

#   if command -v grive >/dev/null 2>&1; then
#     log_progress "Setting up Google Drive integration"
#     systemctl --user enable --now grive@$(systemd-escape Cloud).service
#   fi
# }

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

# TODO: do more steps
# setup_mail() {
#   mw -t 5
# }

setup_cache_management
setup_userjs
setup_mpd
setup_darkman
setup_nightlight
setup_display_brightness_util
# setup_cloud
setup_mpris_proxy
# setup_mail
