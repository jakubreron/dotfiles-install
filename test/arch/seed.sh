set -e
mkdir -p ~/.config/dotfiles
for r in universal voidrice macos pkglists; do cp -r "/src/dotfiles/$r" ~/.config/dotfiles/"$r"; done
cp -r /src/nvim ~/.config/nvim
cp -r /src/dotfiles-install ~/dotfiles-install
mkdir -p ~/.config/dotfiles/pkglists/test
cat > ~/.config/dotfiles/pkglists/test/pacman.txt <<'LIST'
bat
gnupg
lib32-mesa
openssh
ripgrep
ticker-bin
tmux
LIST
printf "cowsay\n@bitwarden/cli\n" > ~/.config/dotfiles/pkglists/test/npm.txt
printf 'test/\n' >> ~/.config/dotfiles/pkglists/.git/info/exclude
echo "seeded: $(ls ~/.config/dotfiles | tr '\n' ' ')"
