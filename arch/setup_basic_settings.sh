#!/usr/bin/env bash

setup_grub() {
  if [ -f /boot/grub/grub.cfg ]; then
    log_progress "[GRUB DETECTED] Setting up"

    local grub_path="/etc/default/grub"
    if ! grep -q "GRUB_FORCE_HIDDEN_MENU=\"true\"" "$grub_path" || ! grep -q "GRUB_HIDDEN_TIMEOUT=\"0\"" "$grub_path"; then
      log_progress "Adding the hidden menu options to $grub_path"
      echo '
  GRUB_FORCE_HIDDEN_MENU="true"
  GRUB_HIDDEN_TIMEOUT="0"
    ' | sudo tee -a "$grub_path" >/dev/null
    fi

    log_progress "Updating the grub kernel parameters and timeouts"
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 iomem=relaxed intel_pstate=disable"/' "$grub_path"
    sudo sed -i 's/^GRUB_TIMEOUT=5$/GRUB_TIMEOUT=0/' "$grub_path"
    sudo sed -i 's/^GRUB_TIMEOUT_STYLE=menu$/GRUB_TIMEOUT_STYLE=hidden/' "$grub_path"

    log_progress "Regenerating the grub config"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  else
    log_status "GRUB not detected, skipping"
  fi
}

setup_bluetooth() {
  if ! command -v bluetoothctl >/dev/null 2>&1 || ! pacman -Q bluez >/dev/null 2>&1; then
    log_progress "Installing bluez and bluez-utils"
    install_pkg bluez bluez-utils
  else
    log_status "bluez and bluez-utils are already installed"
  fi

  if command -v bluetoothctl >/dev/null 2>&1 && pacman -Q bluez >/dev/null 2>&1; then
    log_progress "Setting up the bluetooth"

    sudo sed -i 's/^AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf
    sudo systemctl enable bluetooth.service --now
  fi
}

setup_fingerprint() {
  if ! command -v fprintd-enroll  >/dev/null 2>&1; then
    log_progress "Installing fprintd"
    install_pkg fprintd
  else
    log_status "fprintd is already installed"
  fi

  if command -v fprintd-enroll >/dev/null 2>&1; then
    if fprintd-list "$USER" 2>/dev/null | grep -q '#[0-9]'; then
      log_status "Fingerprint already enrolled, skipping"
    else
      log_progress "Enrolling your fingerprints, follow the prompts"
      fprintd-enroll
      fprintd-enroll -f left-index-finger
    fi
  fi
}

setup_grub
setup_bluetooth
setup_fingerprint 
