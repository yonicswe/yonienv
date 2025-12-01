#!/bin/bash

echo "TCP connections with interface names:"
# Get all TCP connections

ss -t -n | awk 'NR>1 {print $4, $5}' | while read local remote; do
    # Extract the IP address and port
    local_ip=$(echo $local | cut -d: -f1)
    remote_ip=$(echo $remote | cut -d: -f1)

    # Get the interface name for the local IP
    iface=$(ip -o addr show | grep "inet $local_ip" | awk '{ print $2 }')
    echo "Local: $local (Interface: $iface) <---> Remote: $remote"
done
