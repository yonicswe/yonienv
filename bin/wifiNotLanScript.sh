#!/bin/bash

# validateState () 
# { 
#     local lan=$(ip link show eth0 | grep "state UP" | wc -l );
#     local wifi=$(ip link show wlan0 | grep "state UP" | wc -l );
#     echo "lan: $lan, wifi: $wifi";
#     [ ${wifi} -eq ${lan} ] && return 1;
#     wifiNotLan=${wifi}
# }
# 
# startLan () 
# { 
#     local start=$1;
#     if [ ${start} -eq 1 ]; then
#         ifup eth0;
#         restartDhcp eth0;
#     else
#         ifdown eth0;
#     fi
# }
# 
# startNotStopWifi () 
# { 
#     local start=$1;
#     if [ ${start} -eq 1 ]; then
#         service wpa_supplicant start;
#         ifup wlan0;
#         restartDhcp wlan0;
#     else
#         service wpa_supplicant stop;
#         ifdown wlan0;
#     fi
# }
# changeState () 
# { 
#     wifiNotLan=$( [ ${wifiNotLan} -eq 1 ] && echo 0 || echo 1 )
# }

# main () 
# { 
#     local ret;
#     validateState;
#     ret=$?;
#     [ ${ret} -ne 0 ] && return 1;
#     changeState;
#     if [ ${wifiNotLan} -eq 1 ]; then
#         startLan 0;
#         startNotStopWifi 1;
#     else
#         startNotStopWifi 0;
#         startLan 1;
#     fi;
#     showState;
#     ethlist
# }
# 
# main "$@"
# su -c "wifiNotLan; $SHELL"
su -c "wifiNotLan;"



