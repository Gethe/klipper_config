#!/usr/bin/env bash

set -xe

KIAUH_DIR="${HOME}/kiauh"

# shellcheck source=../kiauh/scripts/globals.sh
source "$KIAUH_DIR"/scripts/globals.sh
# shellcheck source=../kiauh/scripts/utilities.sh
source "$KIAUH_DIR"/scripts/utilities.sh
# shellcheck source=../kiauh/scripts/klipper.sh
source "$KIAUH_DIR"/scripts/klipper.sh
# shellcheck source=../kiauh/scripts/mainsail.sh
source "$KIAUH_DIR"/scripts/mainsail.sh
# shellcheck source=../kiauh/scripts/moonraker.sh
source "$KIAUH_DIR"/scripts/moonraker.sh

remove_klipper
remove_mainsail
remove_moonraker

rm -rf printer_data

rm -rf kiauh
rm -rf kiauh-backups
rm -f .kiauh.ini

