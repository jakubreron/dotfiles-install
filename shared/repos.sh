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

  log_progress "Pulling latest changes in repos"
  git -C "$DI_VOIDRICE_DIR" pull
  git -C "$DI_PKGLISTS_DIR" pull
  git -C "$DI_MACOS_DIR" pull
  git -C "$DI_NVIM_DIR" pull

  log_progress "[Background] Initializing submodules in $DI_VOIDRICE_DIR"
  git -C "$DI_VOIDRICE_DIR" submodule update --init --remote --recursive &
fi
