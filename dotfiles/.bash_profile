
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

[[ $(hostname) =~ amazon.com ]] && AMAZON=true || AMAZON=false
$AMAZON && email_addr=$USER@amazon.com || email_addr=m.n.rundle@gmail.com

setup_path() {
    local -a paths
    if $AMAZON; then
        # NOTE: having SDETools in front of /usr/bin breaks BFDP builds
        paths+=(
            /apollo/env/SDETools/bin
            /apollo/env/envImprovement/bin
            /apollo/env/AmazonAwsCli/bin
            /apollo/env/BlackfootServiceClientShell/bin
            /apollo/env/BarkCLI/bin
            /apollo/env/GordianKnot/bin
            $HOME/work/BlackfootSDETools/src/BlackfootSDETools/bin
            $HOME/work/Git-review-tools
        )
    fi
    paths+=(
        $HOME/bin
    )
    for p in ${paths[@]}; do PATH+=:$p; done
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
    alias eh="expand-hostclass"
    alias findfiles="find . -type f | grep -v git"
    alias gfind=findfiles
    alias gf=gfind
    alias ff=findfiles
    # git
    alias ga="git add"
    alias gu="git add -u"
    alias gc="git commit"
    alias gp="git pull"
    alias gP="git push"
    alias tags="ctags -R --languages=c,c++ --exclude='*build*' ."
    alias scope="cscope -b -q -k"
    alias post-review="PYTHONHTTPSVERIFY=0 post-review"
    alias ec2-ssh=/apollo/env/EC2SSHWrapper/bin/ec2-ssh
}

setup_mac() {
    # Colors for mac terminal
    PS1=
    # If on an ec2-instance, blink a reminder (bold black on yellow background)
    [[ $USER == ec2-user ]] && PS1="\e[30m\e[103m\e[1m[EC2 INSTANCE]\e[0m "
    PS1+="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
    export PS1
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

colors() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
    done
}
export -f colors

alert() {
    # bold, underlined, yellow
    local alert_msg="ALERT"
    local extra_msg=""
    [[ -n $* ]] && extra_msg+="\e[93m ($*)\e[0m"
    printf "\e[1m\e[4m\e[93m${alert_msg}\e[0m${extra_msg}"
}
export -f alert

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

