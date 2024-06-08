#!/usr/bin/env bash

function mcu_build() {
    cd "${KLIPPER_DIR}" || exit
    status_msg "Initializing firmware build ..."

    make clean
    cp -f ~/custom_config/common/boards/btt_skr_mini_e3_v2/firmware.config "${KLIPPER_DIR}/.config"

    status_msg "Building firmware ..."
    make olddefconfig
    make

    ok_msg "Firmware built!"
}

function mcu_flash() {
    local isUpdate=${1}

    if [[ ${isUpdate} ]]; then
        local flash_script="${KLIPPER_DIR}/scripts/flash-sdcard.sh"
        local selected_baud_rate=250000
        local device="/dev/btt-skr-mini-e3-v2"
        local selected_board="btt-skr-mini-e3-v2"

        check_usergroups

        ###flash process
        do_action_service "stop" "klipper"
        if "${flash_script}" -b "${selected_baud_rate}" "${device}" "${selected_board}"; then
            print_confirm "Flashing successfull!"
            log_info "Flash successfull!"
        else
            print_error "Flashing failed!\n Please read the console output above!"
            log_error "Flash failed!"
        fi
        do_action_service "start" "klipper"
    else
        status_msg "This board only supports manual SD card flash on initial install."

        echo "Ensure MCU is powered off and remove SD card."
        echo "Copy klipper.bin to local machine as firmware.bin."
        echo "Move firmware.bin to SD card and insert into MCU."
        echo "Power on MCU and plug connect to Rpi."
    fi
}
