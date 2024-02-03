#!/usr/bin/env bash

cp -f "$CONFIG_DIR"/common/boards/btt_octopus/firmware.config /home/pi/klipper/.config
cd /home/pi/klipper || exit
make olddefconfig
make clean
make

make flash FLASH_DEVICE=/dev/btt-octopus-11
