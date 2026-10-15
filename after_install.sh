#!/usr/bin/env bash

log_progress "Stashing local changes in repos to ensure no unwanted overrides"
for repo_dir in "$DI_VOIDRICE_DIR" "$DI_UNIVERSAL_DIR" "$DI_MACOS_DIR" "$DI_PKGLISTS_DIR" "$DI_NVIM_DIR"; do
  log_progress "Stashing local changes in $repo_dir"
  git -C "$repo_dir" stash push -u -m "dotfiles-install backup"
done

log_progress "Stowing again to ensure no unwanted overrides"
stow --adopt --target="$HOME" --dir="$DI_DOTFILES_DIR" voidrice universal macos

ensure_firefox_profile

log_progress "Updating symlinks with global script (to ensure firefox config)"
command $HOME/.local/bin/sync/update-symlinks-all

if [ -f "$DI_SCRIPT_STATE_DIR/.firefox-setup-completed" ]; then
  log_status "Firefox setup already completed, skipping..."
else
  if [ -f "$HOME/.config/dotfiles/voidrice/.config/firefox/betterfox/user.js" ]; then
    log_progress "Restarting firefox to enforce custom config"
    killall firefox

    log_progress "Waiting for Firefox to shut down all processes"
    sleep 5

    log_progress "Opening Firefox Add-on pages for manual installation"
    declare -a addon_urls=(
      "https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/"
      "https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/"
      "https://addons.mozilla.org/en-US/firefox/addon/vimium-ff/"
      "https://addons.mozilla.org/en-US/firefox/addon/youtube-recommended-videos/"
      "https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/"
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
      log_progress "Opening $url"
      $open_command "$url" &
      sleep 1 # Small delay to give Firefox a moment to open each tab/window
    done

    log_progress "Marking the firefox setup as completed"
    touch "$DI_SCRIPT_STATE_DIR/.firefox-setup-completed"
  else 
    log_error "betterfox/user.js not found, config not sourced"
  fi
fi

log_progress "Building bat cache"
if command -v bat >/dev/null 2>&1; then
  bat cache --build
else
  log_warn "bat is not installed, skipping the cache build"
fi

log_progress "Cleaning up the clone folder $DI_GIT_CLONE_PATH"
rm -rf "$DI_GIT_CLONE_PATH"

print_failure_summary

log_status "Install finished, manual steps left"
log_warn "1. Log into Bitwarden and enable its SSH agent in Settings, git over SSH needs it"
log_warn "2. If the GPG key is still missing, restore it from Bitwarden and run: gpg --import <file>"
log_warn "3. Import Yomitan settings from $DI_VOIDRICE_DIR/.config/yomitan and dictionaries from your Google Drive backup"
log_warn "4. Restore uBlock Origin settings from $DI_VOIDRICE_DIR/.config/ublock"

log_progress "Last steps that need you, everything above ran unattended"
enroll_fingerprints
fetch_gpg_key_from_bitwarden
