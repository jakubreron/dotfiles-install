#!/bin/sh

# TODO: add brew install
# TODO: install findutils, node, yarn, fnm, exa, mcfly, aunpack, atool, fzf, gettext
# TODO: after cloning pkglists, do cat brew.txt | xargs brew install
# TODO: brew install koekeishiya/formulae/skhd; brew services start skhd

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
