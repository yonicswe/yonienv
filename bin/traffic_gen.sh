#!/bin/bash

#
# validate the user chosen interface
#
validate_interface ()
{ 
    local interface=${1};
    local found;
    local interface_list=( $(ifconfig | grep eth | awk '{print $1}') ) 

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
            return 1;
        fi        
    fi

    return 0;
}

root_permission () 
{ 
    # make sure that user has root permission
    if (( $(id -u ) != 0 )) ; then 
        echo "You must be root" 
        return 1;  
    fi    

    return 0;        
}

sanity_validate ()
{
    local r;

    root_permission;
    r=$?;
    [ $r -ne 0 ] && return 1;

    validate_interface;
    r=$?;
    [ $r -ne 0 ] && return 1;

    return 0;
}

#
# get speed from user
#
get_speed () 
{ 
    local speed;
    local speed_default=200;

    read -p "Enter speed (${speed_default}Mbps) : " speed
    if [ -z ${speed} ] ; then
        speed=${speed_default};
    fi

    echo ${speed};            
}

#
# get loops from user
#
get_loops ()
{
    local loops;
    read -p "Enter loops (0) : " loops
    if [ -z ${loops} ] ; then
        loops=0;
    fi

    echo ${loops};
}

# start the test
traffic_runner () 
{

    local speed=$1;
    local loops=${2};
    local interface=${3};
    local pcap=${4};
    local instances=1;

    for i in `seq 1 ${instances}` ; do 

        #  run instances in the background.
        echo -e "tcpreplay -l ${loops} -M ${speed}  -q --stats=5 -i eth${interface} ${pcap}&"
        tcpreplay -l ${loops} -M ${speed}  -q --stats=5 -i eth${interface} ${pcap}&
        
        
        # save the pid in array         
        p=$!
        a+=($p)
        echo "started eth${interface} pid $p at speed ${speed}"	

        if (( ${multiple_interface} != 0  )) ; then 
            (( interface++ )) 
        fi 
    done

}




#
# Main
#
main () 
{
    local interface=${1}
    local pcap=${2}
    local multiple_interface=${4:-0}

    sanity_validate;
    [ $? -ne 0 ] && return 1;


    speed=$(get_speed);
    loops=$(get_loops);

    traffic_runner ${speed} ${loops} ${interface} ${pcap} 

    #
    # stop all when user press key        
    #
    echo "running tcpreplay pid list : ${a[*]}"
    read x
    for ((i=0 ;i< ${#a[*]} ; i++ )) ; do 
        echo "kill ${a[$i]}"
        kill ${a[$i]}
    done

    return 0;        
}

main "$@";



