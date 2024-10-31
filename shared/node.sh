#!/usr/bin/env bash

if ! command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then 
  log_progress "Installing $DI_NPM_HELPER"
  install_pkg nodejs fnm "$DI_NPM_HELPER"
fi

if command -v "$DI_NPM_HELPER" >/dev/null 2>&1; then 
  log_progress "Installing node packages via $DI_NPM_HELPER"

  packages="$DI_PKGLISTS_DIR/$DI_PKG_TYPE/$DI_NPM_HELPER.txt"
  cat "$packages" | xargs $DI_NPM_HELPER install --global
fi
