#!/usr/bin/env bash

case "$OS" in
  Linux)
    log_progress "Preparing the user permissions"

    mkdir -p "$HOME"

    sudo usermod -aG wheel "$USER" # sudo
    sudo usermod -aG video "$USER" # backlight

    sudo chown "$USER":wheel "$HOME" # chown /home/jakub just in case $HOME is created under root user
    ;;
esac
