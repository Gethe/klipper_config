#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source "$HOME"/custom_config/common/scripts/header.sh

status_msg "Applying config updates..."

sudo cp -r "$CONFIG_DIR"/motd/* /etc/update-motd.d/
sudo cp "$CONFIG_DIR"/"$HOSTNAME"/motd/logo /etc/update-motd.d/logo/logo
sudo chmod a+x /etc/update-motd.d/*

ok_msg "Finished updates!"
