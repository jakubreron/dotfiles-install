if command -v Xorg >/dev/null 2>&1; then
  log_progress "Xorg detected, setting up"

  setup_intel_hd_xorg() {
    if laptop-detect >/dev/null 2>&1; then
      log_progress "Laptop detected, setting up Intel HD Graphics on Xorg"
      printf 'Section "Device"
      Identifier "Intel Graphics"
      Driver "intel"
      Option      "TearFree"        "false"
      Option      "TripleBuffer"    "false"
      Option      "SwapbuffersWait" "false"
      EndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf
    else
      log_status "No laptop detected, skipping Intel HD Graphics setup on Xorg"️
    fi
  }

  setup_intel_hd_xorg
else
  log_status "No Xorg detected, skipping the configuration"️
fi
