#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  echo "Run this script with bash, not sh" >&2
  exit 1
fi

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
  echo "Run this script with: bash install.sh (sourcing it would close your terminal on exit)" >&2
  return 1
fi

# TODO: @Jakub add https://linuxblog.io/upgrade-thinkpad-firmware-linux-fwupd/
# updates for bios, etc... (systemctl)

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

source "$BASEDIR/variables.sh"

mkdir -p "$DI_LOG_DIR"
declare -x DI_LOG_FILE
DI_LOG_FILE="$DI_LOG_DIR/install-$(date +%F-%H%M%S).log"
exec > >(tee -a "$DI_LOG_FILE") 2>&1

source "$BASEDIR/helpers.sh"

log_status "Logging everything to $DI_LOG_FILE"
log_progress "Starting the install on $OS (package type: $DI_PKG_TYPE)"

source "$BASEDIR/prepare.sh"

source "$BASEDIR/before_install.sh"

case "$OS" in
Linux)
  source "$BASEDIR/arch/index.sh"
  ;;
Darwin)
  source "$BASEDIR/macos/index.sh"
  ;;
*)
  log_error "OS $OS is not currently supported"
  exit 1
  ;;
esac

source "$BASEDIR/after_install.sh"
