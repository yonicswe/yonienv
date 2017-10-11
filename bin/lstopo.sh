#!/bin/bash
core=( $(cat /proc/cpuinfo | grep "processor" | sed 's/.*://g') ) ; 
socket=( $(cat /proc/cpuinfo | grep "physical\ id" | sed 's/.*://g') )  ; 

printf "%-10s" "core :"

echo ${core[*]} | while read core ; do 
    printf "%-3d" $core
done;   
    
echo
printf "%-10s" "socket :"
    
echo ${socket[*]} | while read core ; do 
    printf "%-3d" $core
done; 

echo

