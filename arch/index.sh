#!/usr/bin/env bash

source "$BASEDIR/arch/setup_basic_settings.sh"

# NOTE: packages installable with aur helper
source "$BASEDIR/arch/install_pkg_manager_pkgs.sh"

# NOTE: packages not installable with aur helper
source "$BASEDIR/arch/install_custom_pkgs.sh"

# NOTE: all other packages settings
source "$BASEDIR/arch/setup_other_pkgs.sh"

# NOTE: gnome app settings
source "$BASEDIR/arch/setup_gnome_pkgs.sh"
