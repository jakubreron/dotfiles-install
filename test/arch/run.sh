#!/usr/bin/env bash

profile="arch-test"
context="colima-$profile"
image="arch-install-test"
name="${1:-arch-install}"
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
repo="$(cd -- "$here/../.." &>/dev/null && pwd)"

dk() { env -u DOCKER_HOST docker --context "$context" "$@"; }

previous_context="$(sed -n 's/.*"currentContext": *"\(.*\)".*/\1/p' "$HOME/.docker/config.json" 2>/dev/null)"

if ! colima list 2>/dev/null | grep -qE "^$profile +Running"; then
  echo "Starting the Colima profile $profile"
  colima start "$profile" --cpu 6 --memory 12 --disk 40
  if [[ -n "$previous_context" ]]; then
    env -u DOCKER_HOST docker context use "$previous_context" >/dev/null
  fi
fi

echo "Building the Arch image $image"
dk build --platform linux/amd64 -t "$image" "$here"

echo "Starting the container $name"
dk run -d --name "$name" --platform linux/amd64 \
  -v "$HOME/.config/dotfiles:/src/dotfiles:ro" \
  -v "$HOME/.config/nvim:/src/nvim:ro" \
  -v "$repo:/src/dotfiles-install:ro" \
  "$image" sleep infinity >/dev/null

echo "Seeding the container with copies of your repos and a small test package list"
dk exec -i "$name" bash -s <"$here/seed.sh"

echo "Running the installer in the background"
dk exec -d -e DI_PKG_TYPE=test "$name" bash -c 'yes "" | head -n 4000 | script -qec "bash $HOME/dotfiles-install/install.sh" /dev/null > ~/run.out 2>&1'

echo "Follow it with:"
echo "  env -u DOCKER_HOST docker --context $context exec $name tail -f /home/tester/run.out"
