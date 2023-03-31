update_system() {
  log_progress "Updating software packages via softwareupdate"
  softwareupdate -i -a
}

update_system
