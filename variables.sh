#!/usr/bin/env bash

declare -x OS
OS="$(uname -s)"

declare -x DI_NPM_HELPER="${DI_NPM_HELPER:-'npm'}"
declare -x DI_AUR_HELPER="${DI_AUR_HELPER:-'paru'}"

declare -xr DI_DOTFILES_DIR="$HOME/.config/dotfiles"
declare -xr DI_NVIM_DIR="$HOME/.config/nvim"
declare -xr DI_VOIDRICE_DIR="$DI_DOTFILES_DIR/voidrice"
declare -xr DI_PKGLISTS_DIR="$DI_DOTFILES_DIR/pkglists"
declare -xr DI_MACOS_DIR="$DI_DOTFILES_DIR/macos"

declare -xr DI_NVIM_REPO="https://github.com/jakubreron/kickstart.nvim.git"
declare -xr DI_VOIDRICE_REPO="https://github.com/jakubreron/voidrice.git"
declare -xr DI_PKGLISTS_REPO="https://github.com/jakubreron/pkglists.git"
declare -xr DI_MACOS_REPO="https://github.com/jakubreron/macos.git"

declare -xr DI_GIT_CLONE_PATH="$HOME/Downloads/git-clone"

case "$OS" in
  Linux)
    declare -x DI_PKG_TYPE="${DI_PKG_TYPE:-secondary}"
    declare -xr DI_FIREFOX_BROWSER="firefox-developer-edition"
    declare -xr HOME="/home/$USER" # needed if you run script as root
    ;;
  Darwin)
    declare -xr DI_PKG_TYPE="work"
    declare -xr DI_FIREFOX_BROWSER="firefox"
    ;;
esac

