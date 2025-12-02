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
  log_status "Dev settings already set up, skipping"
else
  log_progress "Setting up dev settings"
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false # Disable press-and-hold for keys in favor of key repeat

  defaults write NSGlobalDomain KeyRepeat -int 1 # Set a fast keyboard repeat rate
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowPathbar -bool true

  defaults write com.apple.dock mru-spaces -bool false # Don’t automatically rearrange Spaces based on most recent use

  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock persistent-apps -array # Remove all default apps from Dock
  killall Dock

  defaults write com.apple.dock wvous-tl-corner -int 2 # Top left screen corner → Mission Control (2)
  defaults write com.apple.dock wvous-tl-modifier -int 0 # No modifier (0)
  defaults write com.apple.dock wvous-tr-corner -int 12 # Top right screen corner → Notification Center (12)
  defaults write com.apple.dock wvous-tr-modifier -int 0 # No modifier (0)

  mkdir -p $DI_SCRIPT_STATE_DIR
  touch $DI_SCRIPT_STATE_DIR/.macos-script-completed
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
