#!/usr/bin/env bash

function check_root {
    if [ "$EUID" -eq 0 ]; then
        echo "This script must not be run as root!"
        exit 1
    fi
}

function report_status {
    echo -e "\n\n###### $1"
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}
