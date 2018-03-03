# .bash_profile
email_addr=m.n.rundle@gmail.com

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

setup_path() {
    PATH+=:$HOME/bin
    export PATH
}

setup_git() {
    alias gg="git grep"
    # hash of most recent commit
    alias gitlast="git log | head -n 1 | awk '{print \$2}'"
}

setup_aliases() {
    alias picoc="picoc -i"
    alias c="picoc -i"
    alias work="cd ~/work"
}

setup_mac() {
    # Colors for mac terminal
    export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad
    alias ls='ls -GFh'
}

setup_demo() {
    _DEMO=false
    alias demo="export _DEMO=true; export OLD_PS1='$PS1'; export PS1='\e[36m$ \e[39m'"
    alias undemo="if $_DEMO; then export PS1='$OLD_PS1'; _DEMO=false; fi"
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
            sendmail $email_addr < $tmpmail
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

# use like:
#    $ cat /tmp/bigfile.txt | paste
#    http://termbin.com/j06n
paste() {
    nc termbin.com 9999 < /dev/stdin
}
export -f paste

colors() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
    done
}
export -f colors

_alert() {
    # bold, underlined, yellow
    local msg=ALERT
    printf "\e[1m\e[4m\e[93m$msg\e[0m"
}
export -f _alert

ask() {
    prompt="$@ (y/n): "
    while true; do
        read -p "$prompt" resp
        case $resp in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "\n$prompt";;
        esac
    done
}
export -f ask

rgrep() {
    grep -nr "$@" .
}
export -f rgrep

setup_path
setup_aliases
setup_mac
setup_ssh
setup_git
setup_notetaker
setup_tmux
setup_demo
