#!/bin/sh

# TODO: setup SDDM/autologin https://youtu.be/wNL6eIoksd8?t=482

enable_cache_management() {
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

setup_bluetooth() {
  sudo sed -i 's/^#AutoEnable=true/AutoEnable=true/g' /etc/bluetooth/main.conf
  sudo systemctl enable bluetooth.service --now
}

sudo -u "$user" "$browser" --headless >/dev/null 2>&1 &
sleep 1

browser_dir="$HOME/.mozilla/firefox"
browser_profiles_ini_dir="$browser_dir/profiles.ini"
profile="$(sed -n "/Default=.*.dev-edition-default/ s/.*=//p" "$browser_profiles_ini_dir")"
browser_profile_dir="$browser_dir/$profile"

make_userjs(){
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

setup_program_settings() {
  systemctl --user enable --now mpd.service
  [ -f "$HOME/.config/mpd" ] && touch "$HOME"/.config/mpd/{database,mpdstate}

  if command -v gsettings >/dev/null 2>&1; then
     gsettings set org.gnome.nautilus.preferences show-hidden-files true
  fi
}

setup_darkman() {
  sudo systemctl enable --now avahi-daemon.service
  sudo systemctl restart geoclue.service
  systemctl --user enable --now darkman.service
}

setup_cloud() {
  if command -v grive >/dev/null 2>&1; then
    systemctl --user enable --now grive@$(systemd-escape Cloud).service
  fi
}

setup_intel_hd_xorg() {
  if laptop-detect -s >/dev/null 2>&1; then
    printf 'Section "Device"
  Identifier "Intel Graphics"
  Driver "intel"
  Option      "TearFree"        "false"
  Option      "TripleBuffer"    "false"
  Option      "SwapbuffersWait" "false"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf
  fi
}


enable_cache_management
setup_bluetooth
[ -d "$browser_profile_dir" ] && make_userjs
setup_program_settings
setup_cloud
if command -v Xorg >/dev/null 2>&1; then
  setup_intel_hd_xorg
fi
