#!/bin/bash
if [ -e /usr/local/bin/bwm-ng -o -e /usr/bin/bwm-ng ] ; then 
    bwm-ng -u bits -T avg -d
else
    echo "you need to install bwm-ng ( man ips ) "
fi    

