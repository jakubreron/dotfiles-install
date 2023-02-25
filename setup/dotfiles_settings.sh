#!/bin/sh

# TODO: setup SDDM/autologin https://youtu.be/wNL6eIoksd8?t=482

setup_program_settings() {
  [ -f "/home/$user/.config/mpd" ] && touch /home/$user/.config/mpd/{database,mpdstate}

  # TODO: add more gsettings
  if command -v gsettings &> /dev/null; then
     gsettings set org.gnome.nautilus.preferences show-hidden-files true
  fi
}

setup_cloud() {
  # TODO: add more setup and init sync
  if command -v grive &> /dev/null; then
    systemctl --user enable grive@$(systemd-escape Cloud).service
    systemctl --user start grive@$(systemd-escape Cloud).service
  fi
}

setup_dotfiles_settings() {
  setup_program_settings
  setup_cloud
}