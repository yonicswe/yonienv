#!/bin/bash

unalias -a;
unset SSH_ASKPASS
alias editbashcommon='g ${yonienv}/bashrc_common.sh';
grepbash () 
{
    local grepme=${1};
    [ -z "${grepme}" ] && return -1;

    grep -nHT --color ${grepme} ${yonienv}/*.sh;
}

export LANG=en_US.UTF-8
export LC_ALL=C

alias cdyonienv='cd ${yonienv}'

source ${yonienv}/env_common_args.sh

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

if [ -e /usr/bin/nproc ] ; then 
    ncoresformake=$((   $(nproc) )) ;  
else 
    ncoresformake=$(cat /proc/cpuinfo |grep core\ id | wc -l); 
fi
