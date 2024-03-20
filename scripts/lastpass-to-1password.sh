#!/usr/bin/env bash
set -euo pipefail
source ../bash_helpers/common.sh

workdir=./lp-to-op; mkdir -p $workdir
lp=
op=

check_logins() {
    lp_status="$($lp status)" || die "sign into lastpass with '$lp login <email>'"
    #op_status=$($op whoami | grep Email | awk -F) || die "sign into 1password with '$op signin'"
    op_status="$($op whoami)" || die "sign into 1password with '$op signin'"

    # `op whoami | grep Email` = Email:      some.user@google.com
    op_email=$(echo "$op_status" | grep Email | awk '{print $2}')

    # `lp status` = Logged in as some.user@google.com.
    lp_email=$(echo "$lp_status" | awk '{print $NF}' | sed 's/\.$//')

    # TODO confirm both emails, especially if not matching

    echo "1password email: $op_email"
    echo "Lastpass email:  $lp_email"
    ask "Proceed?"
}

op_get_items() {
    local -r urls=$workdir/.op_urls
    local -r skips=$workdir/.op_skips
    : > $urls
    : > $skips
    local -r f=$(mktemp)
    local -a item_ids=($($op item list | tail -n +2 | awk '{print $1}'))
    local id title username password website
    echo "writing ${#item_ids[@]} 1password urls to $urls, and skips to $skips"
    for id in ${item_ids[@]}; do
        $op item get $id > $f
        title=$(grep ^Title $f |  awk -F: '{print $2}' | sed 's/^[[:space:]]*//') ||:
        username=$(grep username $f | awk -F: '{print $2}' | sed 's/^[[:space:]]*//') ||:
        password=$(grep password $f | awk -F: '{print $2}' | sed 's/^[[:space:]]*//') ||:
        website=$(grep website $f | sed -e 's/^website:[[:space:]]*//') ||:
        if [[ -z ${website:-} ]]; then
            echo "${title:-}" >> $skips
            echo -n "S"
            continue
        fi
        echo -n "."
        #echo -n "* title='$title' "
        #echo -n "website='$website' "
        #echo -n "username='$username' "
        #echo -n "password='$password' "
        #echo
        echo "$website" >> $urls
    done
    rm -vf $f
    echo
}

lp_get_items() {
    local -r urls=$workdir/.lp_urls
    local -r skips=$workdir/.lp_skips
    : > $urls
    : > $skips
    local -a item_ids=($($lp ls | grep id | awk '{print $NF}' | sed 's/\]$//'))
    local id title username password website
    echo "writing ${#item_ids[@]} lastpass urls to $urls, and skips to $skips"
    for id in ${item_ids[@]}; do
        title="$($lp show $id --name)" ||:
        username="$($lp show $id --username)" ||:
        password="$($lp show $id --password)" ||:
        website="$($lp show $id --url)" ||:
        if [[ -z ${website:-} ]]; then
            echo "${title:-}" >> $skips
            echo -n "S"
            continue
        fi
        echo -n "."
        #echo -n "* title='$title' "
        #echo -n "website='$website' "
        #echo -n "username='$username' "
        #echo -n "password='$password' "
        #echo
        echo "$website" >> $urls
    done
    echo
}

compare_urls() {
    local -r op_urls=$(mktemp)
    local -r lp_urls=$(mktemp)
    cat $workdir/.op_urls | sed -e 's,http://,,' | sed -e 's,https://,,' | sed 's,/.*,,' | sort -u | awk '{print $1}' > $op_urls
    cat $workdir/.lp_urls | sed -e 's,http://,,' | sed -e 's,https://,,' | sed 's,/.*,,' | sort -u | awk '{print $1}' > $lp_urls
    for u in $(cat $lp_urls); do
        grep -q $u $op_urls || echo "1password is missing $u"
    done
    rm -f $op_urls $lp_urls
}

# Show items:
#     $op item list
#     lp ls

main() {
    lp=$(which lpass)
    op=$(which op)
    if ask "Fetch fresh data?"; then
        echo fetching
        exit 0
        check_logins
        op_get_items
        lp_get_items
    fi
    compare_urls
}

run_main main
