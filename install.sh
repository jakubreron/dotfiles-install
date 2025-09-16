#!/usr/bin/env bash

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# TODO: add check to prevent using this script as a root user

source "$BASEDIR/variables.sh"
source "$BASEDIR/helpers.sh"
source "$BASEDIR/shared.sh"

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

# cleanup
rm -rf "$DI_GIT_CLONE_PATH"
