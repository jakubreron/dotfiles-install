#!/bin/sh

# TODO: add brew install
# TODO: install findutils, node, yarn, fnm, exa, mcfly, aunpack, atool, fzf, gettext
# TODO: after cloning pkglists, do cat brew.txt | xargs brew install

user="jakubreron"

pkgtype="work"
pkg_manager_helper="brew"

. ./helpers.sh

. ../shared/index.sh
. ./setup/index.sh
