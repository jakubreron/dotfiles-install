# TODO: brew install koekeishiya/formulae/skhd; brew services start skhd
# TODO: save it somewhere https://www.chrisatmachine.com/posts/01-macos-developer-setup
# TODO: execute this command after installing packages: xattr -d com.apple.quarantine /Applications/Chromium.app

# NOTE: basic settings that do not require any previous setup
. ./basic_settings.sh

# NOTE: brew, custom, and compiled packages installation process
. ./packages/installation/index.sh

# NOTE: all packages settings
. ./packages/settings/index.sh
