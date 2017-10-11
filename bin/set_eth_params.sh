#!/bin/bash

interface=${1};

interface_list=( $(ifconfig | grep eth | awk '{print $1}') ) 

# validate the user chosen interface
if ! [ -z ${interface} ] ; then 
    found=no
    case "${interface_list[@]}" in  
        *"${interface}"*) 
            found=yes 
            ;; 
    esac

    if [ ${found} == "no" ] ; then
        echo "NO Interface : eth${interface}"
        echo "Available    : ${interface_list[@]}";
        exit
    fi        
else    
    echo "you must enter an interface (e.g. eth2)";
    exit 1; 
fi

# make sure that user has root permission
if (( $(id -u ) != 0 )) ; then 
    echo "You must be root" 
    exit 1; 
fi    

set -x
ifconfig eth${interface} down
ifconfig eth${interface} promisc
ethtool -s eth${interface} speed 10000 duplex full
ethtool --set-ring eth${interface} tx 4096
ethtool --set-ring eth${interface} rx 4096
ethtool  -K eth${interface} rx off tx off tso off gso off gro off
ifconfig eth${interface} up
set +x

ethtool -k eth${interface}
sleep 2
ethtool eth${interface}


