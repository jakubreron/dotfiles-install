#!/usr/bin/env bash

log_progress "Creating common folders"

mkdir -p "$HOME"/{Documents,Downloads,Music,Pictures}
mkdir -p "$HOME"/Documents/Projects/{personal,work}
mkdir -p "$HOME"/.local/{bin,share,src}

case "$OS" in
  Linux)
    mkdir -p "$HOME"/{Videos,Cloud}
    mkdir -p "$HOME"/Documents/Torrents "$HOME"/Videos/Recordings "$HOME"/Pictures/Screenshots
    ;;
esac

mkdir -p "$DI_GIT_CLONE_PATH"
mkdir -p "$DI_DOTFILES_DIR"
