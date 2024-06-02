#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source "$HOME"/custom_config/common/scripts/header.sh

"$CONFIG_DIR"/common/boards/btt_octopus/make_flash.sh
