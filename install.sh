#!/usr/bin/env bash

# Set x for debug
if [[ ${DEBUG} -eq 1 ]]; then
    set -x
fi

# Force script to exit if an error occurs
set -e

if [[ ${EUID} -eq 0 ]]; then
    echo -en "\e[91m"
    echo -e "/=======================================================\\"
    echo -e "|       !!! THIS SCRIPT MUST NOT RUN AS ROOT !!!        |"
    echo -e "|                                                       |"
    echo -e "|        It will ask for credentials as needed.         |"
    echo -e "\=======================================================/"
    echo -en "\e[39m"
    exit 1
fi

update() {
    sudo apt update && sudo apt full-upgrade -y
    sudo apt install -y git figlet </dev/null
}


KIAUH_SRCDIR="${HOME}/kiauh"
clone_kiauh() {
    if [ ! -d "${KIAUH_SRCDIR}" ] ; then
        cd ~ && git clone https://github.com/dw-0/kiauh.git
    else
        git -C "$KIAUH_SRCDIR" pull
    fi
    # shellcheck source=../kiauh/scripts/backup.sh
    source "$KIAUH_SRCDIR"/scripts/backup.sh
    # shellcheck source=../kiauh/scripts/klipper.sh
    source "$KIAUH_SRCDIR"/scripts/klipper.sh
    # shellcheck source=../kiauh/scripts/mainsail.sh
    source "$KIAUH_SRCDIR"/scripts/mainsail.sh
    # shellcheck source=../kiauh/scripts/moonraker.sh
    source "$KIAUH_SRCDIR"/scripts/moonraker.sh
    # shellcheck source=../kiauh/scripts/nginx.sh
    source "$KIAUH_SRCDIR"/scripts/nginx.sh
}

CONFIG_DIR="${HOME}/custom_config"
clone_config() {
    if [ ! -d "${CONFIG_DIR}" ]; then
        git clone https://github.com/Gethe/klipper_config.git custom_config
    else
        git -C "$CONFIG_DIR" pull
    fi

    # Make all script files executable
    find "$CONFIG_DIR"/ -type f -iname "*.sh" -exec chmod +x {} \;
    sudo ln -sf "$CONFIG_DIR"/common/boards/*/*.rules /etc/udev/rules.d/

    source "$CONFIG_DIR"/common/scripts/utils.sh
    source "$CONFIG_DIR"/common/scripts/globals.sh
    source "$CONFIG_DIR"/"$HOSTNAME"/mcu.sh
    set_globals

    status_msg "Installing git hooks"
    if [[ ! -e "$CONFIG_DIR"/.git/hooks/post-merge ]]; then
        ln -sf "$CONFIG_DIR"/common/scripts/update.sh "$CONFIG_DIR"/.git/hooks/post-merge
        sudo chmod +x "$CONFIG_DIR"/.git/hooks/post-merge
    fi
}

klipper_screen=( ruby )
install_firmware() {
    local klipper_systemd_services
    local moonraker_services

    status_msg "Installing printer firmware"

    klipper_systemd_services=$(klipper_systemd)
    if [[ -n ${klipper_systemd_services} ]]; then
        ok_msg "Klipper already installed!"
    else
        set_custom_klipper_repo DangerKlippers/danger-klipper master
        run_klipper_setup 3 "printer"
    fi

    moonraker_services=$(moonraker_systemd)
    if [[ -n ${moonraker_services} ]]; then
        ok_msg "Moonraker already installed!"
    else
        moonraker_setup 1
    fi

    if [ ! -d "${MAINSAIL_DIR}" ]; then
        install_mainsail
    fi

    # wget -O - https://raw.githubusercontent.com/Frix-x/klippain-shaketune/main/install.sh | bash

    if [[ -z ${klipper_screen[$HOSTNAME]} ]]; then
        install_klipperscreen
    fi

    mcu_build
    mcu_flash
}


PRINTER=$(cat <<-END
[include _$HOSTNAME.cfg]
[include _variables.cfg]

[gcode_macro VARS]
gcode:

#*# <---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
#*# [heater_bed]
#*# control = pid
#*# pid_kp = 64.136
#*# pid_ki = 2.117
#*# pid_kd = 485.827
#*#
#*# [extruder]
#*# control = pid
#*# pid_kp = 22.525
#*# pid_ki = 1.146
#*# pid_kd = 110.652
#*#
#*# [stepper_z]
#*# position_endstop = 116.575

END
)
MOONRAKER=$(cat <<-END
[include _$HOSTNAME.conf]

END
)


update
clone_kiauh
clone_config

install_firmware

print_confirm "All done!!"
