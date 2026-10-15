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
declare -x DI_FAILURES_FILE
DI_FAILURES_FILE="${DI_LOG_FILE%.log}-failures.txt"
: >"$DI_FAILURES_FILE"
set -o errtrace
trap 'record_failed_command "$?" "${BASH_SOURCE[0]}" "$LINENO" "$BASH_COMMAND"' ERR
log_status "Failed commands are collected in $DI_FAILURES_FILE and summarized at the end"

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

log_progress "Running preflight checks"
run_preflight_checks

log_progress "Checking sudo is available"
if ! command -v sudo >/dev/null 2>&1; then
  log_error "sudo is not installed, install it and add your user to the wheel group as root first"
  exit 1
fi

log_progress "Asking for your sudo password once, it is kept alive for the whole run"
if ! sudo -v; then
  log_error "Could not get sudo access, check your password and that your user may use sudo"
  exit 1
fi

sudo_keepalive_seconds=60
(
  trap - ERR
  while kill -0 "$$" 2>/dev/null; do
    sudo -n true
    sleep "$sudo_keepalive_seconds"
  done
) >/dev/null 2>&1 &

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
