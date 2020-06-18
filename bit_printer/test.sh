#!/bin/bash -eu
# Test a decimal->binary program

progress() { while true; do sleep 1; printf %s .; done }

if [[ $# -ne 1 ]] || [[ ! -x $1 ]]; then
    echo "Usage: ${0##*/} <test_prog>"
    exit 1
fi
test_prog=`realpath $1`

cmp() {
    local res=`$test_prog $1`
    if [[ $res =~ ^0+$ ]]; then
       res=0
    else
        res=$(sed -e 's/^0*//' <<< "$res") # strip leading 0
    fi
    local -r exp=`bc <<< "obase=2; $1"`
    if [[ $res != $exp ]]; then
        echo "failed on $1"
        echo "    res: $res"
        echo "    exp: $exp"
        exit 1
    fi
}

test() {
    for i in `seq 0 1234`; do
        cmp $i
    done

    cmp `bc <<< '2^32'`
    cmp `bc <<< '2^32 + 1'`
    cmp `bc <<< '2^32 - 1'`
}

progress &
progress_pid=$!

echo -n "Testing '$test_prog'"
test

kill $progress_pid >/dev/null 2>&1
echo -e "\e[92mOK\e[39m"
