#!/bin/bash

unalias -a;
unset SSH_ASKPASS
alias editbashcommon='${v_or_g} ${yonienv}/bashrc_common.sh';
grepyonienv () 
{
    local grepme="${1}";
    [ -z "${grepme}" ] && return -1;

#   grep -nHT --color ${grepme} ${yonienv}/*.sh;
    ag --shell --noheading --depth 1 ${grepme} ${yonienv};
}

export LANG=en_US.UTF-8
export LC_ALL=C
export LESSCHARSET=UTF-8

alias cdyonienv='cd ${yonienv}'

source ${yonienv}/env_common_args.sh

# return 0:no 1:yes
ask_user_default_no ()
{
    local choice=;
    read -p " [y|N]?" choice
    case "$choice" in 
      y|Y ) return 1;;
      * ) return 0;;
#       y|Y ) echo "yes";;
#       n|N ) echo "no";;
#       * ) echo "no";;
    esac
}

# return 0:no 1:yes
ask_user_default_yes ()
{
    local choice=;
    local user_string=${1};
    read -p "${user_string} [Y|n]?" choice
    case "$choice" in 
      n|N ) return 0;;
      * ) return 1;;
#       n|N ) echo "no";;
#       y|Y ) echo "yes";;
#       * ) echo "yes";;
    esac
}

# e.g print_underline "yoni cohen" =
#  prints a line from "=" in the length 
#  of the string "yoni cohen"
#  i.e.           ==========
# 
print_underline_size () 
{
    local line_char=$1;
    local str_len=${2:-20};

    for i in $(seq 0 ${str_len} )  ; do 
        printf "${line_char}" ; 
    done

    echo; 
}

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

      ${v_or_g} ${yonienv}/${bashfile};
#     if [ $(rpm -q vim-X11 | wc -l ) -gt 0 ] ; then 
#         gvim ${yonienv}/${bashfile};
#     elif [ $(rpm -q vim-enhanced | wc -l ) -gt 0 ] ; then 
#         vim ${yonienv}/${bashfile};
#     else
#         echo "please install vim-enhanced or vim-X11"
#     fi        
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

yonienvconfigureforputty ()
{
    if [ -h ~/.inputrc ] ; then 
        rm -f ~/.inputrc;
        echo "disabled, run bash to take effect";
    else
        ln -snf ${yonienv}/inputrc.for.putty ~/.inputrc ;
        echo "enabled, run bash to take effect";
    fi

}

if [ -e /usr/bin/nproc ] ; then 
    ncoresformake=$((   $(nproc) )) ;  
else 
    ncoresformake=$(cat /proc/cpuinfo |grep core\ id | wc -l); 
fi
