#!/bin/bash -eu

. /etc/os-release

if [[ ${NAME,,} =~ 'ubuntu' ]]; then
    sudo apt-get install -y golang-go
elif [[ ${NAME,,} =~ 'alpine linux' ]]; then
    apk add musl-dev gcc build-base go
else
    echo "Unknown OS: $NAME"
fi
