#!/usr/bin/env bash

remove_db_lock() {
  if [[ -f /var/lib/pacman/db.lck ]] && ! pgrep -x pacman >/dev/null 2>&1; then
    log_warn "Pacman DB lock file detected, attempting to remove it"
    if sudo rm -f /var/lib/pacman/db.lck; then
      log_status "Pacman DB lock removed"
    else
      log_error "Failed to remove Pacman DB lock, please resolve manually"
    fi
  fi
}

record_failed_command() {
  local exit_code="$1" source_file="$2" line="$3" failed_command="$4"
  local last_failure

  case "$failed_command" in
  "("* | source\ * | .\ *) return 0 ;;
  *'$('*)
    case "${failed_command%% *}" in
    [A-Za-z_]*=*) return 0 ;;
    esac
    ;;
  esac

  last_failure="$(tail -n 1 "$DI_FAILURES_FILE" 2>/dev/null)"
  case "$last_failure" in
  *": $failed_command") return 0 ;;
  esac

  echo "exit $exit_code in ${source_file##*/}:$line: $failed_command" >>"$DI_FAILURES_FILE"
}

print_failure_summary() {
  local stopped="${1:-}" count index=0 failure

  if [[ -n "${DI_FAILURE_SUMMARY_PRINTED:-}" ]]; then
    return 0
  fi
  DI_FAILURE_SUMMARY_PRINTED=1

  count="$(wc -l <"$DI_FAILURES_FILE" 2>/dev/null | tr -d ' ')"
  if [[ "${count:-0}" -eq 0 ]]; then
    if [[ -z "$stopped" ]]; then
      log_status "All steps finished without a failed command"
    fi
    return 0
  fi

  log_warn "$count command(s) failed during this run"
  while IFS= read -r failure; do
    index=$((index + 1))
    echo "   $index. $failure"
  done <"$DI_FAILURES_FILE"
  log_warn "Full output of the run is in $DI_LOG_FILE"
}

finish_install() {
  local exit_code=$?

  if [[ "$exit_code" -ne 0 ]]; then
    log_error "The install stopped early with exit code $exit_code, the full output is in $DI_LOG_FILE"
    print_failure_summary stopped
  else
    print_failure_summary
  fi

  release_install_lock
}

release_install_lock() {
  rm -f "$DI_LOCK_DIR/pid"
  rmdir "$DI_LOCK_DIR" 2>/dev/null
}

acquire_install_lock() {
  local running_pid

  log_progress "Checking no other install is running"
  if ! mkdir "$DI_LOCK_DIR" 2>/dev/null; then
    running_pid="$(cat "$DI_LOCK_DIR/pid" 2>/dev/null)"

    if [[ -n "$running_pid" ]] && kill -0 "$running_pid" 2>/dev/null; then
      log_error "Another install is already running (pid $running_pid), wait for it to finish"
      exit 1
    fi

    log_warn "Removing a stale install lock left by a crashed run"
    release_install_lock
    mkdir "$DI_LOCK_DIR" || {
      log_error "Could not create the install lock at $DI_LOCK_DIR"
      exit 1
    }
  fi

  echo "$$" >"$DI_LOCK_DIR/pid"
  trap finish_install EXIT
  log_status "Install lock acquired"
}

check_network() {
  local url
  local -a urls=("https://github.com")
  [[ "$OS" == "Linux" ]] && urls+=("https://archlinux.org")

  if ! command -v curl >/dev/null 2>&1; then
    log_warn "curl is not installed, skipping the network check"
    return 0
  fi

  for url in "${urls[@]}"; do
    log_progress "Checking that $url is reachable"
    if ! curl -fsS -I -o /dev/null --max-time "$DI_NETWORK_TIMEOUT_SECONDS" "$url"; then
      log_error "Cannot reach $url, check your internet connection (and VPN or proxy) and run again"
      exit 1
    fi
  done

  log_status "Network is reachable"
}

