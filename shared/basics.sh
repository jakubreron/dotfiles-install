#!/bin/sh

create_dirs() {
  mkdir ~/{Documents,Downloads,Music,Pictures,Videos,Cloud,Storage}
  mkdir ~/Documents/Projects/{personal,work}
  mkdir ~/Videos/Recordings ~/Pictures/Screenshots

  mkdir -p ~/.local/{bin,share,src}
  mkdir -p ~/.local/bin/{dmenu,entr,git,layouts,music,qemu,rofi,statusbar,tmux,update,volume}

  case "$(uname -s)" in
    Linux*)
        mkdir -p ~/Videos/Recordings
        mkdir -p ~/Pictures/Screenshots
      ;;
    Darwin)
      ;;
  esac

  mkdir -p "$dotfiles_dir"
}

clone_dotfiles_repos() {
  git clone "$voidrice_repo" "$voidrice_dir"
  git clone "$pkglists_repo" "$pkglists_dir"

  git --git-dir "$voidrice_dir" pull
  git --git-dir "$pkglists_dir" pull

  git --git-dir "$voidrice_dir" submodule update --init --remote --recursive
}

replace_stow() {
  stow --adopt --target="$home" --dir="$dotfiles_dir" voidrice
}

create_dirs
clone_dotfiles_repos
replace_stow
