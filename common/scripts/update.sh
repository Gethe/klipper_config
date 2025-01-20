#!/usr/bin/env bash

# shellcheck source=./common/scripts/header.sh
source ~/klipper_config/common/scripts/header.sh

status_msg "Applying config updates..."

function update_links() {
    status_msg "Updating links for ${printer_name}"

    local data_path=$1
    local config_path=$data_path"/config"

    local source_path=$2

    ln -sf "$source_path"/.fluidd-theme "$config_path"/.fluidd-theme
    ln -sf "$source_path"/moonraker.conf "$config_path"/_"$printer_name".conf
    ln -sf "$source_path"/printer.cfg "$config_path"/_"$printer_name".cfg
    ln -sf "$source_path"/variables.cfg "$config_path"/_variables.cfg

    ok_msg "Links updated!!"
}

find "$REPO_PATH"/ -type f -iname "*.sh" -exec chmod +x {} \;

for dir in "$REPO_PATH"/printer_*/; do
    dir=${dir%*/}      # remove the trailing "/"
    printer_name=${dir##*_}     # isolate the name

    if [[ -z $NAME ]]; then
        if [ -d ~/printer_"$printer_name"_data ]; then
            update_links ~/printer_"$printer_name"_data "$dir"
        else
            error_msg "Data path for printer \"$printer_name\" could not be automatically determined."
        fi
    elif [[ $NAME == "$printer_name" ]]; then
        if [[ $DATA ]]; then
            if [ -d "$DATA" ]; then
                update_links "$DATA" "$dir"
            else
                error_msg "Data path \"$DATA\" could not be found."
            fi
        elif [ -d ~/printer_"$NAME"_data ]; then
            update_links ~/printer_"$NAME"_data "$dir"
        else
            update_links ~/printer_data "$dir"
        fi

        break
    fi
done

ok_msg "Finished updates!"
