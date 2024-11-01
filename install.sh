#!/usr/bin/env bash

declare -x BASEDIR
BASEDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

source "$BASEDIR/variables.sh"
source "$BASEDIR/helpers.sh"
source "$BASEDIR/shared/index.sh"

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

source "$BASEDIR/cleanup.sh"
