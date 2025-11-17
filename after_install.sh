#!/usr/bin/env bash

log_progress "Resetting repos with reset --hard to ensure no unwanted overrides"
git -C "$DI_VOIDRICE_DIR" reset --hard
git -C "$DI_UNIVERSAL_DIR" reset --hard
git -C "$DI_MACOS_DIR" reset --hard
git -C "$DI_PKGLISTS_DIR" reset --hard
git -C "$DI_NVIM_DIR" reset --hard

log_progress "Stowing again to ensure no unwanted overrides"
stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice universal macos

log_progress "Cleaning up"
rm -rf "$DI_GIT_CLONE_PATH"
