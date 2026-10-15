* fix throttling issues on my thinkpad laptop

```sh
sudo pacman -S msr-tools throttled
sudo systemctl enable --now throttled

# check if exists, but idk if this snippet is valid
echo "msr" | sudo tee /etc/modules-load.d/msr.conf

# then add
[Unit]
Description=Fix ThinkPad 400MHz CPU Throttling After Suspend
After=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=/usr/bin/wrmsr -a 0x1FC 0x23E0000

[Install]
WantedBy=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

sudo systemctl daemon-reload
sudo systemctl enable lenovo-fix-wake.service
```

* modify the dotfiles install script, so that bitwarden doesn't become my ssh agent, but instead, it creates files id_rsa_personal and id_rsa_work  with relevant permissions, and they are untracked, so everything is ok. update readme in unviersal repo too, I don't need to manually do `cd ~/.config/dotfiles && stow --adopt --target=$HOME universal &&
chmod 600 ~/.ssh/{id_rsa_personal.pub,id_rsa_work.pub,config} &&
chmod 700 ~/.ssh`, it should be automatic

* paste my gemini conversation into claude, and see what was not working

* NPM not working sometimes, setup in dotfiles to use latest lts node from fnm
* there are too many logs after all, drop obvious logs such as
  * `log_progress "Running prepare.sh"`
  * `log_progress "Running before_install.sh"`
* instead of "log_progress "Running preflight checks"", just log "Install lock acquired", "Network is reachable", etc. not only for these, but for everything else too
