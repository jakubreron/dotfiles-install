#!/usr/bin/env bash

# NOTE: basic settings that do not require any previous setup
source "$BASEDIR/macos/basic_settings.sh"

# NOTE: brew, custom, and compiled packages installation process
source "$BASEDIR/macos/packages/installation/index.sh"

# NOTE: all packages settings
source "$BASEDIR/macos/packages/settings/index.sh"