setup_amazon() {
    clone() {
        cmd="git clone ssh://git.amazon.com/pkg/$1"
        echo "Running $cmd ..."
        $cmd
    }

    # blackfoot
    export RPMDIR=~/work/rpmdir
    if [ ! -d $rpmdir ]; then
        rm -rf $rpmdir
        mkdir -p $rpmdir
    fi

    # random crap
    alias work="cd ~/work"
    alias bfdp="cd ~/work/BlackfootDataPlane"
    alias shadow='ssh -A bastion-iad.ec2 "ssh 10.106.160.185"'
    # XXX use system vim for now, envImprovement doesn't respect .vimrc
    #envVim=/apollo/env/envImprovement/bin/vim
    #[[ -f $envVim ]] && alias vim=$envVim
    alias vim='/usr/bin/vim'
    export TWO="ua41f725e10ec55c1162b.ant.amazon.com" # physical desktop
    export COV_ROOT=/home/mrundle/work/coverity/cov-analysis-linux64-2017.07/

    # Prefer SDETools' git, found errors otherwise
    sde_git=/apollo/env/SDETools/bin/git
    [[ -x $sde_git ]] && alias git=$sde_git

    # svn
    export SVN_EDITOR=vim
    export SVN_URL=https://svn.ec2.amazon.com
    post_review_svn() {
    	if [ ! -x ~/post-review-from-svn ]; then
	        cd ~ && svn export $SVN_URL/ec2/netsec/trunk/post-review-from-svn/post-review-from-svn
        fi
        ~/post-review-from-svn -- .
    }
    export -f post_review_svn

    # Set up functions and aliases for Brazil
    alias bb="brazil-build"
    alias bba="brazil-build && brazil-build apollo-pkg"
    alias bre="brazil-runtime-exec"
    bcreate() {
        # function to quickly create
        if [ $# -ne 1 ]; then
            echo "usage: $FUNCNAME <package_name>"
        else
            package=$1
            brazil ws create --name $package || return 1
            cd $package
            brazil ws --use -p $package
        fi
    }
    export -f bcreate

    alias brazil-octane='/apollo/env/OctaneBrazilTools/bin/brazil-octane'

    # Uses post-review to post an arbitrary diff
    arbitrarydiff() {
        if [ $# -ne 2 ]; then
            echo "usage: $FUNCNAME <start commit> <end commit>"
            echo "or, run:"
            echo "git diff -U999999999 --no-color" \
                 "<start commit> <end commit> | post-review [-r <cr_id>] -a -"
             # for crux
             # https://builderhub.corp.amazon.com/blog/arbitrary-diff-support-for-crux-is-now-available/
            echo "git diff -U999999999 --no-color" \
                "<start commit> <end commit> |"\
                "cr --arbitrary-diff-create-personal-pkg [-r <cr_id>] -a -"
            return 1
        fi
        start_commit=$1
        end_commit=$2
        /usr/bin/kinit
        git diff -U999999999 --no-color $start_commit $end_commit \
            | cr --arbitrary-diff-create-personal-pkg -a -
    }
    export -f arbitrarydiff

    # Uses post-review to post an arbitrary diff between two files
    # TODO use crux instead, like arbitrarydiff above
    rawdiff() {
        if [[ $# -ne 2 ]]; then
            echo "usage: $FUNCNAME <file_a> <file_b>"
            return 1
        fi
        git diff --no-index $1 $2 | post-review -a -
    }

    midway_creds_expiring() {
        local cookie=~/.midway/cookie
        [[ ! -f $cookie ]] && return 0
        local -i expiry=$(grep ^#HttpOnly_midway $cookie | awk '{print $5}')
        expiry=$(( expiry - (1 * 60 * 60) ))
        # will it expire in less than an hour?
        [[ $((expiry - (1*60*60))) -lt $(/bin/date +%s) ]]
    }
    export -f midway_creds_expiring

    kerberos_creds_expiring() {
        /usr/bin/klist -s && return 1 || return 0
    }
    export -f kerberos_creds_expiring

    alert_if_creds_expiring() {
        [[ $USER == 'ec2-user' ]] && return 0
        local -a missing
        midway_creds_expiring && missing+=('midway')
        kerberos_creds_expiring && missing+=('kerberos')
        if [[ ${#missing[@]} -gt 0 ]]; then
            echo "#"
            echo "# `alert` Creds missing or expired: [ ${missing[@]} ], run refresh_creds"
            echo "#"
        fi
    }

    refresh_creds() {
        local pin otp password
        if midway_creds_expiring; then
            echo "$(alert Initializing Midway)"
            local blink="\e[5m" reset="\e[0m" ylwbg="\e[103m" blk="\e[30m" uln="\e[4m" bld="\e[1m"
            # bold, underline, black text on yellow bg
            echo -en "Midway ${blink}${ylwbg}${blk}${bld}${uln}PIN${reset}: "
            read -s pin; echo
            read -p 'Yubikey OTP: ' otp && \
                echo -e "${pin}\n${otp}" | \
                    /usr/bin/mwinit -o
        fi
        if kerberos_creds_expiring; then
            echo "$(alert Initializing Kerberos)"
            read -sp 'Password: ' password; echo
            echo $password | /usr/bin/kinit >/dev/null
        fi
        echo "$(confirm authenticated)"
    }
    export -f refresh_creds

    # use PROMPT_COMMAND to check creds before each prompt
    export PROMPT_COMMAND="alert_if_creds_expiring"

    export CLOUDFOOT=34.209.85.162
    export CLOUDFOOT_IP=$CLOUDFOOT
    export CLOUDFOOT_SSH_KEY=~/.ssh/mrundle-cloudfoot.pem

    cloudfoot() {
        ssh -i $CLOUDFOOT_SSH_KEY ec2-user@$CLOUDFOOT
    }
    export -f cloudfoot
}

setup_path
setup_aliases
setup_mac
setup_ssh
setup_git
setup_notetaker
setup_tmux
setup_demo

# amazon-specific
$AMAZON && setup_amazon
