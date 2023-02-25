#!/bin/sh

# TODO: setup SDDM/autologin https://youtu.be/wNL6eIoksd8?t=482

setup_program_settings() {
  touch /home/$user/.config/mpd/{database,mpdstate} || return 1

  gsettings set org.gnome.nautilus.preferences show-hidden-files true
}

setup_cloud() {
  systemctl --user enable grive@$(systemd-escape Cloud).service
  systemctl --user start grive@$(systemd-escape Cloud).service
}

setup_dotfiles_settings() {
  setup_program_settings
  setup_cloud
}
