#!/usr/bin/env bash

if ! command -v yabai >/dev/null 2>&1; then
  log_progress "Installing tiling manager (yabai)"
  install_pkg koekeishiya/formulae/yabai
else
  log_status "yabai is already installed"
fi
if command -v yabai >/dev/null 2>&1; then
  yabai_service_file="$HOME/Library/LaunchAgents/com.asmvik.yabai.plist"
  if [[ -f "$yabai_service_file" ]]; then
    log_status "yabai service is already installed"
  else
    log_progress "Installing the yabai service"
    yabai --install-service
  fi
  log_progress "Starting the yabai service"
  yabai --start-service
fi

if ! command -v borders >/dev/null 2>&1; then
  log_progress "Installing borders"
  install_pkg felixkratz/formulae/borders
else
  log_status "borders is already installed"
fi
if  command -v borders >/dev/null 2>&1; then
  log_progress "Starting borders brew service"
  brew services start borders
fi

if ! command -v colima >/dev/null 2>&1; then
  log_progress "Installing colima"
  install_pkg "colima"
else
  log_status "colima is already installed"
fi
if command -v colima >/dev/null 2>&1; then
  log_progress "Starting colima"
  colima start
fi

log_progress "Opening apps that require setup"
open_app_if_not_running() {
  local app_name="$1"

  if ! pgrep -f "$app_name" >/dev/null 2>&1; then
    if open -a "$app_name"; then
      log_status "Opened '$app_name'."
    else
      log_error "Failed to open '$app_name'. It might not be installed."
    fi
  else
    log_status "'$app_name' is already running, skipping."
  fi
}

open_app_if_not_running "Scroll Reverser"
open_app_if_not_running "Karabiner-Elements"
