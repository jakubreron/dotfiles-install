#!/usr/bin/env bash

# NOTE: basic settings that do not require any previous setup
source "$BASEDIR/arch/basic_settings.sh"

# NOTE: AUR, custom, and compiled packages installation process
source "$BASEDIR/arch/packages/installation/index.sh"

# NOTE: all packages settings
source "$BASEDIR/arch/packages/settings/index.sh"
