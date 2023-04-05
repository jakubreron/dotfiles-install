#!/usr/bin/env bash

# TODO: setup SDDM/autologin https://youtu.be/wNL6eIoksd8?t=482

setup_user() {
  log_progress "Preparing the user permissions"
  sudo usermod -a -G wheel "$DI_USER" && mkdir -p "/home/$user" && sudo chown "$DI_USER":wheel /home/"$DI_USER"
}

setup_core_settings() {
  log_progress "Setting up core settings"
  # Make pacman colorful, concurrent downloads and Pacman eye-candy.
  grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
  sudo sed -Ei "s/^#(ParallelDownloads).*/\1 = 15/;/^#Color$/s/#//" /etc/pacman.conf

  # Use all cores for compilation.
  sudo sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

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
  log_progress "Setting up grub"
  grub_path="/etc/default/grub"
  if ! grep -q "GRUB_FORCE_HIDDEN_MENU=\"true\"" "$grub_path" || ! grep -q "GRUB_HIDDEN_TIMEOUT=\"0\"" "$grub_path"; then
    echo '
GRUB_FORCE_HIDDEN_MENU="true"
GRUB_HIDDEN_TIMEOUT="0"
  ' | sudo tee -a "$grub_path" >/dev/null
  fi

  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"/' "$grub_path"

  sudo grub-mkconfig -o /boot/grub/grub.cfg
}

setup_touchpad() {
  if laptop-detect >/dev/null 2>&1; then
    log_progress "Laptop detected, setting up the touchpad"
    printf 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
	Option "Tapping" "on"
  Option "NaturalScrolling" "true"
EndSection' | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf
  else
    log_progress "No laptop detected, skipping the touchpad settings"
  fi
}

setup_bluetooth() {
  log_progress "Setting up the bluetooth"
  # sudo sed -i 's/^#AutoEnable=true/AutoEnable=true/g' /etc/bluetooth/main.conf
  sudo systemctl enable bluetooth.service --now
}

setup_user
setup_core_settings
setup_grub
setup_touchpad
setup_bluetooth
