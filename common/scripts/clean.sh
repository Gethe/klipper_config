#!/usr/bin/env bash

set -xe

# shellcheck source=./common/scripts/header.sh
source "$HOME"/custom_config/common/scripts/header.sh

status_msg "Uninstalling printer config..."


# shellcheck source=../kiauh/scripts/klipper.sh
source "$KIAUH_SRCDIR"/scripts/klipper.sh
# shellcheck source=../kiauh/scripts/mainsail.sh
source "$KIAUH_SRCDIR"/scripts/mainsail.sh
# shellcheck source=../kiauh/scripts/moonraker.sh
source "$KIAUH_SRCDIR"/scripts/moonraker.sh

remove_klipper
remove_mainsail
remove_moonraker

rm -rf printer_data

rm -rf kiauh
rm -rf kiauh-backups
rm -f .kiauh.ini

