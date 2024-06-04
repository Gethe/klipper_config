#!/usr/bin/env bash

cp -f ~/custom_config/common/boards/btt_skr_mini_e3_v2/firmware.config ~/klipper/.config

do_action_service "stop" "klipper"

pushd ~/klipper || exit
make olddefconfig
make clean
make

read -p "Copy klipper.bin to local machine as firmware.bin. Press [Enter] to continue"
read -p "Move firmware.bin to SD card and insert into MCU. Press [Enter] to continue"

popd || exit
