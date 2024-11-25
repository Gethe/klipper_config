#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source ~/klipper_config/common/scripts/header.sh

function mcu_build() {
    cd "${KLIPPER_DIR}" || exit
    status_msg "Initializing firmware build ..."

    make clean
    cp -f ~/klipper_config/common/boards/btt_octopus/firmware.config "${KLIPPER_DIR}/.config"

    status_msg "Building firmware ..."
    make olddefconfig
    make

    ok_msg "Firmware built!"
}

function mcu_flash() {
    local selected_board="btt-octopus-11"
    local device="/dev/$selected_board"

    check_usergroups

    ###flash process
    do_action_service "stop" "klipper"
    if make flash FLASH_DEVICE="${device}"; then
        ok_msg "Flashing successfull!"
    else
        warn_msg "Flashing failed!"
        warn_msg "Please read the console output above!"
    fi
    do_action_service "start" "klipper"
}
