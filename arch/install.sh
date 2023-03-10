#!/bin/sh

# TODO: preinstall keepassxc addon (and maybe more essential addons) to the firefox
# TODO: clone src folders and compile them
# TODO: in src folders, switch to laptop branch if on laptop
# TODO: uncomment xorg packages in genpkg
# TODO: install xorg drivers
# TODO: create .local/bin/{cron,dmenu,etc...} folders first before stowing
# TODO: clone lunarvim config and replace the default one
# TODO: add darkman
# TODO: create more ~/Documents folders (like projects, torrents, etc)
# TODO: enable multilib in pacman
# TODO: setup email
# TODO: create Screenshots and Recordings folders

. ../shared/variables.sh
. ../shared/setup/basics.sh

user="jakub" 

pkgtype="secondary"
pkg_manager_helper="paru"

. ./helpers.sh

. ./setup/basics.sh
. ./setup/packages/pkg-manager.sh
. ./setup/packages/custom.sh
. ./setup/settings.sh

setup_basics
setup_pkgmanager_packages
setup_custom_packages
setup_settings
