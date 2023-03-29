#!/bin/sh

export npm_helper="yarn"

dotfiles_dir="$HOME/.config/dotfiles"

voidrice_dir="$dotfiles_dir/voidrice"
voidrice_repo="https://github.com/jakubreron/voidrice.git"

pkglists_dir="$dotfiles_dir/pkglists"
pkglists_repo="https://github.com/jakubreron/pkglists.git"

git_clone_path="$HOME/Downloads/git-clone"
mkdir -p "$git_clone_path"
