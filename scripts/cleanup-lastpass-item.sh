#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <title>"
    exit 1
fi

/opt/homebrew/bin/lpass ls | grep -i "$1" | head -1
id=$(/opt/homebrew/bin/lpass ls | grep -i "$1" | head -1 |  awk '{print $NF}' | sed 's/\]$//')
if [[ -z ${id:-} ]]; then
    echo "nothing found, exiting"
    exit 1
fi

/opt/homebrew/bin/lpass show $id
if ask delete; then
    /opt/homebrew/bin/lpass rm $id
fi
