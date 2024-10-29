#!/usr/bin/env bash

if ! command -v zsh >/dev/null 2>&1; then
  log_progress "Installing ZSH"
  install_pkg zsh zsh-completions
fi

if command -v zsh >/dev/null 2>&1; then
  mkdir -p "$HOME/.cache/zsh/"
  mkdir -p "$HOME/.config/zsh/"

  touch "$HOME/.cache/zsh/.zsh_history"

  if ! [[  "$SHELL" =~ .*'zsh' ]]; then
    log_progress "Changing default shell to ZSH"

    case "$OS" in
      Linux)
        chsh -s /usr/bin/zsh "$USER"
        ;;
      Darwin)
        chsh -s /bin/zsh "$USER"
        ;;
    esac
  else
    log_status "ZSH is already a default shell"️
  fi

  rm "$HOME/.config/zsh/.zcompdump"
fi
