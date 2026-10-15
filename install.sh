#!/usr/bin/env bash

# TODO: @Jakub add https://linuxblog.io/upgrade-thinkpad-firmware-linux-fwupd/
# updates for bios, etc... (systemctl)

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

source "$BASEDIR/variables.sh"

export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf"
export GIT_CONFIG_VALUE_0="git@github.com:"
export GIT_CONFIG_KEY_1="url.https://github.com/.insteadOf"
export GIT_CONFIG_VALUE_1="ssh://git@github.com/"

mkdir -p "$DI_LOG_DIR"
declare -x DI_LOG_FILE
DI_LOG_FILE="$DI_LOG_DIR/install-$(date +%F-%H%M%S).log"
exec > >(tee -a "$DI_LOG_FILE") 2>&1
echo "Logging to $DI_LOG_FILE"

source "$BASEDIR/helpers.sh"

if [[ "$EUID" -eq 0 ]]; then
  log_error "This script should not be run as root. Exiting."
  exit 1
fi

source "$BASEDIR/before_install.sh"

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
