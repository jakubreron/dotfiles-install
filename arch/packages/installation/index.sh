#!/usr/bin/env bash

# NOTE: packages installable with aur helper
source "$BASEDIR/arch/packages/installation/pkg-manager.sh"

# NOTE: packages not installable with aur helper
source "$BASEDIR/arch/packages/installation/custom.sh"

# NOTE: packages compiled from source
source "$BASEDIR/arch/packages/installation/compiled.sh"
