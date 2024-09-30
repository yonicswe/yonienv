#!/bin/bash

# node a has 904 in  port-name (nn)
# node b has 984 in  port-name (nn)

subsys=$(nvme list-subsys | head -1|sed 's/.*=//g')

# connect_list=$(nvme list-subsys|grep 904|awk '{print $4 " " $5}'|sed 's/host_traddr=/-w /g'  | sed 's/traddr=/-a /g'|while read l ; do echo "nvme connect -t fc $l -n ${subsys} ;"  ; done)
# echo ${connect_list};

print_connection_list_node_a ()
{
    echo "====== subsystem list node-a ======================";
    if [[ 0 == $(2>/dev/null nvme list-subsys | grep 904 | wc -l) ]] ; then 
        echo "list empty"; 
    else
        2>/dev/null nvme list-subsys | grep 904;
    fi;
    # read -p "continue ?" x;
}

print_connection_list_node_b ()
{
    echo "====== subsystem list node-b ======================";
    if [[ 0 == $(nvme list-subsys | grep 984 | wc -l) ]] ; then 
        echo "list empty"; 
    else
        nvme list-subsys | grep 984;
    fi;
    #read -p "continue ?" x;
}

disconnect_node_a ()
{
    echo "====== disconnect node-a ======================";
        nvme list-subsys|grep 904|cut -f 3 -d ' ' | while read d ; do 
        echo "nvme disconnect -d $d";
        nvme disconnect -d $d;
    done
}

connect_node_a ()
{
    echo "====== connect node-a ======================";
    cat node_904_connection_list | grep 904|awk '{print $4 " " $5}'|sed 's/host_traddr=/-w /g'  | sed 's/traddr=/-a /g'|while read l ; do 
        echo "nvme connect -t fc $l -n ${subsys}";
        nvme connect -t fc $l -n ${subsys};
    done
}

# nvme list-subsys | grep 904 | tee node_904_connection_list;

print_connection_list_node_a;
disconnect_node_a;
print_connection_list_node_a;
