#!/bin/bash -eu

. /etc/os-release

if [[ ${NAME,,} =~ ubuntu ]]; then
    sudo apt-get install -y golang-go
else
    echo "Unknown OS: $NAME"
fi
