#!/bin/bash

# 97                               94
# 7c:fe:90:75:3e:20 13.134.97.1/16 7c:fe:90:75:3e:58 13.134.94.1/16
# 7c:fe:90:d5:ba:9c 11.134.97.1/16 7c:fe:90:d5:ba:90 11.134.94.1/16
# 7c:fe:90:d5:ba:9d 12.134.97.1/16 7c:fe:90:d5:ba:91 12.134.94.1/16

# dev-l-vrt-097
macs97=("7c:fe:90:75:3e:20" "7c:fe:90:d5:ba:9c" "7c:fe:90:d5:ba:9d")
ips97=("13.134.97.1/16"     "11.134.97.1/16"    "12.134.97.1/16")

# dev-l-vrt-094
macs94=("7c:fe:90:75:3e:58" "7c:fe:90:d5:ba:90" "7c:fe:90:d5:ba:91")
ips94=( "13.134.94.1/16"    "11.134.94.1/16"    "12.134.94.1/16")

# dev-l-vrt-146-005
#             ens5                 ens6
macs1465=( "e4:1d:2d:ae:86:f9" "e4:1d:2d:ae:86:f8")
ips1465=(  "11.134.146.5/16"   "12.134.146.5/16"   )

# dev-l-vrt-145-005
#             ens5                 ens6
macs1455=("e4:1d:2d:ae:87:0c" "e4:1d:2d:ae:87:0d")
ips1455=( "11.134.145.5"      "12.134.145.5"   )

resolve_intf_from_mac () 
{
    mac=${1};
    local candidate_mac;

    for i in /sys/class/net/* ; do 
        candidate_mac=$(cat ${i}/address);
        if [ "${candidate_mac}" == "${mac}" ] ; then 
            echo $(basename ${i})
            return;
        fi
    done
}

main ()
{ 
    local indx=0;

    if [ $(hostname -s) == "dev-l-vrt-097" ] ;then 
        for i in ${macs97[@]} ; do 
            intf=$(resolve_intf_from_mac ${i})
            ip_addr=${ips97[${indx}]};

            sudo ifconfig ${intf} ${ip_addr}
            ((indx++))
        done    

        return;
    fi

    if [ $(hostname -s) == "dev-l-vrt-094" ] ;then 
        for i in ${macs94[@]} ; do 
            intf=$(resolve_intf_from_mac ${i})
            ip_addr=${ips94[${indx}]};

            sudo ifconfig ${intf} ${ip_addr}
            ((indx++))
        done    
        return;
    fi

    if [ $(hostname -s) == "dev-l-vrt-146-005" ] ;then 
        for i in ${macs1465[@]} ; do 
            intf=$(resolve_intf_from_mac ${i})
            ip_addr=${ips1465[${indx}]};

            sudo ifconfig ${intf} ${ip_addr}
            ((indx++))
        done    
        return;
    fi

    if [ $(hostname -s) == "dev-l-vrt-145-005" ] ;then 
        for i in ${macs1455[@]} ; do 
            intf=$(resolve_intf_from_mac ${i})
            ip_addr=${ips1455[${indx}]};

            sudo ifconfig ${intf} ${ip_addr}
            ((indx++))
        done    
        return;
    fi

    echo "no setup for $(hostname -s)"
}

main $@
