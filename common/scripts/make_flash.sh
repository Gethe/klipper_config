#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source ~/klipper_config/common/scripts/header.sh

function mcu_build() {
    local mcu_name=${1}

    cd "${KLIPPER_DIR}" || exit
    status_msg "Initializing firmware build ..."

    make clean
    cp -f ~/klipper_config/common/boards/"${mcu_name}"/firmware.config "${KLIPPER_DIR}/.config"

    status_msg "Building firmware ..."
    make olddefconfig
    make

    ok_msg "Firmware built!"
}

function mcu_flash() {
    local mcu_path=${1}

    check_usergroups

    ###flash process
    do_action_service "stop" "klipper"
    if make flash FLASH_DEVICE="${mcu_path}"; then
        ok_msg "Flashing successfull!"
    else
        warn_msg "Flashing failed!"
        warn_msg "Please read the console output above!"
    fi
    do_action_service "start" "klipper"
}

function mcu_flash_sd() {
    local baud_rate=${1}
    local mcu_path=${2}
    local board_type=${3}

    local flash_script="${KLIPPER_DIR}/scripts/flash-sdcard.sh"

    check_usergroups

    ###flash process
    do_action_service "stop" "klipper"
    if "${flash_script}" -b "${baud_rate}" "${mcu_path}" "${board_type}"; then
        print_confirm "Flashing successfull!"
        log_info "Flash successfull!"
    else
        print_error "Flashing failed!\n Please read the console output above!"
        log_error "Flash failed!"
    fi
    do_action_service "start" "klipper"
}
