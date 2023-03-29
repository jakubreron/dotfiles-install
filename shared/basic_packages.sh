#!/bin/sh

case "$(uname -s)" in
  Linux*)
    if ! command -v "$di_pkg_manager_helper" >/dev/null 2>&1; then
      log_pretty_message "Installing AUR helper: $di_pkg_manager_helper"

      path="$git_clone_path/$di_pkg_manager_helper"
      clone_git_repo "https://aur.archlinux.org/$di_pkg_manager_helper.git" "$path"

      cd "$path" || exit
      makepkg -si
      cd ..
      rm -rf "$path"
    else
      log_pretty_message "AUR helper $di_pkg_manager_helper is already installed" ℹ️
    fi

    ;;
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      log_pretty_message "Installing brew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      log_pretty_message "Brew is already installed"
    fi
    ;;
esac
