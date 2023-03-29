update_system() {
  log_pretty_message "Updating software packages via softwareupdate"
  softwareupdate -i -a
}

update_system
