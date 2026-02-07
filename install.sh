#!/usr/bin/env bash

# TODO: @Jakub add https://linuxblog.io/upgrade-thinkpad-firmware-linux-fwupd/
# updates for bios, etc... (systemctl)

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

if [[ "$EUID" -eq 0 ]]; then
  log_error "This script should not be run as root. Exiting."
  exit 1
fi

source "$BASEDIR/variables.sh"
source "$BASEDIR/helpers.sh"
source "$BASEDIR/before_install.sh"

if [[ ! -d "$DI_UNIVERSAL_DIR" ]]; then
  log_error "Clone universal repo into $DI_UNIVERSAL_DIR first"
  exit 1
fi

case "$OS" in
Linux)
  source "$BASEDIR/arch/index.sh"
  ;;
Darwin)
  source "$BASEDIR/macos/index.sh"
  ;;
*)
  echo "OS $OS is not currently supported."
  exit 1
  ;;
esac

source "$BASEDIR/after_install.sh"
