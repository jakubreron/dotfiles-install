if ! command -v yabai >/dev/null 2>&1; then
  log_progress "Installing tiling manager (yabai)"
  install_pkg koekeishiya/formulae/yabai
fi
log_progress "Starting yabai brew service"
yabai --install-service
yabai --start-service

if ! command -v yabai >/dev/null 2>&1; then
  log_progress "Installing borders"
  install_pkg felixkratz/formulae/borders
fi
log_progress "Starting borders brew service"
brew services start borders

log_status "Removing quarantine for common apps"
xattr -d com.apple.quarantine /Applications/{Chromium.app,Alacritty.app}

if [ -f "$DI_SCRIPT_STATE_DIR/.macos-script-completed" ]; then
  log_status "macos.sh already ran, skipping..."
else
  log_status "running macos.sh"
  [ -f "$DI_MACOS_DIR/macos.sh" ] && $DI_MACOS_DIR/macos.sh
fi

log_status "Opening apps that require setup"
open -a "Scroll Reverser"
open -a "karabiner-Elements"
