#!/usr/bin/env bash

cp -f "$CONFIG_DIR"/common/boards/btt_skr_mini_e3_v2/firmware.config ~/klipper/.config

pushd ~/klipper || exit
make olddefconfig
make clean
make

service klipper stop
make flash FLASH_DEVICE=/dev/btt-skr-mini-e3-20
popd || exit
