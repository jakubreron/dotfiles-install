#!/usr/bin/env bash

source "$BASEDIR/arch/setup_basic_settings.sh"

# NOTE: packages installable with aur helper
source "$BASEDIR/arch/install-pkg-manager-pkgs.sh"

# NOTE: packages not installable with aur helper
source "$BASEDIR/arch/install-custom-pkgs.sh"

# NOTE: all other packages settings
source "$BASEDIR/arch/setup-other-pkgs.sh"

# NOTE: gnome app settings
source "$BASEDIR/arch/setup-gnome-pkgs.sh"
