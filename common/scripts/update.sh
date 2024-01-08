#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source "$HOME"/custom_config/common/scripts/header.sh

status_msg "Applying config updates..."


sudo rm -rf /etc/motd
sudo rm -rf /etc/update-motd.d

sudo mkdir /etc/update-motd.d
sudo cp -r $CONFIG_DIR/motd/* /etc/update-motd.d/
sudo chmod a+x /etc/update-motd.d/*

sudo mkdir /etc/update-motd.d/logo
sudo cp "$CONFIG_DIR"/"$HOSTNAME"/motd/logo /etc/update-motd.d/logo/logo

print_confirm "All done!!"