check_disk_space() {
  local min_gb free_gb answer

  case "$OS" in
  Linux) min_gb="$DI_MIN_FREE_GB_LINUX" ;;
  Darwin) min_gb="$DI_MIN_FREE_GB_MACOS" ;;
  esac

  free_gb="$(($(df -Pk "$HOME" | awk 'NR==2 {print $4}') / 1024 / 1024))"
  log_progress "Free disk space in $HOME is ${free_gb}GB, at least ${min_gb}GB is recommended"

  if ((free_gb >= min_gb)); then
    log_status "Enough free disk space"
    return 0
  fi

  log_warn "Low disk space, the install may fail halfway"
  if read -r -p "Continue anyway? [y/N] " answer; then
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      log_error "Stopping because of low disk space"
      exit 1
    fi
  else
    log_warn "No input available, continuing despite the low disk space"
  fi
}

run_preflight_checks() {
  acquire_install_lock
  check_network
  check_disk_space
}

firefox_profile_exists() {
  local profile_dir

  for profile_dir in "$@"; do
    grep -qs "default-release" "$profile_dir/profiles.ini" && return 0
  done

  return 1
}

ensure_firefox_profile() {
  local firefox_bin firefox_pid
  local -a profile_dirs

  case "$OS" in
  Linux)
    firefox_bin="$(command -v firefox)"
    profile_dirs=("${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox" "$HOME/.mozilla/firefox")
    ;;
  Darwin)
    firefox_bin="/Applications/Firefox.app/Contents/MacOS/firefox"
    profile_dirs=("$HOME/Library/Application Support/Firefox")
    ;;
  esac

  log_progress "Checking whether a Firefox profile already exists"
  if firefox_profile_exists "${profile_dirs[@]}"; then
    log_status "Firefox profile already exists, skipping"
    return 0
  fi

  if [[ -z "$firefox_bin" || ! -x "$firefox_bin" ]]; then
    log_warn "Firefox is not installed, cannot create its profile"
    return 0
  fi

  log_progress "Starting Firefox headless once to create its profile"
  "$firefox_bin" --headless --no-remote about:blank >/dev/null 2>&1 &
  firefox_pid=$!

  for _ in $(seq 1 30); do
    firefox_profile_exists "${profile_dirs[@]}" && break
    sleep 1
  done

  log_progress "Stopping the headless Firefox"
  kill "$firefox_pid" 2>/dev/null
  wait "$firefox_pid" 2>/dev/null

  if firefox_profile_exists "${profile_dirs[@]}"; then
    log_status "Firefox profile created"
  else
    log_warn "Firefox did not create a profile within 30 seconds, the user.js merge will be skipped"
  fi
}

gpg_key_missing() {
  local gpg_key_id
  gpg_key_id="$(git config -f "$1" user.signingkey)"

  [[ -n "$gpg_key_id" ]] && ! gpg --list-secret-keys "$gpg_key_id" >/dev/null 2>&1
}

import_gpg_key() {
  local git_config_file="$1" gpg_key_file="$2"

  log_progress "Checking the GPG key configured in $git_config_file"
  if gpg_key_missing "$git_config_file"; then
    if [[ -f "$gpg_key_file" ]]; then
      log_progress "Importing GPG key from $gpg_key_file (passphrase is in Bitwarden)"
      gpg --import "$gpg_key_file"
    else
      log_warn "GPG key not found, restore it from Bitwarden and run: gpg --import <file>"
    fi
  else
    log_status "GPG key is already in the keyring or not configured, skipping"
  fi
}

import_gpg_keys() {
  log_progress "Importing GPG keys for $OS"

  case "$OS" in
  Darwin)
    import_gpg_key "$HOME/.config/git/config_macos" "$HOME/.config/git/work-gpg-key.asc"
    ;;
  Linux)
    import_gpg_key "$HOME/.config/git/config_linux" "$HOME/.config/git/personal-gpg-key.asc"
    ;;
  esac
}

