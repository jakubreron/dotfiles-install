if command -v gsettings >/dev/null 2>&1; then
  log_pretty_message "Setting up GNOME settings via gsettings" 
  gsettings set org.gnome.nautilus.preferences show-hidden-files true
else
  log_pretty_message "No gsettings detected, skipping GNOME settings" ℹ️
fi
