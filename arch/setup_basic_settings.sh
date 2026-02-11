#!/usr/bin/env bash

setup_core_settings() {
  log_progress "Setting up core settings"

  sudo usermod -aG wheel "$USER" # sudo
  sudo usermod -aG video "$USER" # backlight

  # show  C o o o, instead of #### in progress
  grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

  # Enable multilib
  sudo sed -i '/^# \[multilib\]$/,/^# Include = \/etc\/pacman\.d\/mirrorlist$/s/^# //' /etc/pacman.conf

  sudo sed -Ei "s/^#(ParallelDownloads).*/\1 = 15/;/^#Color$/s/#//" /etc/pacman.conf

  # Allow wheel users to sudo with password and allow several system commands
  # (like `shutdown` to run without password).
  echo "%wheel ALL=(ALL:ALL) ALL" | sudo tee /etc/sudoers.d/00-wheel-can-sudo
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman -Syu,/usr/bin/pacman -Syyu,/usr/bin/pacman -Syyu --noconfirm,/usr/bin/loadkeys,/usr/bin/pacman -Syyuw --noconfirm,/usr/bin/pacman -S -u -y --config /etc/pacman.conf --,/usr/bin/pacman -S -y -u --config /etc/pacman.conf --" | sudo tee /etc/sudoers.d/01-cmds-without-password
  echo "Defaults editor=/usr/bin/nvim" | sudo tee /etc/sudoers.d/02-visudo-editor
  echo "Defaults timestamp_timeout=1440" | sudo tee /etc/sudoers.d/03-sudo-timeout

  sudo mkdir -p /etc/sysctl.d
  echo "kernel.dmesg_restrict = 0" | sudo tee /etc/sysctl.d/dmesg.conf
  echo "export \$(dbus-launch)" | sudo tee /etc/profile.d/dbus.sh
}

setup_grub() {
  if [ -f /boot/grub/grub.cfg ]; then
    log_progress "[GRUB DETECTED] Setting up"

    local grub_path="/etc/default/grub"
    if ! grep -q "GRUB_FORCE_HIDDEN_MENU=\"true\"" "$grub_path" || ! grep -q "GRUB_HIDDEN_TIMEOUT=\"0\"" "$grub_path"; then
      echo '
  GRUB_FORCE_HIDDEN_MENU="true"
  GRUB_HIDDEN_TIMEOUT="0"
    ' | sudo tee -a "$grub_path" >/dev/null
    fi

    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 iomem=relaxed intel_pstate=disable"/' "$grub_path"
    sudo sed -i 's/^GRUB_TIMEOUT=5$/GRUB_TIMEOUT=0/' "$grub_path"
    sudo sed -i 's/^GRUB_TIMEOUT_STYLE=menu$/GRUB_TIMEOUT_STYLE=hidden/' "$grub_path"

    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi
}

setup_bluetooth() {
  if ! command -v bluetoothctl >/dev/null 2>&1; then
    log_progress "Installing bluez-utils"
    install_pkg bluez-utils
  fi

  if command -v bluetoothctl >/dev/null 2>&1; then
    log_progress "Setting up the bluetooth"

    sudo sed -i 's/^AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf
    sudo systemctl enable bluetooth.service --now
  fi
}

setup_sddm() {
  if ! command -v sddm >/dev/null 2>&1; then
    log_progress "Installing sddm"
    install_pkg sddm
  fi

  if command -v sddm >/dev/null 2>&1; then
    sudo cp -r /home/jakub/.config/dotfiles/voidrice/.local/share/sddm/themes/catppuccin/src/* /usr/share/sddm/themes

    sudo groupadd autologin
    sudo usermod -aG autologin "$USER"

    sudo groupadd -r nopasswdlogin
    sudo gpasswd -a "$USER" nopasswdlogin

    sudo mkdir /etc/sddm.conf.d/

    # NOTE: create autologin
    # ----------------------
    echo "[Autologin]
User=$USER
Session=hyprland

[Theme]
Current=/usr/share/sddm/themes/catppuccin-mocha" | sudo tee /etc/sddm.conf.d/autologin.conf
  fi

  # NOTE: add permissions for login without password
  echo "auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin
auth        include     system-login" | sudo tee /etc/pam.d/sddm

  # NOTE: make sure everything is wayland compatible
  echo "[General]
DisplayServer=wayland" | sudo tee /etc/sddm.conf.d/10-wayland.conf
}

setup_fingerprint() {
  if ! command -v fprintd-enroll  >/dev/null 2>&1; then
    log_progress "Installing fprintd"
    install_pkg fprintd
  fi

  sudo fprintd-enroll
  sudo fprintd-enroll -f left-index-finger jakub
}

setup_core_settings
setup_grub
setup_bluetooth
setup_sddm
setup_fingerprint 
