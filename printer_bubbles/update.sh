#!/usr/bin/env bash

# from ~/ run:
# ./klipper_config/printer_bubbles/update.sh

# shellcheck source=./common/scripts/make_flash.sh
source ~/klipper_config/common/scripts/make_flash.sh

mcu_build btt_skr_mini_e3_v2
mcu_flash_sd 115200 /dev/serial/by-path/pci-0000:00:1d.0-usb-0:1.2:1.0 btt-skr-mini-e3-v2
