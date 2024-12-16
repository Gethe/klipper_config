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

# Script args
PRINTER_NAME=$1
PRINTER_DATA=$2

REPO_PATH=~/klipper_config
clone_config() {
    if [ ! -d "$REPO_PATH" ]; then
        git clone https://github.com/Gethe/klipper_config.git

        # Make all script files executable
        find "$REPO_PATH"/ -type f -iname "*.sh" -exec chmod +x {} \;

        status_msg "Installing git hooks"
        if [[ ! -e "$REPO_PATH"/.git/hooks/post-merge ]]; then
            ln -sf "$REPO_PATH"/common/scripts/update.sh "$REPO_PATH"/.git/hooks/post-merge
            sudo chmod +x "$REPO_PATH"/.git/hooks/post-merge
        fi
    else
        git -C "$REPO_PATH" pull
    fi

    source "$REPO_PATH"/common/scripts/utils.sh
}

setup_ssh_motd() {
    status_msg "Installing console MotD"

    # Disable standard LastLog info
    # There is a bug with `sed -i` that is causing permissions issues, so we are
    # doing it the long way
    sed '/PrintLastLog/cPrintLastLog no' /etc/ssh/sshd_config >tmp
    sudo mv -f tmp /etc/ssh/sshd_config
    chmod 0644 /etc/ssh/sshd_config

    # Disable default static MoTD
    do_action_service disable motd
    sudo rm -rf /etc/motd

    # Disable default dynamic MoTD
    sudo rm -rf /etc/update-motd.d

    sudo mkdir /etc/update-motd.d
    sudo cp -r "$CONFIG_DIR"/motd/* /etc/update-motd.d/

    sudo chmod a+x /etc/update-motd.d/*
    ok_msg "Console MotD installed!!"

    do_action_service restart sshd
}

function link_config() {
    status_msg "Linking config for ${PRINTER_NAME}"

    local data_path=$1
    local config_path=$data_path"/config"

    ln -sf "$REPO_PATH"/common "$config_path"/common

    ln -sf "$REPO_PATH/$PRINTER_NAME"/.fluidd-theme "$config_path"/.fluidd-theme

    ln -sf "$REPO_PATH/$PRINTER_NAME"/moonraker.conf "$config_path"/_"$PRINTER_NAME".conf
    ln -sf "$REPO_PATH/$PRINTER_NAME"/printer.cfg "$config_path"/_"$PRINTER_NAME".cfg
    ln -sf "$REPO_PATH/$PRINTER_NAME"/variables.cfg "$config_path"/_variables.cfg

    echo "$PRINTER" >"$config_path"/printer.cfg
    echo "$MOONRAKER" >"$config_path"/moonraker.conf

    ok_msg "Config linked!!"
}

PRINTER=$(cat <<-END
[include _$PRINTER_NAME.cfg]
[include _variables.cfg]

[gcode_macro _USER_VARIABLES]
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
#*# control = mpc
#*# block_heat_capacity = 18.8963
#*# sensor_responsiveness = 0.108925
#*# ambient_transfer = 0.0889668
#*# fan_ambient_transfer = 0.0889668, 0.158646, 0.163268, 0.166996, 0.174824, 0.178281, 0.181468
#*#
#*# [stepper_z]
#*# position_endstop = 116.575

END
)
MOONRAKER=$(cat <<-END
[include _$PRINTER_NAME.conf]

END
)

clone_config
setup_ssh_motd

if [[ -z $PRINTER_NAME ]]; then
    error_msg "Script must be run with the printer's name to link the config."
else
    if [[ -d "$REPO_PATH"/"$PRINTER_NAME" ]]; then
        if [ -d ~/printer_"$PRINTER_NAME"_data ]; then
            link_config ~/printer_"$PRINTER_NAME"_data
        elif [ -d "$PRINTER_DATA" ]; then
            link_config "$PRINTER_DATA"
        else
            link_config ~/printer_data
        fi
    else
        error_msg "Config directory at \"$REPO_PATH/$PRINTER_NAME\" does not exist."
    fi
fi
