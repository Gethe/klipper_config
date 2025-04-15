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
NAME=$1
DATA=$2

REPO_PATH=~/klipper_config
clone_config() {
    if [ ! -d "$REPO_PATH" ]; then
        git clone https://github.com/Gethe/klipper_config.git

        # Make all script files executable
        find "$REPO_PATH"/ -type f -iname "*.sh" -exec chmod +x {} \;
        source "$REPO_PATH"/common/scripts/utils.sh

        if [[ ! -e "$REPO_PATH"/.git/hooks/post-merge ]]; then
            ln -sf "$REPO_PATH"/common/scripts/update.sh "$REPO_PATH"/.git/hooks/post-merge
            sudo chmod +x "$REPO_PATH"/.git/hooks/post-merge
        fi
    else
        # git -C ~/klipper_config pull
        git -C "$REPO_PATH" pull
    fi

    source "$REPO_PATH"/common/scripts/utils.sh
}

install_plugins() {
    ln -sf "$REPO_PATH"/plugins/*.py ~/klipper/klippy/plugins/
}

function link_config() {
    local data_path=$1
    local config_path=$data_path"/config"

    if [[ $data_path == ~/printer_data ]]; then
        $REPO_PATH/common/scripts/shaketune.sh false "$config_path"
    else
        $REPO_PATH/common/scripts/shaketune.sh "$printer_name" "$config_path"
    fi

    status_msg "Linking config for ${printer_name}"
    ln -sf "$REPO_PATH"/common "$config_path"/common

    local source_path=$2
    ln -sf "$source_path"/.fluidd-theme "$config_path"/.fluidd-theme
    ln -sf "$source_path"/moonraker.conf "$config_path"/_"$printer_name".conf
    ln -sf "$source_path"/printer.cfg "$config_path"/_"$printer_name".cfg
    ln -sf "$source_path"/variables.cfg "$config_path"/_variables.cfg

    cat > "$config_path"/printer.cfg << EOF
[include _$printer_name.cfg]
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

EOF

    cat > "$config_path"/moonraker.conf << EOF
[include _$printer_name.conf]

EOF

    ok_msg "Config linked!!"
}

clone_config
install_plugins

for dir in "$REPO_PATH"/printer_*/; do
    dir=${dir%*/}      # remove the trailing "/"
    printer_name=${dir##*_}     # isolate the name

    if [[ -z $NAME ]]; then
        if [ -d ~/printer_"$printer_name"_data ]; then
            link_config ~/printer_"$printer_name"_data "$dir"
        elif [[ "$printer_name" == "$HOSTNAME" ]]; then
            link_config ~/printer_data "$dir"
        else
            error_msg "Data path for printer \"$printer_name\" could not be automatically determined."
        fi
    else
        if [[ "$printer_name" == "$NAME" ]]; then
            if [[ $DATA ]]; then
                if [ -d "$DATA" ]; then
                    link_config "$DATA" "$dir"
                else
                    error_msg "Data path \"$DATA\" could not be found."
                fi
            elif [ -d ~/printer_"$printer_name"_data ]; then
                link_config ~/printer_"$printer_name"_data "$dir"
            else
                link_config ~/printer_data "$dir"
            fi

            break
        else
            error_msg "Printer \"$NAME\" could not be could not be found."
        fi
    fi
done

ok_msg "Finished installation!"
