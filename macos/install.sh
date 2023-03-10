#!/bin/sh

. ../shared/variables.sh
. ../shared/setup/basics.sh

user="jakubreron"

pkgtype="work"
pkg_manager_helper="brew"

. ./helpers.sh

. ./setup/basics.sh
. ./setup/packages/pkg-manager.sh
. ./setup/packages/custom.sh
. ./setup/settings.sh

# setup_basics
# setup_pkgmanager_packages
# setup_custom_packages
# setup_settings
