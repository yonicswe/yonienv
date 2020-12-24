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

yonideps_arr=(vim);
yonideps_arr+=(vim-X11);
yonideps_arr+=(ctags);
yonideps_arr+=(cscope);
yonideps_arr+=(tagging);
yonideps_arr+=(cgdb);
yonideps_arr+=(tree);
yonideps_arr+=(screen);
yonideps_arr+=(sshpass);
yonideps_arr+=(the_silver_searcher);
yonideps_arr+=(colordiff);
yonideps_arr+=(words);
yonideps_arr+=(tmux);
yonideps_arr+=(figlet);

# pax-utils for lddtree
yonideps_arr+=(pax-utils);

yonimlxdeps_arr+=(pciutils);
yonimlxdeps_arr+=(openssl-devel);
yonimlxdeps_arr+=(virt-what);
yonimlxdeps_arr+=(dmidecode);
yonimlxdeps_arr+=(grub2-tools);
yonimlxdeps_arr+=(grub2-tools-minimal);
yonimlxdeps_arr+=(opensm);
yonimlxdeps_arr+=(libibverbs-utils);
yonimlxdeps_arr+=(libibverbs-devel);
yonimlxdeps_arr+=(iproute);
yonimlxdeps_arr+=(perftest);
yonimlxdeps_arr+=(mlxver-scripts);
yonimlxdeps_arr+=(pandoc);
yonimlxdeps_arr+=(diffstat);
#-------------------------------------
#           ofed deps
#-------------------------------------
yonimlxdeps_arr+=(tk lsof pkgconf-pkg-config ethtool tcl);


# infiniband-diags for ibstat
yonimlxdeps_arr+=(infiniband-diags);
complete -W "$(echo ${yonideps_arr[@]} ${yonimlxdeps_arr[@]})" yuminstall yuminstallifnotexist
yonienvdepsinstall ()
{
    for p in $(echo ${yonideps_arr[@]}) ; do 
        yuminstallifnotexist $p
    done
#     yuminstallifnotexist vim
#     yuminstallifnotexist vim-X11
#     yuminstallifnotexist ctags
#     yuminstallifnotexist cgdb
#     yuminstallifnotexist tree
#     yuminstallifnotexist screen
#     yuminstallifnotexist sshpass
#     yuminstallifnotexist the_silver_searcher
#     yuminstallifnotexist colordiff
#     yuminstallifnotexist lddtree
#     yuminstallifnotexist pax-utils
}

alias yuminstall='sudo yum install -y'
alias yumlocalinstall='sudo yum localinstall -y'
printlinefromfile ()
{
    local line=$1;
    local file=$2;

    if [ -z "${*}" ] ; then
        echo "usage: printlinefromfile <line> <file>"
        return;
    fi

    sed -n ${line}p $file;
}

checkifalive ()
{
    server=$1;
    [[ -z $server ]] && return;

    while : ; do  
        ping -q $server  -w 3;
        ret=$? ;
        [[ $ret == 0 ]] && break; 
        sleep 10
    done
}

subtitlenamesync ()
{
    movie_name=${1};
    output_path=${2:-subs.out}

#   sanity check
    if [ -z ${movie_name} ] ; then 
        echo -e "give me a movie name e.g : $ subtitlenamesync \"superman\"";
        echo -e "also possible with an output path. e.g : $ subtitlenamesync \"super\" subs.super";
        echo "possible names : ";
        tabcomplete_video_file_name;
        return -1;
    fi

    movie_name=$(basename $movie_name);

#   sanity check
    if [ -z "$(ls *srt 2>/dev/null)" ] ; then
        echo "No SRT files found";
    fi; 

    extract_srt_files_from_archive;

#  use this to debug
#     j=1; 
#     for i in *srt ; do 
#         echo -e "install -D \"$i\" `pwd`/${output_path}/${movie_name}.$j.srt"; 
#         ((j++)) ; 
#     done
# 
#     ask_user_default_yes;
#     [ $? -eq 0 ] && return;
#  use this to debug

    j=1; 
    for i in *srt ; do 
        install -D "$i" `pwd`/${output_path}/${movie_name}.$j.srt ; 
        ((j++)) ; 
    done;

#   echo "done";
    tree -A ${output_path};
}

extract_srt_files_from_archive ()
{
    if [ -n "$(ls *zip)" ] ; then
        ask_user_default_yes "Hey I found zip files should i open them";
        if [ $? -eq 0 ] ; then 
#       user answered No!
            echo "ok!";
            return -1; 
        fi;
    else
        return -1;
    fi;

#   sanity check
    which 7za;
    if [ $? -ne 0 ] ; then
        echo "please install 7za and retry";
        return -1;
    fi;

#   let the extraction begin
    for i in $(ls *zip) ; do 
        7za x "$i";
    done;

    ask_user_default_no "should i clean all non srt files";
    if [ $? -eq 0 ] ; then 
        echo -e "ok Bye";
        return -1;
    fi;
    
    if [ -n "$(findvideofiles)" ] ; then 
        echo "video files found.. WILL NOT DELETE.";
        return -1;
    fi;

    echo -e "rm -f $(ls -I "*srt")";
    ask_user_default_yes "are you sure "; 
    if [ $? -eq 0 ] ; then 
        echo "ok Bye";
        return -1;
    fi;

#   user chose to cleanup the folder    
    rm -f $(ls -I "*srt");
}

tabcomplete_video_file_name ()
{
    local comp_string="$( findvideofiles  |
        while read f  ; do ff=${f%.*}; echo $ff; done;)";
    echo ${comp_string};
    complete -W "$(echo ${comp_string})" subtitlenamesync;
}

findvideofiles ()
{
    local video_file_types="matroska\|mp4"; 
    find -type f |
        xargs file | grep -i "${video_file_types}" | 
        cut -f 1 -d ' ' | 
        while read x ; do 
            basename $x ; 
        done;
}

source /home/ycohen/share/tmp/fzf/shell/key-bindings.bash
