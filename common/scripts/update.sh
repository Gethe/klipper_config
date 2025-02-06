#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source ~/klipper_config/common/scripts/header.sh

status_msg "Applying config updates..."

ln -sf "$REPO_PATH"/plugins/. ~/klipper/plugins
sudo chmod +x ~/klipper/plugins

find "$REPO_PATH"/ -type f -iname "*.sh" -exec chmod +x {} \;
