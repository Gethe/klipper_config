#!/usr/bin/env bash

hostname=$(hostname -s)
REPO_DIR="custom_config"

# Where repository config files will go (read-only and keep untouched)
REPO_CONFIG_PATH="${HOME}/$REPO_DIR"
# Repo sub-path for specific printer config files
HOST_CONFIG_PATH="$REPO_CONFIG_PATH/$hostname"
# Where the user accessable config is located (ie. the one used by Klipper to work)
USER_CONFIG_PATH="${HOME}/printer_data/config"


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


sudo apt update && sudo apt full-upgrade -y
sudo apt install git -y


KIAUH_SRCDIR="${HOME}/kiauh"
if [ ! -d "${KIAUH_SRCDIR}" ] ; then
    cd ~ && git clone https://github.com/dw-0/kiauh.git
fi

if [ ! -d "${REPO_CONFIG_PATH}" ] ; then
    git clone git@github.com:Gethe/klipper_config.git $REPO_DIR
fi


source "$REPO_CONFIG_PATH"/common/scripts/utils.sh

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

set_globals

source "$REPO_CONFIG_PATH"/common/scripts/overrides.sh


install_firmware() {
    status_msg "Installing printer firmware"

    set_custom_klipper_repo DangerKlippers/danger-klipper master
    run_klipper_setup 3 "printer"

    moonraker_setup 1

    install_mainsail
}
install_printer_config() {
    status_msg "Installing printer configuration for $hostname"

    rm -f "$USER_CONFIG_PATH"/printer.cfg
    rm -f "$USER_CONFIG_PATH"/moonraker.conf

    ln -sf "$REPO_CONFIG_PATH"/common "$USER_CONFIG_PATH"/common
    ln -sf "$HOST_CONFIG_PATH"/.theme "$USER_CONFIG_PATH"/.theme

    ln -sf "$HOST_CONFIG_PATH"/variables.cfg "$USER_CONFIG_PATH"/variables.cfg
    ln -sf "$HOST_CONFIG_PATH"/printer.cfg "$USER_CONFIG_PATH"/printer_base.cfg
    ln -sf "$HOST_CONFIG_PATH"/moonraker.conf "$USER_CONFIG_PATH"/moonraker_base.conf

    echo "$PRINTER" >"$USER_CONFIG_PATH"/printer.cfg
    echo "$MOONRAKER" >"$USER_CONFIG_PATH"/moonraker.conf

    print_confirm "All done!!"
}


PRINTER=$(cat <<-END
[include printer_base.cfg]
[include variables.cfg]

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
[include moonraker_base.conf]

END

)


install_firmware
install_printer_config
source "$REPO_CONFIG_PATH"/common/scripts/flash.sh
