#!/bin/bash

# afaik this is only good ranger
# export VISUAL=/home/y_cohen/yonienv/bin/nvim.appimage
export VISUAL=vim
export EDITOR=$VISUAL

alias editbashmisc='vim ${yonienv}/bashrc_misc.sh'

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
    local pkg=${2};
    if [ -z ${repo} ] ; then 
        echo "forgot the repo ? ";
        return;
    fi

    if [[ -z ${pkg} ]] ; then 
        echo "forgot which pkg to install";
        return;
    fi;
    sudo yum install -y --disablerepo=\* --enablerepo=${repo} ${pkg};
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

extract_srt_files_from_archive ()
{
    local output_path=${1:-.};
    local cleanup=${2:-0};

    #if [ -n "$(ls *zip)" ] ; then
        #ask_user_default_yes "Hey I found zip files should i open them";
        #if [ $? -eq 0 ] ; then 
##       user answered No!
            #echo "ok!";
            #return -1; 
        #fi;
    #else
        #return 0;
    #fi;

#   sanity check
    which 7za 1>/dev/null;
    if [ $? -ne 0 ] ; then
        echo "please install 7za and retry";
        return -1;
    fi;

#   extract all zip files.
#   echo "find -maxdepth 1 -name "*zip" -exec 7za x -o ${output_path} {} \; "
    find -maxdepth 1 -name "*zip" | while read subfile ; do 
        7za x "${subfile}" -o${output_path};
        if [ $? -ne 0 ] ; then 
            echo "failed to unzip ${subfile}";
            return 1;
        fi;
    done;

    if [ $cleanup -eq 1 ] ; then
        ask_user_default_no "are you sure about the cleanup"; 
        if [ $? -eq 0 ] ; then 
            echo "ok no cleanups Bye";
            return -1;
        fi;

        if [ -n "$(findvideofiles)" ] ; then 
            echo "video files found.. WILL NOT DELETE.";
            return -1;
        fi;


        if [ "$(ls -I "*srt")" ] ; then 
            echo "there are srt files !! I cant proceed";
            return -1;
        fi;

        ask_user_default_no "final chance before cleanup"; 
        if [ $? -eq 0 ] ; then 
            echo "ok no cleanups Bye";
            return -1;
        fi;

        rm -f $(ls -I "*srt");
    fi
}

subtitlenamesync ()
{
    local movie_name=${1};
    local ask_user=${2:-1};
    local output_path=subs.out;

#   sanity check
    if [ -z ${movie_name} ] ; then 
        echo -e "give me a movie name e.g : $ subtitlenamesync \"superman\"";
        echo -e "also possible with an output path. e.g : $ subtitlenamesync \"super\" subs.super";
        echo "possible names : ";
        tabcomplete_video_file_name;
        return -1;
    fi

#     if ! [ -e ${movie_name} ] ; then 
#         echo -e "No such file \'${movie_name}\'";
#         return -1;
#     fi

    if [ -d subs ] ; then 
        echo -e "there is already a \'subs' directory here. remove it before we continue"
        return 1;
    fi

    movie_name=$(basename $movie_name);

#   sanity check
    if [ -z "$(ls *srt 2>/dev/null)" ] ; then
        echo "No SRT files found";
    fi; 

    extract_srt_files_from_archive ${output_path}; 
    if [ $? -ne 0 ] ; then echo "failed to extract" ; return -1; fi;
    if [ $( ls -l ${output_path}/*zip 2>/dev/null | wc -l ) -ne 0 ] ; then 
    #  subtitles zip files sometimes contain other zip files
    #  extract them also
        echo found more zip files.
#       rm -f *zip;
        pushd ${output_path}
            extract_srt_files_from_archive
        popd
    fi

    if ! [ -d ${output_path} ] ; then
        output_path=.;
    fi

    j=1; 
    for i in ${output_path}/*srt ; do 
        echo -e "install -D \"$i\" `pwd`/subs/${movie_name}.$j.srt" ; 
        install -D "$i" "`pwd`/subs/${movie_name}.$j.srt" ; 
        if [ $? -ne 0 ] ; then 
            echo "failed rename srt files."
            return -1;
        fi
        ((j++)) ; 
    done;

    rm -rf ${output_path}

#   echo "done";
    # tree -A ${output_path};
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
    local video_file_types="matroska\|mp4\|mkv"; 
    find -type f |
        xargs file | grep -i "${video_file_types}" | 
        cut -f 1 -d ' ' | 
        while read x ; do 
            basename $x ; 
        done;
}

install-zsh-zap ()
{
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
}

_find_zip_files_of_chapter ()
{
    local chapter=${1};

    if [[ -z ${chapter} ]] ; then
        return -1;
    fi;
    
    find -name "*E${chapter}*zip"

}

subtitle-series-sort-directories ()
{
    local nr_episodes=${1};
    local episode_index=;

    #episode_index_E=( $(seq -f "E%02g" 1 ${nr_episodes}) );

    if [[ -z ${nr_episodes} ]] ; then
        echo "num of episodes is 0"
        return -1;
    fi;

    for e in $(seq ${nr_episodes} -1 1) ; do
        f=$(find -type f -maxdepth 1 -regex ".*e$e.*\|.*e0$e.*\|.*E$e.*\|.*E0$e.*")
        if [ -z "$f" ] ; then
            echo "no files were found";
            break;
        fi;
        e=$(printf "%02d" $e)
        echo "mkdir e$e";
        mkdir e$e;
        echo "mv $f e$e";
        mv $f e$e;
        pushd e$e;
        if (( $(ls *mkv  | wc -l ) > 0 )) ; then
            subtitlenamesync *mkv
        elif (( $(ls *mp4  | wc -l ) > 0 )) ; then
            subtitlenamesync *mp4
        fi;
        popd
    done;


}


#_subtitleseriesnamesync_usage ()
#{

#}

#subtitleseriesnamesync ()
#{
    #local nr_episodes=${1};
    #local prefix_name=${2};

    #if [[ -z ${nr_episodes} ]] ; then
        #_subtitleseriesnamesync_usage;
        #return -1;
    #fi;

    #if [[ -z ${prefix_name} ]] ; then
        #return -1;
    #fi;

    ## create directories
    #seq -w 1 ${nr_episodes} | while read e ; do 
        #mkdir E$e;
        #m=$(basename $(ls ${prefix_name}$e*) ) ; 
        #echo "ln -snf ../../$m E$e/$m"; 
        #ln -snf ../../$m E$e/$m; 
    #done;
#}
