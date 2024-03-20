#!/usr/bin/env bash

# colors (light)
CLR_NONE='\033[00m'
CLR_RED='\033[01;91m'
CLR_GREEN='\033[01;92m'
CLR_YELLOW='\033[01;93m'
CLR_BLUE='\033[01;94m'
CLR_PURPLE='\033[01;95m'
CLR_CYAN='\033[01;96m'
CLR_WHITE='\033[01;97m'

to_upper() { echo "$@" | tr '[:lower:]' '[:upper:]'; }
to_lower() { echo "$@" | tr '[:upper:]' '[:lower:]'; }

_log() {
    local -r lvl="$(to_upper $1)"; shift
    local -r msg="$@"
    local -r ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    local clr=
    [[ $lvl == WARN ]] && clr=$CLR_YELLOW
    [[ $lvl == ERROR ]] && clr=$CLR_RED
    echo -e "$ts [${clr:-}${lvl}${CLR_NONE}] $msg"
}
log_info()  { _log INFO  "$@"             ;}
log_warn()  { _log WARN  "$@" >&2         ;}
log_error() { _log ERROR "$@" >&2         ;}
die()       { _log ERROR "$@" >&2; exit 1 ;}

ask() {
    prompt="$@ (y/n): "
    while true; do
        read -p "$prompt" resp
        case $resp in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "\n$prompt";;
        esac
    done
}

set_exit_trap() {
    trap "log_error 'unexpected error'" EXIT
}

rm_exit_trap() {
    trap - EXIT
}

run_main() {
    local -r args="$@"
    set_exit_trap
    $args
    rm_exit_trap
}
