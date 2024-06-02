#!/usr/bin/env bash

cp -f ~/custom_config/common/boards/btt_octopus/firmware.config ~/klipper/.config

pushd ~/klipper || exit
make olddefconfig
make clean
make

service klipper stop
make flash FLASH_DEVICE=/dev/btt-octopus-11
popd || exit
