#!/bin/awk -f

function debug(str) {
    print(str)
}

BEGIN {
    parsed = 0
    skipped = 0
}

/^.*$/ {
    parsed += 1
}

/^ *skip *$/ {
    skipped += 1
    next # do not process further
}

/^[a-zA-Z ]+$/ {
    debug("starts with letters, and is only letters: '" $0 "'")
}

/^[a-zA-Z\s].*[0-9]/ {
    debug("starts with letters, but also has numbers: '" $0 "'")
}

/^[0-9]/ {
    debug("starts with a number: " $0)
}

END {
    debug("parsed " parsed ", skipped " skipped)
}
