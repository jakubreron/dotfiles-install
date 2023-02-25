#!/bin/sh

install_pkg() {
	sudo pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
}
