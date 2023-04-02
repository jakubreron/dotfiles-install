#!/usr/bin/env bash

# TODO: preinstall keepassxc addon (and maybe more essential addons) to the firefox
# TODO: install xorg drivers
# TODO: enable multilib in pacman
# TODO: setup email

declare -x DI_USER="${DI_USER:-"jakub"}" 
declare -x DI_PKG_TYPE="${DI_PKG_TYPE:-"secondary"}"
declare -x DI_PKG_MANAGER_HELPER="${DI_PKG_MANAGER_HELPER:-"paru"}"
declare -xr DI_BROWSER="firefox-developer-edition"

. "$PWD/shared/index.sh"

for package in curl ca-certificates base-devel ntp laptop-detect reflector rsync; do
  install_pkg "$package"
done

. "$PWD/arch/setup/index.sh"
