#!/usr/bin/env bash

source "$BASEDIR/macos/install_pkg_manager_pkgs.sh"

source "$BASEDIR/macos/setup_basic_settings.sh"

source "$BASEDIR/macos/setup_apps.sh"

# NOTE: Touch ID for sudo, also inside tmux
source "$BASEDIR/macos/setup_touch_id_sudo.sh"

source "$BASEDIR/macos/setup_cron.sh"

source "$BASEDIR/macos/setup_gpg.sh"
