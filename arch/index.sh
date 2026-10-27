#!/usr/bin/env bash

# NOTE: pacman.conf and sudoers, must run before any package sync
source "$BASEDIR/arch/setup_core_settings.sh"

# NOTE: packages installable with aur helper
source "$BASEDIR/arch/install_pkg_manager_pkgs.sh"

# NOTE: grub, bluetooth, fingerprint (install packages, need the synced databases)
source "$BASEDIR/arch/setup_basic_settings.sh"

# NOTE: packages not installable with aur helper
source "$BASEDIR/arch/install_custom_pkgs.sh"

# NOTE: all other packages settings
source "$BASEDIR/arch/setup_other_pkgs.sh"

# NOTE: gpg agent and signing key
source "$BASEDIR/arch/setup_gpg.sh"

# NOTE: unlock the login keyring when logging in on a tty, git credentials need it
source "$BASEDIR/arch/setup_login_keyring.sh"

# NOTE: fingerprint for login, sudo and polkit (needs fprintd from setup_basic_settings.sh)
source "$BASEDIR/arch/setup_fingerprint_pam.sh"

# NOTE: gnome app settings
source "$BASEDIR/arch/setup_gnome_pkgs.sh"
