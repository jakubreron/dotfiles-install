#!/bin/sh

user="jakub" # TODO  prompt for user
dotfiles_dir="/home/$user/.config/personal"
dotfiles_repo="https://github.com/jakubreron/voidrice.git"
pkglists_repo="https://github.com/jakubreron/pkglists.git"
pkgtype="secondary" # TODO: prompt for "primary, secondary, work" pkgtypes

. ./helpers.sh
. ./setup/basics.sh

. ./setup/dotfiles_packages.sh
. ./setup/custom_packages.sh

. ./setup/dotfiles_settings.sh
. ./setup/custom_settings.sh

setup_basics

setup_dotfiles_packages
setup_custom_packages

# setup_dotfiles_settings
# setup_custom_settings
