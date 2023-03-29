#!/bin/sh

# TODO: preinstall keepassxc addon (and maybe more essential addons) to the firefox
# TODO: install xorg drivers
# TODO: enable multilib in pacman
# TODO: setup email

user="jakub" 

pkgtype="secondary"
pkg_manager_helper="paru"
browser="firefox-developer-edition"

. ../shared/index.sh

for package in curl ca-certificates base-devel ntp laptop-detect reflector rsync; do
  install_pkg "$package"
done

. ./setup/index.sh
