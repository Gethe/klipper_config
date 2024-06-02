#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source "$HOME"/custom_config/common/scripts/header.sh

status_msg "Flashing firmware..."


# shellcheck source=../kiauh/scripts/flash_klipper.sh
source "$KIAUH_SRCDIR"/scripts/flash_klipper.sh
