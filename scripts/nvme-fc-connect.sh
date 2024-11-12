#!/bin/bash

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
 
for (( c=1, h=0; h<${#host_arr[@]} ; h++)) ; do
    for (( p=0; p<${#powerstore_arr[@]} ; p++)) ; do
        cmd="nvme discover -t fc -a ${powerstore_arr[${p}]} -w ${host_arr[${h}]}";
        echo "($c) ${cmd}";
        read -p "continue [Y|n]" x;
        if [[ $x == n ]] ; then
            exit 1;
        fi;
	eval $cmd;
        ((c++));
    done;
done;





