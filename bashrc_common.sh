#!/bin/bash


alias editbashcommon='g ${yonienv}/bashrc_common.sh';

export LANG=en_US.UTF-8
export LC_ALL=C

alias cdyonienv='cd ${yonienv}'

export yonidocs=~/share/docs
export yonicode=~/share/code

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

rebash ()
{
    unalias -a

    [ -e ~/.inview ] && rm -f ~/.inview 1>/dev/null;
#    \mv ${BM} ${BM}.tmp ; 
#    pdc 1>/dev/null ; 
   source ~/.bashrc ;
#    \mv ${BM}.tmp ${BM} ; 
#    source ${BM} 1>/dev/null
#    pdf_complete 1>/dev/null
#    pd_complete 1>/dev/null
}   


editbashrc () 
{
    if [ $(rpm -q vim-X11 | wc -l ) -gt 0 ] ; then 
        gvim ${yonienv}/bashrc_main.sh
    elif [ $(rpm -q vim-enhanced | wc -l ) -gt 0 ] ; then 
        vim ${yonienv}/bashrc_main.sh
    else
        echo "please install vim-enhanced or vim-X11"
    fi        
}

findyonialias () 
{
    f=${1};
    grep -ln "alias $1" ${yonienv}bashrc_*sh; 
    grep -l "$1 ()" ${yonienv}bashrc_*sh
}



