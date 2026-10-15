# dotfiles-install

Installs my dotfiles on **Arch Linux** and **macOS**. Run it, type your `sudo` password once, and it does the rest.

## Before you start

* Clone the private `universal` repo into `~/.config/dotfiles/universal` first, the installer expects it
* Needs internet, `sudo`, and enough free disk (10 GB on Linux, 5 GB on macOS)
* Run it as your normal user, never as root

## Run

```sh
bash install.sh
```

* Never `source` it, it calls `exit` and would close your terminal (it refuses to start if sourced)
* **Arch** installs the package list from `pkglists/$DI_PKG_TYPE` (default `primary`), for example `DI_PKG_TYPE=secondary bash install.sh`
* **macOS** always uses the `work` list

## What it does

* `prepare.sh`: failure tracking, forced https for GitHub, root check, preflight checks (network, disk space, a lock against two runs at once), `sudo` kept alive
* `before_install.sh`: folders, `paru` or Homebrew, `git`, `stow`, cloning the dotfile repos, `zsh`, global `npm` packages, shell shortcuts
* `arch/` or `macos/`: system settings, packages, services, GPG agent
* `after_install.sh`: stashes local changes, stows again, creates the Firefox profile and merges its config, prints the summary and the checklist

## Safe to run again

* Every step checks first and skips what is already done, so a crashed run can simply be started again
* Local changes in the dotfile repos are **stashed, never deleted** (`git stash list` in the repo)
* Repos are updated with fast-forward only pulls, a repo with local commits is left as it is with a warning

## Hands-off, with a few steps at the end

* Package installs use `--noconfirm`, so there is nothing to press during the run
* Steps that need you come last, after the summary: fingerprint enrollment and the Bitwarden GPG key fetch
* The final checklist lists what stays manual (Bitwarden SSH agent, Yomitan and uBlock settings)

## Logs and failures

* Everything is logged to `${XDG_CACHE_HOME:-~/.cache}/dotfiles-install/install-<timestamp>.log`, read it with `less -R`
* Every command that fails is recorded in `install-<timestamp>-failures.txt` and listed in the summary near the end
* If the run stops early, the last lines say so and which command failed

## Testing in a container

Runs the whole installer on a minimal Arch in a separate Colima VM, without touching your machine:

```sh
bash test/arch/run.sh
```

* Uses the `arch-test` Colima profile and an `archlinux` x86-64 image (emulated on Apple silicon, so the `paru` build takes a while)
* Copies your local repos into the container, so unpushed commits are tested too
* Installs a small test package list instead of the real one, and stubs `systemctl`
* Does not cover hardware, systemd or GUI steps (bluetooth service, fingerprint reader, Firefox UI)
