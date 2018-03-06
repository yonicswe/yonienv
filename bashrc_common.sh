#!/bin/bash

unalias -a;
unset SSH_ASKPASS
alias editbashcommon='g ${yonienv}/bashrc_common.sh';

export LANG=en_US.UTF-8
export LC_ALL=C

alias cdyonienv='cd ${yonienv}'

export yonidocs=~yonatanc/share/docs
export yonicode=~yonatanc/share/code
export yonitasks=~yonatanc/share/tasks

# 
# e.g print_underline "yoni cohen" =
#  prints a line from "=" in the length 
#  of the string "yoni cohen"
#  i.e.           ==========
# 
print_underline () 
{
    local str=$1;
    local line_char=$2;
    local str_len=${#str};
#   local str_len=$(expr length "$str");

    for i in $(seq 0 ${str_len} )  ; do 
        printf "${line_char}" ; 
    done

    echo; 
}

editbashrc () 
{
    local bashfile=${1:-bashrc_main.sh};

    if [ $(rpm -q vim-X11 | wc -l ) -gt 0 ] ; then 
        gvim ${yonienv}/${bashfile};
    elif [ $(rpm -q vim-enhanced | wc -l ) -gt 0 ] ; then 
        vim ${yonienv}/${bashfile};
    else
        echo "please install vim-enhanced or vim-X11"
    fi        
}

complete -W "$(find  ${yonienv} -maxdepth 1 -name "*bash*" -printf "%f\n")" editbashrc

findyonialias () 
{
    f=${1};
    grep -ln "alias $1" ${yonienv}bashrc_*sh; 
    grep -l "$1 ()" ${yonienv}bashrc_*sh
}

whichbash ()
{
    local yonienv_cmd=${1};
    [ -z ${yonienv_cmd} ] && return;
    grep -l ${yonienv_cmd} ${yonienv}/bashrc_* | sort -u | xargs basename
}

