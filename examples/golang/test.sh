#!/bin/bash -eu

grn() { echo -e "\e[1m\e[92m${*^^}\e[39m\e[0m"; }
red() { echo -e "\e[1m\e[91m${*^^}\e[39m\e[0m"; }

runtest() {
    echo -n " * $1 -> "
    out=`go run $1`; shift
    if ! [[ $out == $* ]]; then
        red fail
        echo "expected '$*' but got '$out'"
        exit 1
    fi
    grn pass
}

tests=(
    hello_world.go\ "hello world"
    variables.go\ "variables"
    loop.go\ "01234567"
    arrays.go\ "abc123def"
)

for (( i = 0; i < ${#tests[@]}; i++ )); do
    runtest ${tests[i]}
done
