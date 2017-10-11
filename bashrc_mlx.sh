#!/bin/bash


#  __  __       _  _                       
# |  \/  | ___ | || | __ _  _ _   ___ __ __
# | |\/| |/ -_)| || |/ _` || ' \ / _ \\ \ /
# |_|  |_|\___||_||_|\__,_||_||_|\___//_\_\
#                                          


alias editbashmlx='g ${yonienv}/bashrc_mlx.sh'

alias 8='    ssh  r-ole08'
alias 9='    ssh  r-ole09'
alias 10='   ssh  r-ole10'
alias 11='   ssh  r-ole11'
alias 145='  ssh  dev-l-vrt-145'
alias 145='  ssh  dev-l-vrt-145'
alias 1455=' ssh  dev-l-vrt-145-005'
alias 1456=' ssh  dev-l-vrt-145-006'
alias 1457=' ssh  dev-l-vrt-145-007'
alias 146='  ssh  dev-l-vrt-146'
alias 1465=' ssh  dev-l-vrt-146-005'
alias 1466=' ssh  dev-l-vrt-146-006'
alias 1467=' ssh  dev-l-vrt-146-007'
alias 1468=' ssh  dev-l-vrt-146-008'
alias 1469=' ssh  dev-l-vrt-146-009'
alias 14610='ssh  dev-l-vrt-146-010'
alias 94='   ssh  dev-l-vrt-094'
alias 97='   ssh  dev-l-vrt-097'


rxeprintstats () 
{
    for i in /sys/class/infiniband/rxe0/ports/1/hw_counters/* ; do echo -e "$(basename $i) = $(cat $i)" ; done | column -t
}

sm () { 
    complete_words=$(awk '/if.*mod.*==/{print $5}' `which singlemoduleinstall.sh ` | sed 's/"//g')
    complete -W "$(echo ${complete_words})" sm; 
    [ -z $1 ] && return;
    singlemoduleinstall.sh $1;
}

geometryrestart ()
{
    geom=${1};
    port=${2};

    if [ $# -ne 2 ] ; then 
        echo "you forgot port number";
        return;
    fi

    set -x ; vncserver -kill :${port} ; sleep 10 ; vncserver -geometry ${geom} :${port}; set +x;
}

alias geometryrestarthome='geometryrestart "1280x1024"'
alias geometryrestartoffice='geometryrestart "1920x1080"'

export yonidevel=~/devel
alias cddevel='cd ${yonidevel}'
alias cdupstream='cd ${yonidevel}/upstream'
alias cdofed='cd ${yonidevel}/ofed'
alias cdrxeregression='cd ${yonidevel}/rxe_regression'

alias ibmod='lsmod |grep "ib_\|mlx[4,5]\|rdma"'
alias nox='lspci | grep nox'
alias cdlinux='cd /images/kernel'
