#!/usr/bin/env bash

if command -v gsettings >/dev/null 2>&1; then
  log_progress "Setting up GNOME settings via gsettings"
  gsettings set org.gnome.nautilus.preferences show-hidden-files true
else
  log_status "No gsettings detected, skipping GNOME settings"️
fi
