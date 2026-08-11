#!/bin/bash

# how to 
# use bsclistnvmeportsfcc on the bsc to create the powerstore_file
# then use bscscptohost to create a scp command to copy the powerstore_file;
# use dellnvme-fc-host-nodename-portname on the host to create the host file
# invoke ./nvme-fc-discover.sh host_file powerstore_file 
# to test all possible paths between host and target

RED="\033[1;31m"
REDBLINK="\033[1;5;31m"
REDITALIC="\033[1;3;31m"
REDREVERSE="\033[1;7;31m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
BROWN="\033[0;33m"
YELLOW="\033[1;33m"
NC="\033[0m"

host_file=${1};
powerstore_file=${2};

if [[ $# -ne 2 ]] ; then
    echo "usage $0 <host file> <powerstore file>"
    exit 1;
fi;

if ! [ -e $host_file ] ; then
    echo "$host_file does not exist";
    exit 1;
fi;

if ! [ -e $powerstore_file ] ; then
    echo "$powerstore_file does not exist";
    exit 1;
fi;

# read the host addresses into an array 
host_arr=( $(cat $host_file) );
powerstore_arr=( $(cat $powerstore_file) );
 
success_file=successful_fc_connections.txt;
echo > ${success_file};
    
for (( c=1, h=0; h<${#host_arr[@]} ; h++)) ; do
    for (( p=0; p<${#powerstore_arr[@]} ; p++)) ; do
        cmd="nvme discover -t fc -a ${powerstore_arr[${p}]} -w ${host_arr[${h}]}";
        echo "($c) ${cmd}";
        read -p "continue [Y|n]" x;
        if [[ $x == n ]] ; then
            exit 1;
        fi;
        eval $cmd;
        if [[ $? -eq 0 ]] ; then
            echo -e "$c\n${cmd}" >> ${success_file};
        fi;
        ((c++));
    done;
done;

echo -e "${RED}results written to ${success_file}${NC}";





