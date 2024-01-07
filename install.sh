#!/usr/bin/env bash

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


CONFIG_DIR_NAME="custom_config"
# Where repository config files will go (read-only and keep untouched)
CONFIG_DIR="${HOME}/$CONFIG_DIR_NAME"
# Where the user accessable config is located (ie. the one used by Klipper to work)
USER_DIR="${HOME}/printer_data/config"


KIAUH_DIR="${HOME}/kiauh"
if [ ! -d "${KIAUH_DIR}" ] ; then
    cd ~ && git clone https://github.com/dw-0/kiauh.git
fi
# shellcheck source=../kiauh/scripts/backup.sh
source "$KIAUH_DIR"/scripts/backup.sh
# shellcheck source=../kiauh/scripts/klipper.sh
source "$KIAUH_DIR"/scripts/klipper.sh
# shellcheck source=../kiauh/scripts/mainsail.sh
source "$KIAUH_DIR"/scripts/mainsail.sh
# shellcheck source=../kiauh/scripts/moonraker.sh
source "$KIAUH_DIR"/scripts/moonraker.sh
# shellcheck source=../kiauh/scripts/nginx.sh
source "$KIAUH_DIR"/scripts/nginx.sh


if [ ! -d "${CONFIG_DIR}" ] ; then
    git clone git@github.com:Gethe/klipper_config.git "$CONFIG_DIR_NAME"
fi
source "$CONFIG_DIR"/common/scripts/utils.sh
source "$CONFIG_DIR"/common/scripts/globals.sh
set_globals

status_msg "Installing git hooks"
if [[ ! -e "$CONFIG_DIR"/.git/hooks/post-merge ]]; then
    ln -sf "$CONFIG_DIR"/common/scripts/update.sh "$CONFIG_DIR"/.git/hooks/post-merge
    sudo chmod +x "$CONFIG_DIR"/.git/hooks/post-merge
fi


install_firmware() {
    status_msg "Installing printer firmware"

    set_custom_klipper_repo DangerKlippers/danger-klipper master
    run_klipper_setup 3 "printer"

    moonraker_setup 1

    install_mainsail
}
install_printer_config() {
    status_msg "Installing printer configuration for $HOSTNAME"

    rm -f "$USER_DIR"/printer.cfg
    rm -f "$USER_DIR"/moonraker.conf

    ln -sf "$CONFIG_DIR"/common "$USER_DIR"/common

    ln -sf "$CONFIG_DIR/$HOSTNAME"/moonraker.conf "$USER_DIR"/_"$HOSTNAME".conf
    ln -sf "$CONFIG_DIR/$HOSTNAME"/printer.cfg "$USER_DIR"/_"$HOSTNAME".cfg
    ln -sf "$CONFIG_DIR/$HOSTNAME"/variables.cfg "$USER_DIR"/_variables.cfg

    for file in "$CONFIG_DIR"/.theme/* "$CONFIG_DIR"/"$HOSTNAME"/.theme/*; do
        ln -sf "$file" "$USER_DIR"/.theme/"${file##/*/}"
    done

    echo "$PRINTER" >"$USER_DIR"/printer.cfg
    echo "$MOONRAKER" >"$USER_DIR"/moonraker.conf

    print_confirm "All done!!"
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


install_firmware
install_printer_config
source "$CONFIG_DIR"/common/scripts/flash.sh
