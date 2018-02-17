#!/bin/bash -eu

pass() { echo -e "\e[1m\e[92mPASS\e[39m\e[8m"; }
fail() { echo -e "\e[1m\e[91mFAIL\e[39m\e[8m"; }

runtest() {
    echo -n "$1 "
    out=`go run $1`; shift
    if ! [[ $out == $* ]]; then
        fail
        echo "expected '$*' but got '$out'"
        exit 1
    fi
    pass
}

tests=(
    hello_world.go\ "hello world"
)

for (( i = 0; i < ${#tests[@]}; i++ )); do
    runtest ${tests[i]}
done

fail
