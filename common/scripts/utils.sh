#!/usr/bin/env bash

# shellcheck source=../kiauh/scripts/utilities.sh
source "$KIAUH_DIR"/scripts/utilities.sh
# shellcheck source=../kiauh/scripts/ui/general_ui.sh
source "$KIAUH_DIR"/scripts/ui/general_ui.sh

copy_function() {
  test -n "$(declare -f "$1")" || return
  eval "${_/$1/$2}"
}

rename_function() {
  copy_function "$@" || return
  unset -f "$1"
}
