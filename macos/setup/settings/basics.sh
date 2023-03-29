update_system() {
  log-pretty-message "Updating software packages"
  softwareupdate -i -a
}

setup_core_settings() {
  log-pretty-message "Setting up core settings"
}

update_system
setup_core_settings
