#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source "$HOME"/custom_config/common/scripts/header.sh

status_msg "Applying config updates..."

find "$CONFIG_DIR"/ -type f -iname "*.sh" -exec chmod +x {} \;

ok_msg "Finished updates!"
