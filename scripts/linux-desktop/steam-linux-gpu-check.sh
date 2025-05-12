#!/bin/bash -eu

################################################################################
#
#    hardcoded config; specify expected gpu and Steam directory
#

readonly EXPECTED_GPU="RADEON RX 6600"
readonly STEAM_USERDATA_DIR="${HOME?}/snap/steam/common/.local/share/Steam/userdata"

################################################################################
#
#    INFO/SUMMARY/WHAT-IS-THIS-THING-AGAIN
#
# This script is meant to be a quick sanity-test for Steam/dGPU settings on
# Linux, specifically regarding the forcing a game/games to run on the discrete
# card rather than integrated CPU graphics.
#
# It's tailored to the setup of AMD CPU+GPU running on Ubuntu. It probably works
# with a bunch of other Linux distros, but guessing not with an Nvidia GPU.
#
# On my machine, despite plugging the monitor into the physical GPU port,
# Ubuntu will still sometimes use integrated graphics by default. This ends up
# meaning that Steam will launch games on the CPU's much weaker integrated
# graphics card, which results in poor performance across the board but
# especially for games like Factorio.
#
# Steam allows you to go in and edit a game's launch parameters (game > settings
# > launch options) and add a string like "DRI_PRIME=0 %command%", where 0
# stands in for the index of the graphics card that the game will be launched
# on.
#
# Unfortunately, it appears that this index isn't particularly stable across
# reboots. Sometimes the integrated graphics is at index 0, sometimes the
# dedicated card is at index 0.
#
# This script just checks the steam config against what the index actually
# points to. At this point, I'm not sure if it can be programatically updated
# (i.e. if writing the file is enough to officially change the setting), so
# really it's still a manual fix through the Steam UI if the script detects
# an issue. But it's still useful because these commands are difficult to
# remember.
#
# My machine details for reference:
#
#  ====================[ CPU ]==================================================
#  |
#  |    $ lscpu | grep -i 'model name'
#  |    Model name:                           AMD Ryzen 7 9800X3D 8-Core Processor
#  |
#  ====================[ GPU ]==================================================
#  |
#  |    $ lspci | grep -i vga
#  |    03:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 23 [Radeon RX 6600/6600 XT/6600M] (rev c7)
#  |    12:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Device 13c0 (rev cb)
#  |
#  ====================[ OS  ]==================================================
#  |
#  |    $ uname -srv
#  |    Linux 6.11.0-21-generic #21~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Mon Feb 24 16:52:15 UTC 2
#  |
#  ====================[ Utils  ]===============================================
#  |
#  |    $ dpkg --search /usr/bin/glxinfo
#  |    mesa-utils: /usr/bin/glxinfo
#  |
#  |    $ dpkg --search /usr/bin/snap
#  |    snapd: /usr/bin/snap
#  |
#  |    $ snap list steam
#  |    Name   Version   Rev  Tracking       Publisher   Notes
#  |    steam  1.0.0.81  206  latest/stable  canonical✓  -
#
# References:
#   * https://docs.mesa3d.org/envvars.html#envvar-DRI_PRIME
#   * https://wiki.archlinux.org/title/PRIME
#   * https://starbeamrainbowlabs.com/blog/article.php?article=posts%2F254-run-program-on-amd-dedicated-graphics-card.html
#   * https://help.steampowered.com/en/faqs/view/7D01-D2DD-D75E-2955


################################################################################
#
#   helper functions
#

function errmsg() { echo "[error]  $@" >&2; }
function die() { errmsg "$@"; trap - EXIT; exit 1; }

function set_steam_config_path() {
    if ! [[ -d ${STEAM_USERDATA_DIR:-} ]]; then
        errmsg "couldn't locate steam userdata directory at '${STEAM_USERDATA_DIR:-}'"
        return 1
    fi
    if [[ -z ${STEAM_USERID:-} ]]; then
        # try to infer userid
        local -a users=($(ls "${STEAM_USERDATA_DIR:-}"))
        local -i n_users=${#users[@]}
        if [[ ${n_users} -ne 1 ]]; then
            errmsg "expected 1 local user, found $n_users"
            errmsg "cannot infer userid, please specify like \`export STEAM_USERID=123456789\`"
            errmsg ""
            errmsg "options: ${users[@]}"
            return 1
        fi
        export STEAM_USERID=${users[0]}
    fi
    local -r userdir="${STEAM_USERDATA_DIR}/${STEAM_USERID}"
    if ! [[ -d "${userdir}" ]]; then
        errmsg "no userdata directory found for user at ${userdir}"
        return 1
    fi
    export STEAM_CONFIG="${userdir}/config/localconfig.vdf"
}

function get_steam_dri_config() {
    egrep -oE 'DRI_PRIME=[^ ]+' "${STEAM_CONFIG}"
}

function check_steam_config_exists() {
    [[ -f ${STEAM_CONFIG?} ]]
}

function check_steam_config_has_dri_prime() {
    get_steam_dri_config >/dev/null 2>&1
}

function check_glxinfo_installed() {
    if ! hash dpkg >/dev/null 2>&1; then
        errmsg "missing 'dpkg'.. this script won't work for this environment"
        return 1
    fi
    if ! dpkg -s mesa-utils >/dev/null 2>&1; then
        errmsg "'mesa-utils', which provides glxinfo, isn't installed; try \`sudo apt install mesa-utils\`"
        return 1
    fi
    hash glxinfo
}

function get_glxinfo() {
    local -r idx="$1"
    DRI_PRIME="$idx" glxinfo | grep -i 'opengl render' | sed -r 's/^.*: //'
}

################################################################################
#
#   main function
#

function main()
{
    set_steam_config_path || \
        die "failed to find steam config, aborting"

    check_steam_config_exists || \
        die "couldn't find steam config @ '${STEAM_CONFIG}'"

    check_steam_config_has_dri_prime || \
        die "DRI_PRIME not set in config @ '${STEAM_CONFIG}'"

    check_glxinfo_installed || \
        die "glxinfo not installed"

    local -r idx=$(get_steam_dri_config | awk -F'=' '{print $2}')
    local -r glxinfo="$(get_glxinfo \"${idx}\")"

    if ! [[ ${glxinfo^^} =~ ${EXPECTED_GPU^^} ]]; then
        errmsg "steam gpu mismatch detected; one or more games is setting DRI_PRIME=${idx}, which per 'glxinfo' does not match expected GPU"
        errmsg ""
        errmsg "expected at index ${idx}:"
        errmsg ""
        errmsg "    ${EXPECTED_GPU}"
        errmsg ""
        errmsg "actual found (\`DRI_PRIME=${idx} glxinfo | grep -i 'opengl render'\`):"
        errmsg ""
        errmsg "    ${glxinfo}"
        errmsg ""
        die "exiting error"
    fi

    echo -e "success! configured correctly as 'DRI_PRIME=${idx}'\n"
    echo -e "    using card: ${glxinfo}\n"
}

################################################################################
#
#   entry point
#

trap 'die unexpected exit' EXIT
main $@
trap - EXIT
