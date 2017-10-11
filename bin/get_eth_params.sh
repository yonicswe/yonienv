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
fi

# make sure that user has root permission
if (( $(id -u ) != 0 )) ; then 
    echo "You must be root" 
    exit  
fi    

ethtool -k eth${interface}
ethtool eth${interface} |grep "Speed\|Duplex"
