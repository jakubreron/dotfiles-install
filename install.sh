#!/usr/bin/env bash

declare -x OS
OS="$(uname -s)"

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

case "$OS" in
  Linux)
    # TODO: preinstall keepassxc addon (and maybe more essential addons) to the firefox
    # TODO: setup email
    # TODO: investigate https://askubuntu.com/questions/463640/ubuntu-sensors-how-to-decrease-temperatures-threshold
    # and maybe setup
    # /etc/sensors.d/isa-coretemp
    # chip "coretemp-isa-0000"
    #    label temp1 "Package id 0"
    #    compute temp1 @-15,@-2 
    # 
    #    label temp2 "Core 0"
    #    compute temp2 @-15,@-2 
    # 
    #    label temp3 "Core 1"
    #    compute temp3 @-15,@-2
    #    
    #    label temp4 "Core 2"
    #    compute temp4 @-15,@-2
    # 
    #    label temp5 "Core 3"
    #    compute temp5 @-15,@-2

    declare -x DI_USER="${DI_USER:-jakub}" 
    declare -x DI_PKG_TYPE="${DI_PKG_TYPE:-secondary}"
    declare -xr DI_BROWSER="firefox-developer-edition"

    declare -xr HOME="/home/$DI_USER" # needed if you run script as root

    source "$BASEDIR/shared/index.sh"
    source "$BASEDIR/arch/index.sh"
    ;;
  Darwin)
    # TODO: brew install koekeishiya/formulae/skhd; brew services start skhd
    # TODO: save it somewhere https://www.chrisatmachine.com/posts/01-macos-developer-setup
    # TODO: execute this command after installing packages: xattr -d com.apple.quarantine /Applications/Chromium.app
    declare -x DI_USER="${DI_USER:-jakubreron}"
    declare -x DI_PKG_TYPE="${DI_PKG_TYPE:-work}"
    declare -xr DI_BROWSER="firefox"

    source "$BASEDIR/shared/index.sh"
    # source "$BASEDIR/macos/index.sh"
    ;;
  *)
    echo "OS $OS is not currently supported."
    exit 1
    ;;
esac
