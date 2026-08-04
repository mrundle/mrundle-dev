# source aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

email_addr=m.n.rundle@gmail.com

setup_path() {
    local -a paths
    paths+=($HOME/bin)
    using_macos && paths+=(/opt/homebrew/bin)
    for p in ${paths[@]}; do PATH+=:$p; done
    export PATH
}

setup_git()
{
    alias gg="git grep"
    # hash of most recent commit
    alias gitlast="git log | head -n 1 | awk '{print \$2}'"
    git-add-modified() {
        git status | grep modified | sed -e 's/^\s*modified:\s*//' \
            | while IFS= read -r f; do git add "$f"; done
    }
    export -f git-add-modified

    # setup 1password for github cli
    local -r plugin=$HOME/.config/op/plugins.sh
    [[ -f $plugin ]] && source $plugin
}

using_macos() {
    local -r os=$(uname)
    [[ ${os,,} =~ darwin ]]
}

setup_macos() {
    if ! using_macos; then
        return 0
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export BASH_SILENCE_DEPRECATION_WARNING=1
}

setup_aliases() {
    alias picoc="picoc -i"
    alias c="picoc -i"
    alias findfiles="find . -type f | grep -v git"
    alias ff=findfiles
    # git
    alias ga="git add"
    alias gu="git add -u"
    alias gc="git commit"
    alias gp="git pull"
    alias gP="git push"
    alias tags="ctags -R --languages=c,c++ --exclude='*build*' ."
    alias scope="cscope -b -q -k"
    alias work="cd $HOME/work"
}

setup_terminal() {
    # setup prompt
    PS1=
    # If on an ec2-instance, blink a reminder (bold black on yellow background)
    [[ $USER == ec2-user ]] && PS1+="\e[30m\e[103m\e[1m[EC2 INSTANCE]\e[0m "
    # If using gitbash or WSL (both would be Windows), set visual tag
    local -r gitbash_tag="git-bash"
    local -r wsl_tag="wsl"
    [[ ${EXEPATH:-} =~ 'Git\bin' ]] && PS1+="\[\033[32m\]($gitbash_tag) \[\033[m"
    [[ -n ${WSLENV:-} ]] && PS1+="\[\033[32m\]($wsl_tag) \[\033[m"
    PS1+="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
    export PS1

    # colors for macos
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad

    # change default list behavior
    if using_macos; then
        alias ls='ls -GFh'
    else
        alias ls='ls -Fh --color=auto'
    fi
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
            echo "usage: ${FUNCNAME[0]} <title>" && return 1
        elif [ -z $NOTE_DIR ]; then
            echo "NOTE_DIR not defined" && return 1
        elif [ ! -d $NOTE_DIR ]; then
            mkdir $NOTE_DIR || return 1
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

setup_tmux()
{
    local -r _TMUX_BIN=$(which tmux)
    if [[ -z $_TMUX_BIN ]]; then
        echo "couldn't find tmux in \$PATH, skipping setup" >&2
        return
    fi

    alias tls="$_TMUX_BIN ls"
    alias tl="tls"
    alias tnew="$_TMUX_BIN new -s"
    alias tn="tnew"
    alias tkill="$_TMUX_BIN kill-session -t"
    alias tk="tkill"
    alias tattach="$_TMUX_BIN attach -dt"
    alias ta="tattach"

    tmux_date() { /bin/date '+%A-%d-%b-%Y' "$@"; } # like "Thursday-14-Oct-2021"
    tmux_date_yesterday() { tmux_date -d '1 day ago'; }
    tmux_sessions() { $_TMUX_BIN list-sessions -F '#{session_name}'; }
    tmux_session_exists() {
        local -r session=$1
        for s in $(tmux_sessions); do
            [[ $s == $session ]] && return 0
        done
        return 1
    }
    ttoday() {
        session=$(tmux_date)
        $_TMUX_BIN new-session -DAs $session
        # TODO
        # if today exists, use that
        # if yesterday exists, offer to copy
        # otherwise, prompt to kill all older sessions and create
    }
    tyesterday() {
        session=$(tmux_date_yesterday)
        $_TMUX_BIN attach-session -dt $session
    }
    export -f ttoday
    export -f tyesterday
}

colors() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
    done
}
export -f colors

alert_with_message() {
    # bold, underlined, yellow
    local alert_msg="ALERT"
    local extra_msg=""
    [[ -n $* ]] && extra_msg+="\e[93m ($*)\e[0m"
    printf "\e[1m\e[4m\e[93m${alert_msg}\e[0m${extra_msg}"
}
export -f alert_with_message

confirm() {
    # bold, underlined, green
    local confirm_msg="OK"
    local extra_msg=""
    [[ -n $* ]] && extra_msg+="\e[92m ($*)\e[0m"
    printf "\e[1m\e[4m\e[92m${confirm_msg}\e[0m${extra_msg}"
}
export -f confirm

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

columnsum() {
    # sum a column, like
    #   awk '{print $1}' $FILE | columnsum
    paste -sd+ - | bc
}
export -f columnsum

rgrep() {
    grep -nr "$@" .
}
export -f rgrep

# use like:
#    $ cat /tmp/bigfile.txt | paste
#    http://termbin.com/j06n
termbin() {
    nc termbin.com 9999 < /dev/stdin
}
export -f termbin

setup_rust() {
    if [[ -f ~/.cargo/env ]]; then
        source ~/.cargo/env
    fi
}

check_bash_version() {
    local major minor
    read major minor <<< $(echo ${BASH_VERSION} | awk -F. '{print $1,$2}')
    if [[ $major -lt 4 ]]; then
        echo "WARNING: older bash version detected (${BASH_VERSION})"
    fi
}

setup_path
setup_aliases
setup_terminal
setup_ssh
setup_git
setup_notetaker
setup_tmux
setup_demo
setup_macos
setup_rust
check_bash_version
