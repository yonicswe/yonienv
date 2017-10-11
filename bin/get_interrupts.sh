#!/bin/bash

interface=${1:-0}
screen=${2:-0}

number_of_cores=$(cat /proc/cpuinfo |grep processor|wc -l)


print_interrupts_for_4_cores () 
{ 
#     echo $FUNCNAME
    if (( ${screen} == 1 || ${screen} == 0 )) ; then 

        printf "%-19s %-10s %-10s %-10s %-10s\n" "interrupt" CPU0 CPU1 CPU2 CPU3;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d\n",$1,$7,$2,$3,$4,$5
            }'
    fi 

}

print_interrupts_for_8_cores () 
{ 
#     echo $FUNCNAME
    if (( ${screen} == 1 || ${screen} == 0 )) ; then 

        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU0 CPU1 CPU2 CPU3 CPU4 CPU5 CPU6 CPU7;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$11,$2,$3,$4,$5,$6,$7,$8,$9
            }'
    fi
}

print_interrupts_for_16_cores () 
{ 
#     echo $FUNCNAME
    if (( ${screen} == 1 || ${screen} == 0 )) ; then 

        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU0 CPU1 CPU2 CPU3 CPU4 CPU5 CPU6 CPU7;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$19,$2,$3,$4,$5,$6,$7,$8,$9
            }'
    fi

    echo 

    if (( ${screen} == 2 || ${screen} == 0 )) ; then 

        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU8 CPU9 CPU10 CPU11 CPU12 CPU13 CPU14 CPU15;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$19,$10,$11,$12,$13,$14,$15,$16,$17
            }'
    fi

}

print_interrupts_for_24_cores ()
{
#     echo $FUNCNAME

    if (( ${screen} == 1 || ${screen} == 0 )) ; then 
        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU0 CPU1 CPU2 CPU3 CPU4 CPU5 CPU6 CPU7;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$27,$2,$3,$4,$5,$6,$7,$8,$9
            }'
    fi

    echo

    if (( ${screen} == 2 || ${screen} == 0 )) ; then 
        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU8 CPU9 CPU10 CPU11 CPU12 CPU13 CPU14 CPU15;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$27,$10,$11,$12,$13,$14,$15,$16,$17
            }'
    fi

    echo

    if (( ${screen} == 3 || ${screen} == 0 )) ; then 
        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU16 CPU17 CPU18 CPU19 CPU20 CPU21 CPU22 CPU23;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$27,$18,$19,$20,$21,$22,$23,$24,$25
            }'
    fi
}

print_interrupts_for_32_cores () 
{
#     echo $FUNCNAME

    if (( ${screen} == 1 || ${screen} == 0 )) ; then 
        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU0 CPU1 CPU2 CPU3 CPU4 CPU5 CPU6 CPU7;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$35,$2,$3,$4,$5,$6,$7,$8,$9
            }'
    fi

    echo

    if (( ${screen} == 2 || ${screen} == 0 )) ; then 
        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU8 CPU9 CPU10 CPU11 CPU12 CPU13 CPU14 CPU15;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$35,$10,$11,$12,$13,$14,$15,$16,$17
            }'
    fi

    echo

    if (( ${screen} == 3 || ${screen} == 0 )) ; then 
        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU16 CPU17 CPU18 CPU19 CPU20 CPU21 CPU22 CPU23;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$35,$18,$19,$20,$21,$22,$23,$24,$25
            }'
    fi

    echo

    if (( ${screen} == 4 || ${screen} == 0 )) ; then 
        printf "%-19s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n" "interrupt" CPU24 CPU25 CPU26 CPU27 CPU28 CPU29 CPU30 CPU31;
        cat /proc/interrupts | grep -i eth${interface} | 
            awk '{
                printf "%-4d %-12s | %-10d %-10d %-10d %-10d %-10d %-10d %-10d %-10d\n",$1,$35,$26,$27,$28,$29,$30,$31,$32,$33
            }'
    fi

}

case ${number_of_cores} in 
    4) 
        print_interrupts_for_4_cores
	;;
    8) 
        print_interrupts_for_8_cores
        ;;
    16) 
        print_interrupts_for_16_cores
        ;;
    24) 
        print_interrupts_for_24_cores
        ;;
    32)
        print_interrupts_for_32_cores
        ;;
esac
