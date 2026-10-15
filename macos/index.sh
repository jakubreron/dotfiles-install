#!/usr/bin/env bash

log_progress "Running macos/install_pkg_manager_pkgs.sh"
source "$BASEDIR/macos/install_pkg_manager_pkgs.sh"

log_progress "Running macos/setup_basic_settings.sh"
source "$BASEDIR/macos/setup_basic_settings.sh"

log_progress "Running macos/setup_apps.sh"
source "$BASEDIR/macos/setup_apps.sh"

log_progress "Running macos/setup_cron.sh"
source "$BASEDIR/macos/setup_cron.sh"

log_progress "Running macos/setup_gpg.sh"
source "$BASEDIR/macos/setup_gpg.sh"
