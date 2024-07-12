#!/usr/bin/env bash

declare -x OS
OS="$(uname -s)"

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

case "$OS" in
  Linux)
    # TODO: preinstall keepassxc addon (and maybe more essential addons) to the firefox
    # TODO: setup email

    declare -x DI_USER="${DI_USER:-jakub}" 
    declare -x DI_PKG_TYPE="${DI_PKG_TYPE:-secondary}"
    declare -xr DI_FIREFOX_BROWSER="firefox-developer-edition"

    declare -xr HOME="/home/$DI_USER" # needed if you run script as root

    source "$BASEDIR/shared/install.sh"
    source "$BASEDIR/arch/install.sh"
    ;;
  Darwin)
    # TODO: brew install koekeishiya/formulae/skhd; brew services start skhd
    # TODO: save it somewhere https://www.chrisatmachine.com/posts/01-macos-developer-setup
    # TODO: execute this command after installing packages: xattr -d com.apple.quarantine /Applications/Chromium.app
    declare -x DI_USER="${DI_USER:-jakubreron}"
    declare -x DI_PKG_TYPE="${DI_PKG_TYPE:-work}"
    declare -xr DI_FIREFOX_BROWSER="firefox"

    source "$BASEDIR/shared/install.sh"
    # source "$BASEDIR/macos/install.sh"
    ;;
  *)
    echo "OS $OS is not currently supported."
    exit 1
    ;;
esac
