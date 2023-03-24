# NOTE: basic settings that do not require any previous setup
. ./basics.sh

# NOTE: packages installable with aur helper
. ./packages/pkg-manager.sh

# NOTE: packages not installable with aur helper
. ./packages/custom.sh

# NOTE: packages compiled from source
. ./packages/compiled.sh

# NOTE: settings for pacakges after installation
. ./settings.sh
