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
  if ! command -v "$DI_FIREFOX_BROWSER" >/dev/null 2>&1; then
    log_progress "Installing $DI_FIREFOX_BROWSER"
    install_pkg "$DI_FIREFOX_BROWSER"
  fi

  if command -v "$DI_FIREFOX_BROWSER" >/dev/null 2>&1; then
    log_progress "Launching headless $DI_FIREFOX_BROWSER for profile generation"
    sudo -u "$DI_USER" "$DI_FIREFOX_BROWSER" --headless >/dev/null 2>&1 &
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

      sudo pkill -u "$DI_USER" "$DI_FIREFOX_BROWSER"
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

# TODO: add more integration steps
setup_cloud() {
  if ! command -v grive >/dev/null 2>&1; then
    log_progress "Installing grive"
    install_pkg grive
  fi

  if command -v grive >/dev/null 2>&1; then
    log_progress "Setting up Google Drive integration"
    systemctl --user enable --now grive@$(systemd-escape Cloud).service
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

setup_thinkpad_thermal_management_fixes() {
  if [[ "$(cat /sys/devices/virtual/dmi/id/chassis_vendor)" = 'LENOVO' ]]; then
    printf '#!/bin/bash
# Disable BD PROCHOT signal on ThinkPads to prevent throttling the CPU to min. freq.
modprobe msr
reg="$(rdmsr -d 0x1FC)"         # commands rdmsr and wrmsr provided by msr-tools on Arch
if [ $((reg%2)) -eq 1 ]; then   # basically reg & 0xFFFE
	wrmsr 0x1FC $((reg-1))
fi' | sudo tee /usr/local/bin/throttlestop
    sudo chmod +x /usr/local/bin/throttlestop

    printf '[Unit]
Description=Stop throttling on x1 carbon
#After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/throttlestop
ExecStop=/usr/local/bin/throttlestop
StandardOutput=journal

[Install]
WantedBy=multi-user.target'

    if [ -f /usr/lib/systemd/system/thermald.service ] >/dev/null 2>&1; then
      sudo sed --in-place --follow-symlinks "0,/ExecStart.*/s//ExecStart=\/usr\/bin\/thermald --systemd --dbus-enable --adaptive --ignore-cpuid-check/" /usr/lib/systemd/system/thermald.service
    fi

    systemctl daemon-reload
    systemctl enable throttlestop.service --now
  fi
}

setup_cache_management
setup_userjs
setup_mpd
setup_darkman
setup_nightlight
# setup_cloud
setup_mpris_proxy
setup_thinkpad_thermal_management_fixes   
