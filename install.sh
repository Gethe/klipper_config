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
    if [ ! -d "${CONFIG_DIR}" ] ; then
        git clone git@github.com:Gethe/klipper_config.git custom_config
    else
        git -C "$CONFIG_DIR" pull
    fi
    source "$CONFIG_DIR"/common/scripts/utils.sh
    source "$CONFIG_DIR"/common/scripts/globals.sh
    set_globals

    status_msg "Installing git hooks"
    if [[ ! -e "$CONFIG_DIR"/.git/hooks/post-merge ]]; then
        ln -sf "$CONFIG_DIR"/common/scripts/update.sh "$CONFIG_DIR"/.git/hooks/post-merge
        sudo chmod +x "$CONFIG_DIR"/.git/hooks/post-merge
    fi
}


install_firmware() {
    status_msg "Installing printer firmware"

    set_custom_klipper_repo DangerKlippers/danger-klipper master
    run_klipper_setup 3 "printer"

    moonraker_setup 1

    install_mainsail
}
install_printer_config() {
    echo "config 0"
    status_msg "Installing printer configuration for $HOSTNAME"

    rm -f "$USER_DIR"/printer.cfg
    rm -f "$USER_DIR"/moonraker.conf

    echo "config 1"
    ln -sf "$CONFIG_DIR"/common "$USER_DIR"/common

    ln -sf "$CONFIG_DIR/$HOSTNAME"/moonraker.conf "$USER_DIR"/_"$HOSTNAME".conf
    ln -sf "$CONFIG_DIR/$HOSTNAME"/printer.cfg "$USER_DIR"/_"$HOSTNAME".cfg
    ln -sf "$CONFIG_DIR/$HOSTNAME"/variables.cfg "$USER_DIR"/_variables.cfg

    echo "config 2"
    mkdir "$USER_DIR"/.theme
    for file in "$CONFIG_DIR"/.theme/* "$CONFIG_DIR"/"$HOSTNAME"/.theme/*; do
        ln -sf "$file" "$USER_DIR"/.theme/"${file##/*/}"
    done
    echo "config 3"

    echo "$PRINTER" >"$USER_DIR"/printer.cfg
    echo "$MOONRAKER" >"$USER_DIR"/moonraker.conf
    echo "config 4"
}
install_motd() {
    echo "motd 0"
    status_msg "Installing MOTD files"

    ## Backup existing /etc/ssh/sshd_config
    if [ -f /etc/ssh/sshd_config ]; then
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.1
    fi
    echo "motd 1"

    # Disable standard LastLog info
    # There is a bug with `sed -i` that is causing permissions issues, so we are
    # doing it the long way
    sed '/PrintLastLog/cPrintLastLog no' /etc/ssh/sshd_config >tmp
    sudo mv -f tmp /etc/ssh/sshd_config
    chmod 0644 /etc/ssh/sshd_config

    # Disable default static MoTD
    do_action_service disable motd
    sudo rm -rf /etc/motd
    echo "motd 2"

    # Disable default dynamic MoTD
    sudo rm -rf /etc/update-motd.d

    sudo mkdir /etc/update-motd.d
    sudo cp -r "$CONFIG_DIR"/motd/* /etc/update-motd.d/
    echo "motd 3"

    sudo mkdir /etc/update-motd.d/logo
    sudo cp "$CONFIG_DIR"/"$HOSTNAME"/motd/logo /etc/update-motd.d/logo/logo

    sudo chmod a+x /etc/update-motd.d/*

    do_action_service restart sshd
    echo "motd 4"
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

echo "install_firmware"
install_firmware
echo "install_printer_config"
install_printer_config
echo "install_motd"
install_motd
#source "$CONFIG_DIR"/common/scripts/flash.sh

print_confirm "All done!!"
