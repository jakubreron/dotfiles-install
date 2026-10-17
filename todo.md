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

conversation from gemini:

```text

on linux can i authenticate with fingerprint? terminal command sudo pam-auth-update on arch linux equivalent

Yes, you can authenticate with a fingerprint on Linux. However, Arch Linux does not have an equivalent automated command like Ubuntu/Debian’s sudo pam-auth-update.
On Arch Linux, PAM (Pluggable Authentication Modules) configurations are handled manually to maintain the distribution's DIY principles. You achieve the exact same result by installing the necessary package and adding one line to your PAM configuration files.
Here is how to set up system-wide and sudo fingerprint authentication on Arch Linux:

Step 1: Install the Fingerprint Daemon

First, install the open-source fingerprint management tool and driver library via pacman:
bash
sudo pacman -S fprintd
Use code with caution.

Step 2: Enroll Your Fingerprint

Register your fingerprint to your current user account by running:
bash
fprintd-enroll
Use code with caution.
Follow the terminal prompts to tap your sensor until completion. You can verify your enrolled fingers using fprintd-list $USER.

Step 3: Configure PAM Manually (The pam-auth-update Equivalent)

Instead of a wizard tool, you must manually edit the configuration files to tell Arch to look for a fingerprint before falling back to a password.
⚠️ Warning: Always keep a separate terminal window open with root access (sudo -i) while editing PAM files. If you make a typo, you could temporarily lock yourself out of authentication.

Option A: Enable for sudo only

If you only want fingerprint prompts when running terminal commands, open the sudo configuration:
bash
sudo nano /etc/pam.d/sudo
Use code with caution.
Add auth sufficient pam_fprintd.so to the very top of the file:
text
#%PAM-1.0
auth sufficient pam_fprintd.so
auth include system-auth
Use code with caution.
(The sufficient tag tells Linux that if the fingerprint succeeds, it can skip the password prompt; if it fails, it moves to the next line for a password fallback).

Option B: Enable System-Wide (sudo, Lock Screens, and GDM)

To make your fingerprint work globally (including local login and GUI polkit windows), edit the central authentication file instead:
bash
sudo nano /etc/pam.d/system-auth
Use code with caution.
Add the module to the very top of the auth section:
text
auth      sufficient pam_fprintd.so
auth      required   pam_env.so
...
Use code with caution.
Once saved, the changes apply immediately without needing a system reboot.
If you try this out, let me know:
• What Desktop Environment (GNOME, KDE Plasma, XFCE) or display manager you are using?
• If you run into a specific error or if your hardware reader isn't recognized by fprintd?
I can give you the exact steps to map GUI login features or fix device driver issues.
• 
Medium·Riki Phukon
System-Wide Fingerprint Auth on Arch Linux
Edit /etc/pam.d/system-auth Add the fingerprint module at the very top of the auth section in your /etc/pam.d/system-auth file.
• 
rikiphukon.com
System-Wide Fingerprint Auth on Arch Linux | Riki Phukon
Aug 21, 2025 — Edit `/etc/pam.d/system-auth` by adding `auth sufficient pam_fprintd.so` at the top of the auth section to enable fingerprint auth...
• 
Reddit·r/archlinux
Fingerprint-enabled sudo/ login : r/archlinux - Reddit
September 23, 2020 — Fingerprint Authentication Setup: The user is attempting to enable fingerprint authentication for sudo and session unlock on an Ar...
Show all
auth

now how to reload settings? can I use fingerprint for sudo commands immediately?

Yes, you can use your fingerprint for sudo commands immediately.
PAM (Pluggable Authentication Modules) reads its configuration files dynamically on every request. You do not need to reload any services, restart the terminal, or reboot your machine.
To test it right now, simply open a new terminal window and run:
bash
sudo echo "It works!"
Use code with caution.

🔍 What to expect:

• Terminal Prompt: Depending on your configuration, your terminal will either display a prompt like Place your finger on the fingerprint reader or it might sit blank for a second waiting for your print.
• If it fails or times out: It will seamlessly fall back to your normal user password prompt.

🛠️ Troubleshooting (If it isn't working immediately)

If you are prompted for a password straight away without a fingerprint option, check these two things:
1. The order in the file: Ensure auth sufficient pam_fprintd.so is placed above the auth include system-auth (or any other auth lines) in /etc/pam.d/sudo. If it's below them, Linux will ask for your password first.
2. Device State: Ensure your device is recognized by running fprintd-list $USER. If it says no devices available, the daemon might need a quick restart to hook onto your hardware:bash
sudo systemctl restart fprintd
Use code with caution.
Did the test sudo command prompt you for your print, or did it jump straight to the password fallback? Let me kno
```

* so to summarize, I want to authenticate with fingerprint also on sudo commands
* not only on sudo commands in terminal, but also on polkit, pinentry, and everywhere possible, on gui popups, etc.
