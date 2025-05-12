#!/bin/bash -eu

# Script to install and configure NordVPN on a device.
# Currently only tested on Ubuntu. Should work on any
# Linux/Mac OS with some minor tweaks to ${SUPPORTED_PKGMGRS}
# and potentially the install_nordvpn() function

NORDVPN=nordvpn
PKGMGR=
SUPPORTED_PKGMGRS=(
    apt
)
KILLSWITCH_DESIRED_SETTING=enabled

die() {
    local -r msg="$*"
    echo "error: $msg"
    trap - EXIT
    exit 1
}

check_prog() {
    hash $1 >/dev/null 2>&1
}

check_root() {
    if [[ ${EUID} -ne 0 ]]; then
        die "need root"
    fi
}

check_os() {
    for PKGMGR in ${SUPPORTED_PKGMGRS[@]}; do
        check_prog "$PKGMGR" && return 0
    done
    die "no supported package managers detected (${SUPPORTED_PKGMGRS[@]}), OS not supported"
}

check_nordvpn_installed() {
    check_prog $NORDVPN
}

install_nordvpn() {
    $PKGMGR install nordvpn
}

check_running() {
    $NORDVPN status
}

check_login() {
    local -r info=$($NORDVPN account 2>&1)
    grep -qi email <<<"$info"
}

login() {
    $NORDVPN login
}

check_connected() {
    local -r info=$($NORDVPN status 2>&1)
    ! [[ "$info" =~ [Dd]isconnected ]]
}

connect() {
    $NORDVPN connect
}

str_matches_enabled() {
    str="${*^^}"
    local -a match=(
        "1"
        "ON"
        "TRUE"
        "ENABLE"
        "ENABLED"
    )
    for e in ${match[@]}; do
        [[ "$str" == "$e" ]] && return 0
    done
    return 1
}

str_matches_disabled() {
    str="${*^^}"
    local -a match=(
        "0"
        "OFF"
        "FALSE"
        "DISABLE"
        "DISABLED"
    )
    for e in ${match[@]}; do
        [[ "$str" == "$e" ]] && return 0
    done
    return 1
}

check_killswitch() {
    # get setting
    local debugmsg=""
    local -r want="${KILLSWITCH_DESIRED_SETTING}"
    local -r have="$($NORDVPN settings | grep -i "kill" | awk '{print $NF}')"

    if str_matches_enabled "$want"; then
        str_matches_enabled "$have" && { echo A; return 0; }
    elif str_matches_disabled "$want"; then
        str_matches_disabled "$have" && { echo B; return 0; }
    else
        debugmsg="error: unknown desired killswitch setting '$want'"
        return 1
    fi

    debugmsg="error: want killswitch '$want', have '$have'"
    return 1
}

configure_killswitch() {
    $NORDVPN set killswitch ${KILLSWITCH_DESIRED_SETTING}
}

main() {
    echo -n "checking root access... "
    check_root
    echo OK

    echo -n "checking operating system... "
    check_os
    echo OK

    echo -n "checking $NORDVPN installed... "
    check_nordvpn_installed && echo "OK" || {
        echo "NO, installing... "
        install_nordvpn
    }

    echo -n "checking $NORDVPN logged in... "
    check_login && echo "OK" || {
        echo "NO, logging in... "
        login
        echo "(log in and re-run this program)"
        exit 0
    }

    echo -n "checking $NORDVPN connected... "
    check_connected && echo "OK" || {
        echo "NO, connecting... "
        connect
    }

    echo -n "checking $NORDVPN killswitch ${KILLSWITCH_DESIRED_SETTING}... "
    check_killswitch ${KILLSWITCH_DESIRED_SETTING} && echo "OK" || {
        echo "NO, configuring... "
        configure_killswitch
    }

    echo "all good, nordvpn configured"
}

trap 'echo "error: unexpected exit"' EXIT
main $@
trap - EXIT
