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
    declare -xr DI_BROWSER="firefox-developer-edition"

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
