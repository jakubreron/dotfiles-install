#!/bin/sh

. ./helpers.sh

# TODO: provide options for "primary, secondary, work" pkgtypes
# TODO: base more things on this: https://github.com/linuxmobile/hyprland-dots
# TODO: base more things on this: https://github.com/ChrisTitusTech/hyprland-titus
# TODO: setup SDDM/autologin https://youtu.be/wNL6eIoksd8?t=482

user="jakub"
dotfiles_dir="/home/$user/.config/personal"
dotfiles_repo="https://github.com/jakubreron/voidrice.git"
pkglists_repo="https://github.com/jakubreron/pkglists.git"
pkgtype="secondary"

setup_basics() {
  pacman --noconfirm --needed -Sy libnewt

  for x in curl ca-certificates base-devel git ntp zsh; do
    install_pkg "$x"
  done

  # Make pacman colorful, concurrent downloads and Pacman eye-candy.
  grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
  sed -Ei "s/^#(ParallelDownloads).*/\1 = 15/;/^#Color$/s/#//" /etc/pacman.conf

  # Use all cores for compilation.
  sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

  # Allow wheel users to sudo with password and allow several system commands
  # (like `shutdown` to run without password).
  echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/00-larbs-wheel-can-sudo
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/pacman -Syyuw --noconfirm,/usr/bin/pacman -S -u -y --config /etc/pacman.conf --,/usr/bin/pacman -S -y -u --config /etc/pacman.conf --" >/etc/sudoers.d/01-larbs-cmds-without-password
  echo "Defaults editor=/usr/bin/nvim" >/etc/sudoers.d/02-larbs-visudo-editor
  mkdir -p /etc/sysctl.d
  echo "kernel.dmesg_restrict = 0" > /etc/sysctl.d/dmesg.conf
}


create_dirs() {
  mkdir /home/$user/{Documents,Downloads,Music,Pictures,Videos,Cloud,Storage}
  mkdir -p /home/$user/.local/{bin,share,src}
  mkdir -p "$dotfiles_dir"
}

clone_dotfiles_repos() {
  git clone "$dotfiles_repo" "$dotfiles_dir" || return 1
  git clone "$pkglists_repo" "$dotfiles_dir" || return 1
}

replace_stow() {
  stow --adopt --target="/home/$user" --dir="$dotfiles_dir" voidrice
}

install_aur_helper() {
  mkdir "/home/$user/Downloads/_cloned-repos"
  cd "/home/$user/Downloads/_cloned-repos" || exit
  git clone https://aur.archlinux.org/paru.git
  cd paru || exit
  makepkg -si  
}

install_pkglists() {
  paru --noconfirm --needed -S - < "$dotfiles_dir/pkglists/$pkgtype/pacman.txt";
}

# TODO: only on laptops
# TODO: install https://github.com/AdnanHodzic/auto-cpufreq#auto-cpufreq-installer
# TODO: and setup into /etc/auto-cpufreq.conf https://github.com/AdnanHodzic/auto-cpufreq#auto-cpufreq-modes-and-options (min freq on battery and so on)
# TODO: also this: https://github.com/intel/dptf or use "thermald"
# install_auto_cpufreq() {
#   git clone https://github.com/AdnanHodzic/auto-cpufreq.git
#   cd auto-cpufreq && sudo ./auto-cpufreq-installer
#   sudo auto-cpufreq --install
# }

install_zap() {
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
}

install_keyd() {
  path="/home/$user/Downloads/keyd"
  git clone https://github.com/rvaiya/keyd "$path" || return 1
  cd "$path" || return 1
  make && sudo make install
  sudo systemctl enable keyd && sudo systemctl start keyd
  rm -rf "$path"
  global_config_path="/etc/keyd/defaulf.conf"
  echo "[ids]

*

[main]

capslock = overload(meta, esc)

# Remaps the escape key to capslock
esc = capslock" | sudo tee "$global_config_path"
}

enable_cache_management() {
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

setup_bluetooth() {
  sudo sed -i 's/^#AutoEnable=true/AutoEnable=true/g' /etc/bluetooth/main.conf
  sudo systemctl enable bluetooth.service --now
}

setup_program_settings() {
  touch /home/$user/.config/mpd/{database,mpdstate} || return 1

  gsettings set org.gnome.nautilus.preferences show-hidden-files true
}

setup_cloud() {
  systemctl --user enable grive@$(systemd-escape Cloud).service
  systemctl --user start grive@$(systemd-escape Cloud).service
}

### THE ACTUAL SCRIPT ###

# basics
setup_basics
create_dirs
clone_dotfiles_repos
replace_stow

# packages
install_aur_helper
install_pkglists

# install custom packages
[ -x "$(command -v "zap")" ] || install_zap
[ -x "$(command -v "keyd")" ] || install_keyd

# setup settings
enable_cache_management
setup_bluetooth
# setup_program_settings
# setup_cloud
