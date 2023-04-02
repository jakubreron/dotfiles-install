#!/usr/bin/env bash

declare -x DI_NPM_HELPER="${DI_NPM_HELPER:-"yarn"}"

declare -xr DI_DOTFILES_DIR="$HOME/.config/dotfiles"
declare -xr DI_VOIDRICE_DIR="$DI_DOTFILES_DIR/voidrice"
declare -xr DI_PKGLISTS_DIR="$DI_DOTFILES_DIR/pkglists"
declare -xr DI_VOIDRICE_REPO="https://github.com/jakubreron/voidrice.git"
declare -xr DI_PKGLISTS_REPO="https://github.com/jakubreron/pkglists.git"

declare -xr DI_GIT_CLONE_PATH="$HOME/Downloads/git-clone"
