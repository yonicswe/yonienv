#!/bin/bash

arg=$1

hosts=();
hosts_ip=();
hosts_user=();
hosts_pass=();

REMOTE_DESK_DB="${HOME}/ipteam_env/bin/remoteDeskDB.sh";
REMOTE_DESK_TAB_COMPLETE="${HOME}/ipteam_env/bin/remoteDeskDB.complete";
    

init_connections () 
{
    hosts=()
    hosts_ip=()
    hosts_user=()
    hosts_pass=()

    while read x1 x2 x3 x4 ; do
        eval hosts+=("$x1")
        eval hosts_ip+=("$x2")
        eval hosts_user+=("$x3")
        eval hosts_pass+=("$x4")
    done < <(cat ${REMOTE_DESK_DB}) ;
}

usage () 
{
    echo "Add a new Remote connection"
    echo -e "\tconnect2RemoteDesk.sh -a <host> <ip> <user> <password>"

    echo "Delete a Remote connection"
    echo -e "\tconnect2RemoteDesk.sh -d <host>"

}
#--------------------------------------------------------------------------- 

# test if user wants to add a new connection 
# or connect to an existing one.    
if [ "$arg" == "-h" ] ; then 
    usage 
elif [ "$arg" == "-a" ] ; then 
    add_or_connect="add"
elif [ "$arg" == "-d" ] ; then 
    host_to_delete=$2
    sed -i "/^${host_to_delete}.*/d" ${REMOTE_DESK_DB} 
else
    add_or_connect="connect"
    dbName=$arg
fi

init_connections
hosts_size=${#hosts[*]}

if [ "$add_or_connect" == "connect" ] ; then 
    # search for the user 
    for (( i=0; i<${hosts_size}; i++)) ; do 
        if [ "${dbName}" == "${hosts[$i]}" ] ; then 
            echo "rdesktop ${hosts_ip[$i]} -f -k en-us -u ${hosts_user[$i]} -p ${hosts_pass[$i]}"
            rdesktop ${hosts_ip[$i]} -f -k en-us -u ${hosts_user[$i]} -p ${hosts_pass[$i]} -0 & 
#             exit;
        fi 
    done

    echo "printing only"
else    
    echo "add new connection"
    echo "------------------"
    host_name=$2
    host_ip=$3
    host_user=$4
    host_password=$5 

    # add the new user
    echo "$host_name $host_ip $host_user $host_password" >> ${REMOTE_DESK_DB}

    init_connections
    hosts_size=${#hosts[*]}
fi

# echo -n "option : "    
for (( i=0; i<${hosts_size}; i++)) ; do 
     printf "%-13s %-16s %-20s %-16s\n" ${hosts[$i]} ${hosts_ip[$i]} ${hosts_user[$i]} ${hosts_pass[$i]}
#     echo -e "${hosts[$i]}       ${hosts_ip[$i]}"
done

echo -e "complete -W \"$(echo ${hosts[@]})\" connect2remoteDesktop" > ${REMOTE_DESK_TAB_COMPLETE}
source ${REMOTE_DESK_TAB_COMPLETE}
echo
