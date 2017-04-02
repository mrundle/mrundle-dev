# .bash_profile

email_address=m.n.rundle@gmail.com

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

setup_git() {
    git config --global user.email "$email_address"
    git config --global user.name "Matt Rundle"
}

setup_ssh() {
    if [ -z "$SSH_AUTH_SOCK" ] ; then
        eval `ssh-agent -s`
        ssh-add
    fi
}

setup_notetaker() {
    export NOTE_DIR=~/notes
    # Allows you to type "note reason", which will open file
    # called $NOTE_DIR/2016-03-01_reason in vim. Subsequent
    # calls will be names with prefixes .1, .2, etc.
    # After saving the note, it will send you an email
    note() {
        if [ $# -eq 0 ]; then
            echo "usage: ${FUNCNAME[0]} <title>" && exit 1
        elif [ -z $NOTE_DIR ]; then
            echo "NOTE_DIR not defined" && exit 1
        elif [ ! -d $NOTE_DIR ]; then
            mkdir $NOTE_DIR || exit 1
        fi

        title_message=""
        for arg in "$@"; do
            title_message="${title_message}_$arg"
        done

        suffix=""
        suffix_ctr=0
        filename_base="$(date +%m-%d-%Y)$title_message"
        while [ -f "${NOTE_DIR}/${filename_base}${suffix}" ]; do
            ((suffix_ctr++))
            suffix=".${suffix_ctr}"
        done

        filename="${NOTE_DIR}/${filename_base}${suffix}"
        vim $filename
        if [ -f "$filename" ]; then
            tmpmail=/tmp/tmp.mail
            echo "Subject: [note] $@" > $tmpmail
            cat $filename >> $tmpmail
            sendmail $email_address < $tmpmail
        fi
    }
    export -f note
}

setup_tmux() {
    alias tls="tmux ls"
    alias tl="tls"
    alias tnew="tmux new -s"
    alias tn="tnew"
    alias tkill="tmux kill-session -t"
    alias tk="tkill"
    alias tattach="tmux attach -dt"
    alias ta="tattach"
}

setup_prompt() {
    bold="\e[1m"
    red="\e[31m"
    green="\e[32m"
    yellow="\e[33m"
    cyan="\e[36m"
    reset='$(tput sgr0)'
    dir="\w"
    return_color='$([ $? -eq 0 ] && echo "'$green'" || echo "'$red'")'
    username="\u"
    export TZ=America/Los_Angeles
    current_time="\A"
    if [ -e ~/.host ]; then host_string=" $(cat ~/.host)" ; else host_string="" ; fi
    PS1="${bold}${return_color}${username} ${current_time}${cyan}${host_string} ${yellow}${dir}${reset}\\n$ "
}

setup_grep() {
    strjoin() { local IFS="$1"; shift; echo "$*"; }
    alias grepv="grep -viE '(binary|build)'" # filter out common annoyances
    rgrep() {
        if [ $# -eq 0 ]; then
            echo "usage: ${FUNCNAME[0]} regex1 ... regexN"
            return 1
        fi
        grep -nrE "(strjoin '|' $*)" . | grepv
    }
    export -f rgrep
}

setup_mawk() {
    # todo: optionally specify separator (-s|--separator)
    mawk() {
        if [ $# -eq 0 ]; then
            echo "usage: ${FUNCNAME[0]} n"
            return 1
        fi
        args=$(for i in `seq $#`; do printf "\$${@:$i:1},"; done)
        args=$(echo $args | sed 's/,$//')
        awk "{print $args}"
    }
    export -f mawk
}

setup=(
    git
    grep
    mawk
    notetaker
    prompt
    tmux
)
for i in ${setup[*]}; do setup_$i; done
