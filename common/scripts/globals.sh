#!/usr/bin/env bash

#!/usr/bin/env bash

# shellcheck disable=SC2034

# Force script to exit if an error occurs
set -e


# shellcheck source=../kiauh/scripts/globals.sh
source "$KIAUH_DIR"/scripts/globals.sh
function set_globals() {
    HOSTNAME=$(hostname -s)

    base_set_globals
}

# KIAUH overrides #
rename_function "set_globals base_set_globals"

function install_mainsail_macros() {
    echo "No mainsail macros"
}
