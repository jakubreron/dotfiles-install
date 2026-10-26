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

dock_changed=false # Tracks whether a Dock setting changed, so the Dock restarts only when needed
if set_default com.apple.dock autohide-time-modifier -float 0.15; then dock_changed=true; fi # Faster autohide slide animation, the default is 0.5 seconds
if set_default com.apple.dock show-recents -bool false; then dock_changed=true; fi # Hide the recent applications section of the Dock

if $dock_changed; then # Only restart the Dock when a setting above changed
  log_progress "Restarting the Dock" # Explain why the Dock flashes
  killall Dock # The Dock reads its settings only when it starts
fi

set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false || true # Keep straight quotes instead of smart quotes, safe for pasted code
set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false || true # Keep "--" as typed instead of turning it into a dash
set_default NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false || true # Do not insert a period after a double space
set_default NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false || true # Do not capitalize the first letter automatically
set_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false || true # Turn off spelling autocorrect

set_default NSGlobalDomain NSWindowResizeTime -float 0.001 || true # Make native app windows resize almost instantly instead of animating

finder_changed=false # Tracks whether a Finder setting changed, so Finder restarts only when needed
if set_default com.apple.finder FXPreferredViewStyle -string Nlsv; then finder_changed=true; fi # Open folders without their own view setting in list view (Nlsv)
if set_default com.apple.finder _FXSortFoldersFirst -bool true; then finder_changed=true; fi # Keep folders above files when sorting by name
if set_default com.apple.finder FXDefaultSearchScope -string SCcf; then finder_changed=true; fi # Search the current folder first instead of the whole Mac (SCcf)
if set_default com.apple.finder FXEnableExtensionChangeWarning -bool false; then finder_changed=true; fi # Do not ask for confirmation when changing a file extension

if $finder_changed; then # Only restart Finder when a setting above changed
  log_progress "Restarting Finder" # Explain why Finder windows close
  killall Finder # Finder reads its settings only when it starts
fi

set_default com.apple.desktopservices DSDontWriteNetworkStores -bool true || true # Do not create .DS_Store files on network shares, takes effect after the next login

screenshots_changed=false # Tracks whether the screenshot setting changed, so SystemUIServer restarts only when needed
mkdir -p "$SCREENSHOTS_DIR" # The folder must exist before macOS can save screenshots into it
if set_default com.apple.screencapture location -string "$SCREENSHOTS_DIR"; then screenshots_changed=true; fi # Save screenshots to the same folder as on Linux instead of the Desktop

if $screenshots_changed; then # Only restart SystemUIServer when the setting above changed
  log_progress "Restarting SystemUIServer" # Explain why the menu bar flashes
  killall SystemUIServer # It reads the screenshot location only when it starts
fi

set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true || true # Open the Save dialog with the full folder browser
set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true || true # Companion key set together with the one above, as common macOS defaults scripts do
set_default NSGlobalDomain PMPrintingExpandedStateForPrint -bool true || true # Open the Print dialog with all its options
set_default NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true || true # Companion key set together with the one above, as common macOS defaults scripts do
