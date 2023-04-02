#!/usr/bin/env bash

enable_cache_management() {
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

make_userjs(){
  if ! command -v "$DI_BROWSER" >/dev/null 2>&1; then
    log_progress "Installing $DI_BROWSER"
    install_pkg "$DI_BROWSER"
  fi

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
}

setup_mpd_settings() {
  if ! command -v mpd >/dev/null 2>&1; then
    log_progress "Installing mpd"
    install_pkg mpd
  fi

  log_progress "Setting up mpd"

  config_path="$HOME/.config/mpd" 
  [ -d "$config_path" ] && mkdir -p "$config_path"
  touch "$config_path"/{database,mpdstate}

  systemctl --user enable --now mpd.service
}

setup_darkman() {
  if ! command -v darkman >/dev/null 2>&1; then
    log_progress "Installing darkman"
    install_pkg darkman
  fi

  log_progress "Setting up darkman"
  sudo systemctl enable --now avahi-daemon.service
  sudo systemctl restart geoclue.service
  systemctl --user enable --now darkman.service
}

setup_redshift() {
  if ! command -v redshift >/dev/null 2>&1; then
    log_progress "Installing redshift"
    install_pkg redshift
  fi

  log_progress "Setting up redshift"
  systemctl --user enable redshift.service
}

# TODO: add more integration steps
setup_cloud() {
  if ! command -v grive >/dev/null 2>&1; then
    log_progress "Installing grive"
    install_pkg grive
  fi

  log_progress "Setting up Google Drive integration"
  systemctl --user enable --now grive@$(systemd-escape Cloud).service
}

enable_cache_management
make_userjs
setup_mpd_settings
setup_cloud
