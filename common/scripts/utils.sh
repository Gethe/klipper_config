#!/usr/bin/env bash

# shellcheck source=../kiauh/scripts/utilities.sh
source ~/kiauh/scripts/utilities.sh
# shellcheck source=../kiauh/scripts/ui/general_ui.sh
source ~/kiauh/scripts/ui/general_ui.sh

rename_function() {
    local ORIG_FUNC
    ORIG_FUNC=$(declare -f "$1")
    local NEWNAME_FUNC="$2${ORIG_FUNC#"$1"}"
    eval "$NEWNAME_FUNC"
}
