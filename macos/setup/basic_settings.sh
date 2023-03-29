update_system() {
  log_pretty_message "Updating software packages"
  softwareupdate -i -a
}

setup_core_settings() {
  log_pretty_message "Setting up core settings"
}

update_system
setup_core_settings
