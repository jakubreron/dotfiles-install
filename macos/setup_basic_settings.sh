setup_tiling_manager() {
  if ! command -v yabai >/dev/null 2>&1; then
    log_progress "Installing tiling manager (yabai)"
    install_pkg koekeishiya/formulae/yabai
  fi

  yabai --install-service
  yabai --start-service
}

setup_borders() {
  if ! command -v yabai >/dev/null 2>&1; then
    log_progress "Installing borders"
    install_pkg felixkratz/formulae/borders
  fi

  brew services start borders
}

remove_quarantine() {
  xattr -d com.apple.quarantine /Applications/{Chromium.app,Alacritty.app}
}

run_macos_scripts() {
  if [ -f "$DI_SCRIPT_STATE_DIR/.macos-script-completed" ]; then
    log_status "macos.sh already ran, skipping..."
  else
    [ -f "$DI_MACOS_DIR/macos.sh" ] && $DI_MACOS_DIR/macos.sh
    mkdir -p $DI_SCRIPT_STATE_DIR
    touch $DI_SCRIPT_STATE_DIR/.macos-script-completed
  fi
}

run_apps() {
  open -a "Scroll Reverser"
  open -a "karabiner-Elements"
}

setup_tiling_manager 
setup_borders
remove_quarantine
run_macos_scripts
run_apps
