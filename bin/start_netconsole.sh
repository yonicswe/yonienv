#!/bin/bash

if [ -z "$1" ]; then
	echo "provide the IP of the receiver."
	exit 1
fi

receiver_port=${2:-12346};

receiverIP=$(ping $1 -c 1 2>/dev/null | grep PING | sed -r -e 's/.*\(([0-9]+.[0-9]+.[0-9]+.[0-9]+)\).*/\1/')
nextHopIP=$(ip r g ${receiverIP} | sed -e '/.*via.*/s/.*via \([^ ]*\).*/\1/gp' | sed -ne 's/^\([0-9.]\+\).*/\1/gp' | tail -n1)
receiverMAC=$(ping ${nextHopIP} -c 1 >/dev/null 2>&1 && ip n s ${nextHopIP} | cut -d' ' -f'5' 2>/dev/null)
#receiverMAC=$(ping ${receiverIP} -c 1 >/dev/null 2>&1 && ip n s | tail -1 | cut -d' ' -f'5' 2>/dev/null)
senderIF=$(ip r g $receiverIP | sed -ne 's/^.*dev[[:space:]]*\([a-zA-Z0-9]\+\).*/\1/p')
senderIP=$(ip a s dev $senderIF | awk -F" " '$1=="inet" {print $2}' | sed 's/\([^\/]\+\).*/\1/g')
#senderIF=$(route 2>/dev/null | tail -1 | awk '{print $NF}')
echo senderIP:    $senderIP
echo senderIF:    $senderIF
echo receiverIP:  $receiverIP
echo receiverMAC: $receiverMAC
echo
echo "Run in $receiverIP: nc -u -l ${receiver_port}"
echo
dmesg -n8
modprobe -r netconsole
cmd="sudo modprobe netconsole netconsole=1111@${senderIP}/${senderIF},${$2}@${receiverIP}/${receiverMAC}"
echo "Running: $cmd"
$cmd
