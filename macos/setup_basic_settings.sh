#!/usr/bin/env bash

if ! command -v yabai >/dev/null 2>&1; then
  log_progress "Installing tiling manager (yabai)"
  install_pkg koekeishiya/formulae/yabai
fi
log_progress "Starting yabai brew service"
yabai --install-service
yabai --start-service

if ! command -v borders >/dev/null 2>&1; then
  log_progress "Installing borders"
  install_pkg felixkratz/formulae/borders
fi
log_progress "Starting borders brew service"
brew services start borders

if [ -f "$DI_SCRIPT_STATE_DIR/.macos-script-completed" ]; then
  log_progress "macos.sh already ran, skipping..."
else
  log_progress "running macos.sh"
  [ -f "$DI_MACOS_DIR/macos.sh" ] && $DI_MACOS_DIR/macos.sh
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
