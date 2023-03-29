#!/bin/sh

enable_cache_management() {
  log-pretty-message "Setting up the cache management"
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

log-pretty-message "Launching headless firefox for profile generation"
sudo -u "$user" "$browser" --headless >/dev/null 2>&1 &
sleep 1

browser_dir="$HOME/.mozilla/firefox"
browser_profiles_ini_dir="$browser_dir/profiles.ini"
profile="$(sed -n "/Default=.*.dev-edition-default/ s/.*=//p" "$browser_profiles_ini_dir")"
browser_profile_dir="$browser_dir/$profile"

make_userjs(){
  log-pretty-message "Creating and deploying user.js file for firefox"
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

sudo pkill -u "$user" "$browser"
}

setup_mpd_settings() {
  log-pretty-message "Setting up mpd"
  systemctl --user enable --now mpd.service
  [ -f "$HOME/.config/mpd" ] && touch "$HOME"/.config/mpd/{database,mpdstate}
}

setup_gnome_settings() {
  if command -v gsettings >/dev/null 2>&1; then
    log-pretty-message "Setting up GNOME settings via gsettings"
    gsettings set org.gnome.nautilus.preferences show-hidden-files true
  else
    log-pretty-message "No gsettings detected, skipping GNOME settings"
  fi
}

setup_darkman() {
  sudo systemctl enable --now avahi-daemon.service
  sudo systemctl restart geoclue.service
  systemctl --user enable --now darkman.service
}

setup_cloud() {
  if command -v grive >/dev/null 2>&1; then
    log-pretty-message "Setting up Google Drive integration"
    systemctl --user enable --now grive@$(systemd-escape Cloud).service
  else
    log-pretty-message "No grive detected, skipping Google Drive integration"
  fi
}


enable_cache_management
[ -d "$browser_profile_dir" ] && make_userjs
setup_mpd_settings
setup_gnome_settings
setup_cloud
