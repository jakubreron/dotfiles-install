#!/bin/sh

npm_helper="yarn"

dotfiles_dir="~/.config/dotfiles"

voidrice_dir="$dotfiles_dir/voidrice"
voidrice_repo="https://github.com/jakubreron/voidrice.git"

pkglists_dir="$dotfiles_dir/pkglists"
pkglists_repo="https://github.com/jakubreron/pkglists.git"

git_clone_path="~/Downloads/git-clone"
mkdir -p "$git_clone_path"
