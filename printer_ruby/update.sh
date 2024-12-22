#!/usr/bin/env bash

# from ~/ run:
# ./klipper_config/printer_ruby/update.sh

# shellcheck source=./common/scripts/make_flash.sh
source ~/klipper_config/common/scripts/make_flash.sh

mcu_build btt_octopus
mcu_flash /dev/serial/by-path/usb-path
