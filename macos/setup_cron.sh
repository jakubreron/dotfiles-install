#!/usr/bin/env bash

log_progress "Installing wiki autocommit cron job"
if crontab -l 2>/dev/null | grep -qF "wiki-autocommit"; then
  log_status "Wiki autocommit cron job already installed, skipping"
else
  log_progress "Adding the wiki autocommit entry to the crontab (daily at 18:40)"
  { crontab -l 2>/dev/null; echo '40 18 * * * $HOME/.local/bin/wiki-autocommit'; } | crontab -
  log_warn "Grant /usr/sbin/cron Full Disk Access manually (System Settings, Privacy & Security)"
fi
