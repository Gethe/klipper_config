#!/usr/bin/env bash

# Where the user Klipper config is located (ie. the one used by Klipper to work)
USER_CONFIG_PATH="${HOME}/printer_data/config"
# Where repository config files will go (read-only and keep untouched)
REPO_CONFIG_PATH="${HOME}/klipper_config"

hostname=$(hostname -s)
HOST_CONFIG_PATH="$REPO_CONFIG_PATH/$hostname"

# Force script to exit if an error occurs
set -e

# shellcheck source=common/scripts/utils.sh
source "$REPO_CONFIG_PATH"/common/scripts/utils.sh

check_root

install_kiauh() {
    report_status "Installing KIAUH"

    cd ~ && git clone https://github.com/dw-0/kiauh.git
    echo "DangerKlippers/danger-klipper" >> ~/kiauh/klipper_repos.txt

    ~/kiauh/kiauh.sh
}

PRINTER=$(cat <<-END
[include printer_base.cfg
[include variables.cfg

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
install_printer_config() {
    report_status "Installing printer configuration for $hostname"

    chmod -R +x "$REPO_CONFIG_PATH"/common/scripts

    ln -sf "$REPO_CONFIG_PATH"/common "$USER_CONFIG_PATH"/common
    ln -sf "$HOST_CONFIG_PATH"/.theme "$USER_CONFIG_PATH"/.theme

    ln -sf "$HOST_CONFIG_PATH"/variables.cfg "$USER_CONFIG_PATH"/variables.cfg
    ln -sf "$HOST_CONFIG_PATH"/printer.cfg "$USER_CONFIG_PATH"/printer_base.cfg
    ln -sf "$HOST_CONFIG_PATH"/moonraker.conf "$USER_CONFIG_PATH"/moonraker_base.conf

    echo "$PRINTER" >"$USER_CONFIG_PATH"/printer.cfg
    echo "$MOONRAKER" >"$USER_CONFIG_PATH"/moonraker.conf
}

install_kiauh
install_printer_config
