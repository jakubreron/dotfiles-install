#!/usr/bin/env bash

if ! command -v zap >/dev/null 2>&1; then 
  log_progress "Setting up Zap"
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh)
else
  log_status "Zap is already installed"️
fi
