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
REPO=$1

update() {
    sudo apt update && sudo apt full-upgrade -y
}

install_deps() {
    sudo apt install -y git figlet </dev/null
}

clone_repos() {
    cd ~

    git clone https://github.com/dw-0/kiauh.git
    cp ./kiauh/default.kiauh.cfg ./kiauh/kiauh.cfg
    sed -i 's|Klipper3d/klipper|KalicoCrew/kalico, main|g' ./kiauh/kiauh.cfg

    git clone https://github.com/KalicoCrew/kalico.git ~/klipper
    git clone https://github.com/Arksine/moonraker.git
    git clone https://github.com/fluidd-core/fluidd.git

    if ssh -q git@github.com; [ $? -eq 255 ]; then
        # not authenticated, use https
        git clone "https://github.com/$REPO.git" ~/klipper_config
    else
        echo "ssh authenticated!!"
        git clone "git@github.com:$REPO.git" ~/klipper_config
    fi

    # shellcheck source=./common/scripts/utils.sh
    source ~/klipper_config/common/scripts/utils.sh
}

setup_ssh_motd() {
    if [ -d /etc/update-motd.d/logo ]; then
        status_msg "Console MotD already installed, skipping..."
    else
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
        sudo cp -r "$REPO_PATH"/motd/. /etc/update-motd.d

        sudo chmod a+x /etc/update-motd.d/*
        ok_msg "Console MotD installed!!"

        do_action_service restart sshd
    fi
}


update
install_deps
clone_repos
setup_ssh_motd

./kiauh/kiauh.sh
