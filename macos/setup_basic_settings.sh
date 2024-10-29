setup_settings () {
  [ -f "$DI_MACOS_DIR/macos.sh" ] && "$DI_MACOS_DIR"/macos.sh
}

setup_quarantine () {
  xattr -d com.apple.quarantine /Applications/Chromium.app
}

setup_settings
setup_quarantine
