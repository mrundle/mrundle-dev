#!/bin/bash -eu

grn() { echo -e "\e[1m\e[92m${*^^}\e[39m\e[0m"; }
red() { echo -e "\e[1m\e[91m${*^^}\e[39m\e[0m"; }

runtest() {
    echo -n " * $1 -> "
    local prog=${1%%.rs}.run
    local out=`rustc $1 -o $prog && ./$prog`; shift
    if ! [[ $out == $* ]]; then
        red fail
        echo "expected '$*' but got '$out'"
        exit 1
    fi
    grn pass
}

tests=(
    hello_world.rs\ "hello world"
    hello_macro.rs\ "hello macro"
)

for (( i = 0; i < ${#tests[@]}; i++ )); do
    runtest ${tests[i]}
done
