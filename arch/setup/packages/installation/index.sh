#!/usr/bin/env bash

# NOTE: packages installable with aur helper
. "$PWD/arch/setup/packages/installation/pkg-manager.sh"

# NOTE: packages not installable with aur helper
. "$PWD/arch/setup/packages/installation/custom.sh"

# NOTE: packages compiled from source
. "$PWD/arch/setup/packages/installation/compiled.sh"
