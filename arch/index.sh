#!/usr/bin/env bash

# NOTE: pacman.conf and sudoers, must run before any package sync
log_progress "Running arch/setup_core_settings.sh"
source "$BASEDIR/arch/setup_core_settings.sh"

# NOTE: packages installable with aur helper
log_progress "Running arch/install_pkg_manager_pkgs.sh"
source "$BASEDIR/arch/install_pkg_manager_pkgs.sh"

# NOTE: grub, bluetooth, fingerprint (install packages, need the synced databases)
log_progress "Running arch/setup_basic_settings.sh"
source "$BASEDIR/arch/setup_basic_settings.sh"

# NOTE: packages not installable with aur helper
log_progress "Running arch/install_custom_pkgs.sh"
source "$BASEDIR/arch/install_custom_pkgs.sh"

# NOTE: all other packages settings
log_progress "Running arch/setup_other_pkgs.sh"
source "$BASEDIR/arch/setup_other_pkgs.sh"

# NOTE: gpg agent and signing key
log_progress "Running arch/setup_gpg.sh"
source "$BASEDIR/arch/setup_gpg.sh"

# NOTE: gnome app settings
log_progress "Running arch/setup_gnome_pkgs.sh"
source "$BASEDIR/arch/setup_gnome_pkgs.sh"
