#!/bin/sh
# TODO: check if ~/.config/pacman/pacman.conf works, if not, link it to /etc something
# TODO: same for paru
# TODO: install zap https://www.zapzsh.org/

dotfiles_dir="$HOME/.config/personal/testing"
dotfiles_repo="https://github.com/jakubreron/voidrice.git"
pkglists_repo="https://github.com/jakubreron/pkglists.git"
# aurhelper="paru"

install_dirs() {
  mkdir $HOME/{Documents,Downloads,Music,Pictures,Videos,Cloud,Storage}
  mkdir -p $HOME/.local/{bin,share,src}
  mkdir -p "$dotfiles_dir"
}

install_repos() {
  git clone "$dotfiles_repo" "$dotfiles_dir" || return 1
  git clone "$pkglists_repo" "$dotfiles_dir" || return 1
}

install_cache_management() {
  sudo journalctl --vacuum-time=4weeks 

  echo '[Unit]
  Description=Clean-up old pacman pkg

  [Timer]
  OnCalendar=monthly
  Persistent=true

  [Install]
  WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/paccache.timer

  echo '[Trigger]
  Operation = Upgrade
  Operation = Install
  Operation = Remove
  Type = Package
  Target = *

  [Action]
  Description = Cleaning pacman cache with paccache …
  When = PostTransaction
  Exec = /usr/bin/paccache -r' | sudo tee -a /usr/share/libalpm/hooks/paccache.hook
}

# TODO; install https://github.com/AdnanHodzic/auto-cpufreq#auto-cpufreq-installer
# TODO: and setup https://github.com/AdnanHodzic/auto-cpufreq#auto-cpufreq-modes-and-options
# install_auto_cpufreq() {
#   git clone https://github.com/AdnanHodzic/auto-cpufreq.git
#   cd auto-cpufreq && sudo ./auto-cpufreq-installer
#   sudo auto-cpufreq --install
# }

install_keyd() {
  path="$HOME/Downloads/keyd"
  git clone https://github.com/rvaiya/keyd "$path" || return 1
  cd "$path" || return 1
  make && sudo make install
  sudo systemctl enable keyd && sudo systemctl start keyd
  rm -rf "$path"
  
  global_config_path="/etc/keyd/defaulf.conf"
  echo "[ids]

*

[main]

shift = oneshot(shift)
meta = oneshot(meta)
control = oneshot(control)

leftalt = oneshot(alt)
rightalt = oneshot(altgr)

capslock = overload(meta, esc)
insert = S-insert" | sudo tee "$global_config_path"
}

setup_basics() {
  timedatectl set-ntp on # network time sync
}

  # TODO: do it automatically
# `sudoedit /etc/bluetooth/main.conf`
# ```sh
#   [Policy]
#   AutoEnable=true

#   [General]
#   # DiscoverableTimeout = 0
# ```
setup_bluetooth() {
  sudo systemctl enable bluetooth.service --now
}

# TODO: do it after all the preparations and stows
setup_programs() {
  touch $HOME/.config/mpd/{database,mpdstate} || return 1
}

# TODO; install these programs from the file first
setup_cloud() {
  systemctl --user enable grive@$(systemd-escape Cloud).service
  systemctl --user start grive@$(systemd-escape Cloud).service
}

setup_gsettings() {
  gsettings set org.gnome.nautilus.preferences show-hidden-files true
}

# install_dirs
# install_repos
# install_cache_management

[ -x "$(command -v "keyd")" ] || install_keyd

# setup_basics
# setup_bluetooth
# setup_programs
# setup_cloud
# setup_gsettings
