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
# TODO: fix packages with choices (like darkman, adw-gtk3, grive)

. ../shared/variables.sh

user="jakub" 

pkgtype="secondary"
pkg_manager_helper="paru"

. ./helpers.sh
. ./setup/basics.sh

. ./setup/packages/dotfiles_packages.sh
. ./setup/packages/custom_packages.sh

. ./setup/settings/dotfiles_settings.sh
. ./setup/settings/custom_settings.sh

setup_basics

setup_dotfiles_packages
setup_custom_packages

setup_dotfiles_settings
setup_custom_settings
