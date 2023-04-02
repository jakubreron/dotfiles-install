#!/usr/bin/env bash

export npm_helper="yarn"

export dotfiles_dir="$HOME/.config/dotfiles"
export voidrice_dir="$dotfiles_dir/voidrice"
export pkglists_dir="$dotfiles_dir/pkglists"

export voidrice_repo="https://github.com/jakubreron/voidrice.git"
export pkglists_repo="https://github.com/jakubreron/pkglists.git"

export git_clone_path="$HOME/Downloads/git-clone"
mkdir -p "$git_clone_path"
