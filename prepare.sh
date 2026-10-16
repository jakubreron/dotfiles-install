#!/usr/bin/env bash

declare -x DI_FAILURES_FILE
DI_FAILURES_FILE="${DI_LOG_FILE%.log}-failures.txt"
: >"$DI_FAILURES_FILE"
set -o errtrace
trap 'record_failed_command "$?" "${BASH_SOURCE[0]}" "$LINENO" "$BASH_COMMAND"' ERR
log_status "Failed commands are collected in $DI_FAILURES_FILE and summarized at the end"

export PATH="$HOME/.local/bin:$PATH"

export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="url.https://github.com/.insteadOf"
export GIT_CONFIG_VALUE_0="git@github.com:"
export GIT_CONFIG_KEY_1="url.https://github.com/.insteadOf"
export GIT_CONFIG_VALUE_1="ssh://git@github.com/"

if [[ "$EUID" -eq 0 ]]; then
  log_error "This script should not be run as root. Exiting."
  exit 1
fi

run_preflight_checks

if ! command -v sudo >/dev/null 2>&1; then
  log_error "sudo is not installed, install it and add your user to the wheel group as root first"
  exit 1
fi

log_progress "Asking for your sudo password once, it is kept alive for the whole run"
if ! sudo -v; then
  log_error "Could not get sudo access, check your password and that your user may use sudo"
  exit 1
fi
log_status "sudo access confirmed"

sudo_keepalive_seconds=60
(
  trap - ERR
  while kill -0 "$$" 2>/dev/null; do
    sudo -n true
    sleep "$sudo_keepalive_seconds"
  done
) >/dev/null 2>&1 &
