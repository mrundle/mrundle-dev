#!/bin/bash

readonly PHONEDIR=${HOME?}/Desktop/phone
readonly PKGS=(
    libimobiledevice-utils
    ifuse
)
declare -a toinstall=()

function unmount() {
    if grep -qs "$PHONEDIR" /proc/mounts; then
        if fusermount -uz $PHONEDIR; then
            echo "successfully unmounted $PHONEDIR"
        else
            echo "ERROR: failed to unmount $PHONEDIR, please manually unmount"
        fi
    fi
}


function ask() {
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

function main() {
    for pkg in ${PKGS[@]}; do
        if ! dpkg -s $pkg >/dev/null 2>&1; then
            toinstall+=($pkg)
        fi
    done

    if [[ ${#toinstall[@]} -ge 1 ]]; then
        sudo apt install ${toinstall[@]}
    fi

    if ! ideviceinfo >/dev/null 2>&1; then
        echo "something went wrong when testing \`ideviceinfo\`"
        exit 1
    fi

    mkdir -p $PHONEDIR
    ifuse $PHONEDIR

    echo "mounted to $PHONEDIR -- do not disconnect without unmounting first!"
    echo ""
    echo "when this process is killed, the phone will be unmounted via \`fusermount -u $PHONEDIR\`"
    echo

    ask "unmount?" ||:
}

trap unmount EXIT
main $@
