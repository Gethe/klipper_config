#!/usr/bin/env bash

# shellcheck disable=SC2034

# Force script to exit if an error occurs
set -e

# shellcheck source=../kiauh/scripts/globals.sh
source ~/kiauh/scripts/globals.sh

# KIAUH overrides #

# Install our files instead of stock
function write_example_printer_cfg() {
    status_msg "Creating printer.cfg in ${USER_DIR} ..."

    ln -sf "$CONFIG_DIR/$HOSTNAME"/printer.cfg "$USER_DIR"/_"$HOSTNAME".cfg
    ln -sf "$CONFIG_DIR/$HOSTNAME"/variables.cfg "$USER_DIR"/_variables.cfg

    echo "$PRINTER" >"$USER_DIR"/printer.cfg

    ok_msg "printer.cfg created!"
}
function create_moonraker_conf() {
    status_msg "Creating moonraker.conf in ${USER_DIR} ..."

    ln -sf "$CONFIG_DIR/$HOSTNAME"/moonraker.conf "$USER_DIR"/_"$HOSTNAME".conf
    echo "$MOONRAKER" >"$USER_DIR"/moonraker.conf

    ok_msg "moonraker.conf created!"
}
function install_mainsail_macros() {
    status_msg "Installing printer configuration for $HOSTNAME"

    ln -sf "$CONFIG_DIR"/common/boards/*/*.rules /etc/udev/rules.d/
    ln -sf "$CONFIG_DIR"/common "$USER_DIR"/common
    ok_msg "config files installed!"

    status_msg "Installing Mainsail theme for $HOSTNAME"
    mkdir "$USER_DIR"/.theme
    for file in "$CONFIG_DIR"/.theme/* "$CONFIG_DIR"/"$HOSTNAME"/.theme/*; do
        ln -sf "$file" "$USER_DIR"/.theme/"${file##/*/}"
    done

    ## Backup existing /etc/ssh/sshd_config
    if [ -f /etc/ssh/sshd_config ]; then
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.1
    fi

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

    sudo mkdir /etc/update-motd.d/logo
    sudo cp "$CONFIG_DIR"/"$HOSTNAME"/motd/logo /etc/update-motd.d/logo/logo

    sudo chmod a+x /etc/update-motd.d/*
    ok_msg "Theme installation complete!"

    do_action_service restart sshd
}
function patch_mainsail_update_manager() {
    true;
}
function patch_klipperscreen_update_manager() {
    true;
}

# Always add user to identified groups
function check_usergroups() {
  local group_dialout group_tty

  if grep -q "dialout" </etc/group && ! grep -q "dialout" <(groups "${USER}"); then
    group_dialout="false"
  fi

  if grep -q "tty" </etc/group && ! grep -q "tty" <(groups "${USER}"); then
    group_tty="false"
  fi

  if [[ ${group_dialout} == "false" || ${group_tty} == "false" ]] ; then
    status_msg "Adding user '${USER}' to group(s) ..."
    if [[ ${group_tty} == "false" ]]; then
        sudo usermod -a -G tty "${USER}" && ok_msg "Group 'tty' assigned!"
    fi
    if [[ ${group_dialout} == "false" ]]; then
        sudo usermod -a -G dialout "${USER}" && ok_msg "Group 'dialout' assigned!"
    fi
    ok_msg "Remember to relog/restart this machine for the group(s) to be applied!"
  fi
}

rename_function set_globals base_set_globals
function set_globals() {
    KIAUH_SRCDIR=~/kiauh
    base_set_globals

    HOSTNAME=$(hostname -s)
    USER_DIR=~/printer_data/config

    # Base Colors #
    red=$(echo -en "\e[91m")
    yellow=$(echo -en "\e[93m")
    green=$(echo -en "\e[92m")
    cyan=$(echo -en "\e[96m")
    magenta=$(echo -en "\e[35m")

    white=$(echo -en "\e[39m")
    grey1=$(echo -en "\e[38;5;249m")
    grey2=$(echo -en "\e[38;5;244m")
    grey3=$(echo -en "\e[38;5;238m")
    black=$(echo -en "\e[38;5;232m")
    clear=$(echo -en "\e[0m")

    # Printer Colors #
    ruby=$(echo -en "\e[38;5;88m")
}
