#!/usr/bin/env bash

# shellcheck disable=SC2034

# Force script to exit if an error occurs
set -e

# Where repository config files will go (read-only and keep untouched)
REPO_CONFIG_PATH="${HOME}/$REPO_DIR"
# Where the user accessable config is located (ie. the one used by Klipper to work)
USER_CONFIG_PATH="${HOME}/printer_data/config"

KIAUH_SRCDIR="${HOME}/kiauh"
# shellcheck source=../kiauh/scripts/globals.sh
source "$KIAUH_SRCDIR"/scripts/globals.sh
# shellcheck source=../kiauh/scripts/utilities.sh
source "$KIAUH_SRCDIR"/scripts/utilities.sh
# shellcheck source=../kiauh/scripts/ui/general_ui.sh
source "$KIAUH_SRCDIR"/scripts/ui/general_ui.sh

set_globals

source "$REPO_CONFIG_PATH"/common/scripts/overrides.sh
