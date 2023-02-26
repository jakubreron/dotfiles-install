#!/bin/sh

user="jakub" 
aur_helper="paru"
npm_helper="yarn"

dotfiles_dir="/home/$user/.config/dotfiles"

voidrice_dir="$dotfiles_dir/voidrice"
voidrice_repo="https://github.com/jakubreron/voidrice.git"

pkglists_dir="$dotfiles_dir/pkglists"
pkglists_repo="https://github.com/jakubreron/pkglists.git"
pkgtype="secondary" # TODO: prompt for "primary, secondary, work" pkgtypes

git_clone_path="/home/$user/Downloads/git-clone"
mkdir -p "$git_clone_path"

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
