#!/bin/sh

user="jakubreron"

pkgtype="work"
pkg_manager_helper="brew"

log_pretty_message "Installing brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
 
. ../shared/index.sh
. ./setup/index.sh
