#!/usr/bin/env bash

if ! command -v git >/dev/null 2>&1; then
  log_progress "Installing git"
  install_pkg git
fi

if command -v git >/dev/null 2>&1; then
  clone_git_repo "$DI_VOIDRICE_REPO" "$DI_VOIDRICE_DIR"
  clone_git_repo "$DI_PKGLISTS_REPO" "$DI_PKGLISTS_DIR"
  clone_git_repo "$DI_MACOS_REPO" "$DI_MACOS_DIR"
  clone_git_repo "$DI_NVIM_REPO" "$DI_NVIM_DIR"
fi
