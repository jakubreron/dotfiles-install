```sh
sudo pacman -S msr-tools throttled
sudo systemctl enable --now throttled

# check if exists
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
