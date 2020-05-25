#!/bin/bash

########################################################################
# huawei stuff
########################################################################

if ! [ -e ~/.bashhuawei_once.$(hostname -s) ] ; then
    export PATH=${PATH}:/.autodirect/mswg/release/MLNX_OFED/
    touch ~/.bashhuawei_once.$(hostname -s); 
fi

alias editbashhuawei='${v_or_g} ${yonienv}/bashrc_huawei.sh'
export yonipass="yonic"

# vnc hosts
create_alias_for_host server 192.168.56.106