fetch_gpg_key_from_bitwarden() {
  local git_config_file bitwarden_item answer

  case "$OS" in
  Darwin)
    git_config_file="$HOME/.config/git/config_macos"
    bitwarden_item="work-git"
    ;;
  Linux)
    git_config_file="$HOME/.config/git/config_linux"
    bitwarden_item="personal-git"
    ;;
  esac

  log_progress "Checking whether the GPG key needs to be fetched from Bitwarden"
  if ! gpg_key_missing "$git_config_file"; then
    log_status "GPG key is already in the keyring or not configured, skipping the Bitwarden fetch"
    return 0
  fi

  if ! command -v bw >/dev/null 2>&1; then
    log_warn "Bitwarden CLI (bw) is not installed, skipping the Bitwarden fetch"
    return 0
  fi

  read -r -p "GPG key is missing, fetch it from Bitwarden item '$bitwarden_item' now? [y/N] " answer || {
    log_status "No input available, skipping the Bitwarden fetch"
    return 0
  }
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    log_status "Skipping the Bitwarden fetch"
    return 0
  fi

  if ! bw login --check >/dev/null 2>&1; then
    log_progress "Logging into Bitwarden"
    bw login
  fi

  log_progress "Unlocking the Bitwarden vault"
  BW_SESSION="$(bw unlock --raw)" || {
    log_error "Could not unlock the Bitwarden vault"
    return 0
  }
  export BW_SESSION

  log_progress "Importing GPG key from Bitwarden item $bitwarden_item"
  bw get notes "$bitwarden_item" | gpg --import

  log_progress "Locking the Bitwarden vault"
  bw lock >/dev/null 2>&1
  unset BW_SESSION
}

brew_install() {
  local pkg
  for pkg in "$@"; do
    if brew info --formula "$pkg" >/dev/null 2>&1; then
      log_progress "Installing $pkg with brew (formula)"
      brew install --formula "$pkg"
    elif brew info --cask "$pkg" >/dev/null 2>&1; then
      log_progress "Installing $pkg with brew (cask)"
      brew install --cask "$pkg"
    else
      log_progress "Installing $pkg with brew (not found as formula or cask, trying as is)"
      brew install "$pkg"
    fi
  done
}

install_pkg() {
  case "$OS" in
  Linux)
    remove_db_lock

    if command -v "$DI_AUR_HELPER" >/dev/null 2>&1; then
      log_progress "Installing with $DI_AUR_HELPER: $*"
      "$DI_AUR_HELPER" --needed -S "$@"
    else
      log_progress "Installing with pacman: $*"
      sudo pacman --needed -S "$@"
    fi
    ;;
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      log_warn "Brew not detected, attempting to source it first..."
      eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
      log_error "Brew not installed, quitting..."
      exit 1
    fi

    log_progress "Installing with brew: $*"
    brew_install "$@"
    ;;
  esac
}

log_message() {
  message="$1"
  emoji="${2:-⏳}"

  BOLD=$(tput bold)
  BLUE=$(tput setaf 4)
  RESET=$(tput sgr0)

  printf "%s${BLUE}${BOLD}$emoji $message...${RESET}\n"
}

log_progress() {
  message="$1"
  emoji="${2:-🕒}"

  log_message "$message" "$emoji"
}

log_status() {
  message="$1"
  emoji="${2:-✅}"

  log_message "$message" "$emoji"
}

log_warn() {
  message="$1"
  emoji="${2:-🟠}"

  log_message "$message" "$emoji"
}

log_error() {
  message="$1"
  emoji="${2:-❌}"

  log_message "$message" "$emoji"
}

clone_git_repo() {
  repo="$1"
  destination="$2"

  if [[ ! -d "$destination" ]]; then
    log_progress "$destination does not exist, cloning $repo via git"
    git clone "$repo" "$destination"
    log_status "Cloned $repo into $destination"
  else
    log_status "Pulling latest changes in  $destination, the repository already existed"️
    if ! git -C "$destination" pull --ff-only; then
      log_warn "Could not fast-forward $destination (local commits not on origin?), keeping its current version"
    fi
  fi

  if [[ -f "$destination/.gitmodules" ]]; then
    log_progress "[Background] Initializing submodules in $destination"
    git -C "$destination" submodule update --init --remote --recursive &
  fi
}
