#!/bin/bash



# Get all interfaces and their IPs

IFACES=$(ip -o -br addr show | awk '{ print $1, $3 }')



# Loop through each interface

echo "TCP Connections Per Interface:"

for iface in $IFACES; do

    IFS=' ' read -r IFNAME ADDR <<< "$iface"

    IP=$(echo $ADDR | cut -d'/' -f1) # Extract just the IP address part



    echo -e "\nInterface: $IFNAME ($IP)"

    

    if [ -n "$IP" ]; then

        # Find all TCP connections for this IP

        ss -nt src $IP or dst $IP | awk 'NR > 1 {print $1, $4, $5}' | while read -r state src dst; do

            src_ip=$(echo $src | cut -d: -f1)

            src_port=$(echo $src | cut -d: -f2)

            dst_ip=$(echo $dst | cut -d: -f1)

            dst_port=$(echo $dst | cut -d: -f2)

            echo "State: $state, Source: $src_ip:$src_port, Destination: $dst_ip:$dst_port"

        done

    else

        echo "No IP address assigned."

    fi

done
