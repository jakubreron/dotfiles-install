#!/bin/sh

user="jakubreron"

pkgtype="work"
pkg_manager_helper="brew"

. ./helpers.sh

log_pretty_message "Installing brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
 
log_pretty_message "Installing brew"
for package in stow findutils node yarn fnm rust exa mcfly aunpack atool fzf gettext; do
  brew install "$package"
done

. ../shared/index.sh
. ./setup/index.sh
