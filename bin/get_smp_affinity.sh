#!/bin/bash

interface=${1:-0}
number_of_cores=$(cat /proc/cpuinfo |grep processor|wc -l)
((ring_name_column_index = $number_of_cores + 3))

declare -a interrupt_list=(  $(cat /proc/interrupts | grep eth$interface | awk '{print $1}' | sed 's/://g' ) )           
declare -a interrupt_name_list;

interrupt_name_list=(  $(cat /proc/interrupts | grep eth$interface | awk '{print $x}' x=$ring_name_column_index  ) )

printf "%-20s %-10s %-10s\n" name interrupt affinity
for (( i=0 ; i < ${#interrupt_list[*]} ; i++ ))   ; do 
	printf "%-20s %-10d %-s\n" ${interrupt_name_list[$i]} ${interrupt_list[$i]} $(cat /proc/irq/${interrupt_list[$i]}/smp_affinity);  
done
