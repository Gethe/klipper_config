#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source "$HOME"/custom_config/common/scripts/header.sh
source ~/kiauh/scripts/flash_klipper.sh

check_usergroups

"$CONFIG_DIR"/common/boards/btt_skr_mini_e3_v2/make_flash.sh
