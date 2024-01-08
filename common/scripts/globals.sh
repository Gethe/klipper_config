#!/usr/bin/env bash

# shellcheck disable=SC2034

# Force script to exit if an error occurs
set -e

# shellcheck source=../kiauh/scripts/globals.sh
source ~/kiauh/scripts/globals.sh

# KIAUH overrides #
function install_mainsail_macros() {
    echo "No mainsail macros"
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
