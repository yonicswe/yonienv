#!/bin/bash

echo "maximum number of packets, queued on the INPUT side"
echo "previous value : "
echo -e "\tcat /proc/sys/net/core/netdev_max_backlog : $(cat /proc/sys/net/core/netdev_max_backlog)"
echo "setting : "
echo -e "\techo 5000 > /proc/sys/net/core/netdev_max_backlog"
echo 5000 > /proc/sys/net/core/netdev_max_backlog 

echo "The default and maximum amount for the receive socket memory"
echo "previous value"
echo -e "\tcat /proc/sys/net/core/rmem_default : $(cat /proc/sys/net/core/rmem_default)"
echo -e "\tcat /proc/sys/net/core/rmem_max : $(cat /proc/sys/net/core/rmem_max)"
echo "setting : "
echo -e "\techo 20971520 > /proc/sys/net/core/rmem_default"
echo 20971520 > /proc/sys/net/core/rmem_default
echo -e "\techo 20971520 > /proc/sys/net/core/rmem_max"
echo 20971520 > /proc/sys/net/core/rmem_max 

# service irqbalance stop
service cpuspeed stop

cat <<- EOF 
To set permanently  use sysctl 
==============================
echo 'net.core.rmem_max=20971520' >> /etc/sysctl.conf
echo 'net.core.rmem_default=20971520' >> /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf

reload settings     
sysctl -p 
EOF
