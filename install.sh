#!/usr/bin/env bash
set -eo pipefail

declare -x OS
OS="$(uname -s)"

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

case "$OS" in
  Linux)
    # TODO: preinstall keepassxc addon (and maybe more essential addons) to the firefox
    # TODO: setup email

    declare -x DI_USER="${DI_USER:-"jakub"}" 
    declare -x DI_PKG_TYPE="${DI_PKG_TYPE:-"secondary"}"
    declare -x DI_PKG_MANAGER_HELPER="${DI_PKG_MANAGER_HELPER:-"paru"}"
    declare -xr DI_BROWSER="firefox-developer-edition"

    source "$BASEDIR/shared/index.sh"

    for package in curl ca-certificates base-devel ntp laptop-detect reflector rsync; do
      install_pkg "$package"
    done

    . "$BASEDIR/arch/index.sh"
    ;;
  Darwin)
    # TODO: brew install koekeishiya/formulae/skhd; brew services start skhd
    # TODO: save it somewhere https://www.chrisatmachine.com/posts/01-macos-developer-setup
    # TODO: execute this command after installing packages: xattr -d com.apple.quarantine /Applications/Chromium.app
    export DI_USER="jakubreron"
    export DI_PKG_TYPE="work"
    export DI_PKG_MANAGER_HELPER="brew"

    source "$BASEDIR/shared/index.sh"

    source "$BASEDIR/macos/index.sh"
    ;;
  *)
    echo "OS $OS is not currently supported."
    exit 1
    ;;
esac

