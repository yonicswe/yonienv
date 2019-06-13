#!/bin/bash

# afaik this is only good ranger
export VISUAL=gvim

alias connect2remoteDesktop='source $(yonienv)/bin/connectToRemoteDesk.sh'
alias yuminstallfromiso='yum install --disablerepo=\* --enablerepo=c7-media'
alias less='less -r'

# LESS or MAN with color
export LESS_TERMCAP_mb=$'\e[1;32m'      # begin blinking
export LESS_TERMCAP_md=$'\e[1;32m'      # being bold
export LESS_TERMCAP_me=$'\e[0m'         # end mode
export LESS_TERMCAP_se=$'\e[0m'         # end stand-out mode
export LESS_TERMCAP_so=$'\e[30;2;43m'      # being stand-out mode (e.g higlight search results on man page)
export LESS_TERMCAP_ue=$'\e[0m'         # end underline
export LESS_TERMCAP_us=$'\e[1;4;31m'    # begin underline

yuminstallfromrepo ()
{
    local repo=${1};
    if [ -z ${repo} ] ; then 
        echo "forgot the repo ? ";
        return;
    fi
    sudo yum install -y --disablerepo=\* --enablerepo=${repo} ;
}

alias yumsearchiniso='yum search --disablerepo=\* --enablerepo=c7-media'
alias yuminfoiniso='yum info --disablerepo=\* --enablerepo=c7-media'

alias now='date +"%d%b%Y_%H%M%S"'

alias sd='echo $TERM'
alias diff='diff -up'

xtermblack () 
{
    local font_size=${1:-14};
    xterm -bg black -fg green -fa 'Monospace' -fs ${font_size} &
}

if [ -e /usr/bin/xrandr ]  ; then 
complete -W "$(xrandr -q 2>/dev/null | awk '{print $1}')" xrandr 
fi

# pdfgrep to grep in pdf files.
# pdfgrep -n <pattern> <filename>

# to get help using wttr.in
#  curl -s "wttr.in/:help"
_weather(){ curl -s "wttr.in?m1" ;}

wttr()
{
# change Paris to your default location
    local request="wttr.in/${1-Paris}";
    [ "$COLUMNS" -lt 125 ] && request+='?n';
    curl -H "Accept-Language: ${LANG%_*}" --compressed "$request";
}

function count() {
      total=$1
            for ((i=total; i>0; i--)); do sleep 1; printf "Time remaining $i secs \r"; done
                  echo -e "\a"
}

function up() {
    times=$1;
    while [ "$times" -gt "0" ]; do
        cd ..
        times=$(($times - 1));
    done
}

# cat "file" with color 
# alias ccat="source-highlight --out-format=esc256 -o STDOUT -i"

yuminstallifnotexist ()
{
    local rpm=${1};
    if [ -z ${rpm} ] ; then return 0 ; fi;
    if [ $( rpm -q ${rpm} | grep -i "not installed" | wc -l ) -gt 0 ] ; then 
        sudo yum install -y ${rpm} ;
        return 1;
    fi;
    echo "${rpm} : already installed.";
    return 0;
}

yonienvdepsinstall ()
{
    yuminstallifnotexist vim
    yuminstallifnotexist vim-X11
    yuminstallifnotexist ctags
    yuminstallifnotexist cgdb
    yuminstallifnotexist tree
    yuminstallifnotexist screen
    yuminstallifnotexist sshpass
    yuminstallifnotexist the_silver_searcher
    yuminstallifnotexist colordiff
    yuminstallifnotexist lddtree
    yuminstallifnotexist tmux
}

alias yuminstall='sudo yum install -y'
alias yumlocalinstall='sudo yum localinstall -y'
printlinefromfile ()
{
    local line=$1;
    local file=$2;

    sed -n ${line}p $file;
}
