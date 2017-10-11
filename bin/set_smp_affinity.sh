#!/bin/bash

interface=${1:-0};
fix_cpu=${2:-acssend};
print_name=${3:-yes};

echo -e "\n$0 <interface[${interface}]> <fixed_cpu[${fix_cpu}]> <print interrupt name[${print_name}]>\n" 

number_of_cores=$(cat /proc/cpuinfo |grep processor|wc -l)

declare -a interrupt_list=(  $(cat /proc/interrupts | grep eth$interface | awk '{print $1}' | sed 's/://g' ) )           

declare -a interrupt_name_list;

if [ ${number_of_cores} -eq 16 ] ; then 
    interrupt_name_list=(  $(cat /proc/interrupts | grep eth$interface | awk '{print $19}'  ) )           
fi

if [ ${number_of_cores} -eq 32 ] ; then 
    interrupt_name_list=(  $(cat /proc/interrupts | grep eth$interface | awk '{print $35}'  ) )           
fi

if [ ${fix_cpu} = acssend ] ; then 
    cpu=1;
else
    ((cpu = 1 << $fix_cpu )) ;
fi


for (( i=0 ; i < ${#interrupt_list[*]} ; i++ )) ; do
	hex_cpu=$(printf "%x" $cpu)
    if [ ${print_name} == "yes" ] ; then 
        printf "%-16s echo %-12d > /proc/irq/%d/smp_affinity\n" ${interrupt_name_list[$i]} ${hex_cpu} ${interrupt_list[$i]};  
    else
        printf "echo %-12d > /proc/irq/%d/smp_affinity\n" ${hex_cpu} ${interrupt_list[$i]};  
    fi
    
    if [ ${fix_cpu} = acssend ] ; then 
        ((cpu = cpu << 1 )) ;
    fi        
done
