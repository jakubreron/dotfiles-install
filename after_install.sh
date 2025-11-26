#!/usr/bin/env bash

log_progress "Resetting repos with reset --hard to ensure no unwanted overrides"
git -C "$DI_VOIDRICE_DIR" reset --hard
git -C "$DI_UNIVERSAL_DIR" reset --hard
git -C "$DI_MACOS_DIR" reset --hard
git -C "$DI_PKGLISTS_DIR" reset --hard
git -C "$DI_NVIM_DIR" reset --hard

log_progress "Stowing again to ensure no unwanted overrides"
stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice universal macos

log_progress "Updating symlinks with global script (to ensure firefox config)"
$HOME/.local/bin/sync/update-symlinks-all

log_progress "Restarting firefox to enforce custom config"
killall firefox

log_progress "Opening Firefox Add-on pages for manual installation"
declare -a addon_urls=(
  "https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/"
  "https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/"
  "https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/"
  "https://addons.mozilla.org/en-US/firefox/addon/youtube-recommended-videos/"
  "https://addons.mozilla.org/en-US/firefox/addon/yomitan/"
)
case "$OS" in
  Linux)
    open_command="firefox"
    ;;
  Darwin)
    open_command="open -a Firefox"
    ;;
esac
for url in "${addon_urls[@]}"; do
  firefox "$url" &
  sleep 1 # Small delay to give Firefox a moment to open each tab/window
done

log_progress "Building bat cache"
if command -v bat >/dev/null 2>&1; then
  bat cache --build
fi

log_progress "Cleaning up"
rm -rf "$DI_GIT_CLONE_PATH"
