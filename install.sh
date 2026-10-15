#!/usr/bin/env bash

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

log_progress "Adding $HOME/.local/bin to PATH for this run"
export PATH="$HOME/.local/bin:$PATH"

log_progress "Forcing https for GitHub during this run (your stored remotes stay untouched)"
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf"
export GIT_CONFIG_VALUE_0="git@github.com:"
export GIT_CONFIG_KEY_1="url.https://github.com/.insteadOf"
export GIT_CONFIG_VALUE_1="ssh://git@github.com/"

log_progress "Checking the script is not run as root"
if [[ "$EUID" -eq 0 ]]; then
  log_error "This script should not be run as root. Exiting."
  exit 1
fi

log_progress "Running before_install.sh"
source "$BASEDIR/before_install.sh"

case "$OS" in
Linux)
  log_progress "Running the Linux (arch) install steps"
  source "$BASEDIR/arch/index.sh"
  ;;
Darwin)
  log_progress "Running the macOS install steps"
  source "$BASEDIR/macos/index.sh"
  ;;
*)
  log_error "OS $OS is not currently supported"
  exit 1
  ;;
esac

log_progress "Running after_install.sh"
source "$BASEDIR/after_install.sh"
