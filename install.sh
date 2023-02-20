#!/bin/sh

install_dirs() {
  mkdir $HOME/{Documents,Downloads,Music,Pictures,Videos,Cloud,Storage}
  mkdir -p $HOME/.config/personal
  mkdir -p $HOME/.local/{bin,share,src}
}

install_keyd() {
  path="$HOME/Downloads/keyd"
  git clone https://github.com/rvaiya/keyd "$path" || return 1
  cd "$path" || return 1
  make && sudo make install
  sudo systemctl enable keyd && sudo systemctl start keyd
  rm -rf "$path"
  
  global_config_path="/etc/keyd/defaulf.conf"
  echo "[ids]

*

[main]

shift = oneshot(shift)
meta = oneshot(meta)
control = oneshot(control)

leftalt = oneshot(alt)
rightalt = oneshot(altgr)

capslock = overload(meta, esc)
insert = S-insert" | sudo tee "$global_config_path"
}

# install_dirs
[ -x "$(command -v "keyd")" ] || install_keyd
