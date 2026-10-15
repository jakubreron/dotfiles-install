#!/usr/bin/env bash

if [ -f "$DI_SCRIPT_STATE_DIR/.macos-script-completed" ]; then
  log_status "Dev settings already set up, skipping"
else
  log_progress "Setting up dev settings"

  log_progress "Disabling saving new documents to iCloud"
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  
  log_progress "Disabling press-and-hold for keys"
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false # Disable press-and-hold for keys in favor of key repeat

  log_progress "Setting a fast keyboard repeat rate"
  defaults write NSGlobalDomain KeyRepeat -int 1 # Set a fast keyboard repeat rate
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  log_progress "Showing hidden files, all extensions and the path bar in Finder"
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowPathbar -bool true

  log_progress "Setting up the Dock (fixed Spaces, autohide, no default apps)"
  defaults write com.apple.dock mru-spaces -bool false # Don’t automatically rearrange Spaces based on most recent use

  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock persistent-apps -array # Remove all default apps from Dock
  log_progress "Restarting the Dock"
  killall Dock

  log_progress "Setting the hot corners"
  defaults write com.apple.dock wvous-tl-corner -int 2 # Top left screen corner → Mission Control (2)
  defaults write com.apple.dock wvous-tl-modifier -int 0 # No modifier (0)
  defaults write com.apple.dock wvous-tr-corner -int 12 # Top right screen corner → Notification Center (12)
  defaults write com.apple.dock wvous-tr-modifier -int 0 # No modifier (0)

  log_progress "Marking the macOS settings as completed"
  mkdir -p $DI_SCRIPT_STATE_DIR
  touch $DI_SCRIPT_STATE_DIR/.macos-script-completed
fi
