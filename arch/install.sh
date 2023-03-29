#!/bin/sh

# TODO: preinstall keepassxc addon (and maybe more essential addons) to the firefox
# TODO: install xorg drivers
# TODO: enable multilib in pacman
# TODO: setup email

export di_user="jakub" 
export di_pkg_type="secondary"
export di_pkg_manager_helper="paru"
export di_browser="firefox-developer-edition"

. "$PWD/shared/index.sh"

for package in curl ca-certificates base-devel ntp laptop-detect reflector rsync; do
  install_pkg "$package"
done

. "$PWD/arch/setup/index.sh"
