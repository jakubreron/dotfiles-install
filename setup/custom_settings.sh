#!/bin/sh

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

setup_custom_settings() {
  enable_cache_management
  setup_bluetooth
}
