#!/bin/bash

#  ___  ___  ___       ___  _           __   __ 
# |_ _|| _ \/ __|     / __|| |_  _  _  / _| / _|
#  | | |  _/\__ \     \__ \|  _|| || ||  _||  _|
# |___||_|  |___/     |___/ \__| \_,_||_|  |_|  
#                                               

alias editbashnice='g ${yonienv}/bashrc_nice.sh'

ICMBUILD_VARS_BAK_FILE_NAME=~/.icmbuild_var.bak
if [ -e ${ICMBUILD_VARS_BAK_FILE_NAME} ] ; then 
	source ${ICMBUILD_VARS_BAK_FILE_NAME} ;		
fi

SBUILD_VARS_BAK_FILE_NAME=~/.sbuild_var.bak
if [ -e ${SBUILD_VARS_BAK_FILE_NAME} ] ; then 
	source ${SBUILD_VARS_BAK_FILE_NAME} ;		
fi

complete -W "we  browsing  ipdr  stability  protocols  half_duplex  sandvine  metadata radius dns ips"  config_setup

tailstatistics () 
{
    # print timeout of each statistics dump
    echo -e "$(getconfigdir)\n"
    echo -e "$(grep Diag $(getconfigdir)/IPS_Analyzer.xml|sed 's|[[:space:]]*||g')\n"

    tail -n40 -f $(getlogdir)/SystemDiagnostics.log | 
        awk '/^Processed/{print "--------------------------------------\n"$0"\n--------------------------------------"} 
             /^Used/     {print "Packet Pool "$0"\n--------------------------------------"} 
             /PP#/       {
                             printf "%5s %s|%s %-10s %-16s|%s %s %s|%-10s %s|%-10s %s|%s %s|%s %s %s%s\n",  
                                     $1, $2,$3,$4a  ,$5,   $6,$7,$8,$9, $10,$11,$12,$13,$14,$15,$16,$17,$18  
                         }'
}

ips_affinity_threads () 
{
    declare -a affinity_list;

    [ -z $(pgrep Analyzer)  ] && return;
    affinity_list=( $( ps --no-headers H -C Analyzer -o tid | while read tid ; do taskset -c -p ${tid}|sed 's/.*://g' ; done ) ); 
    c=0;
    printf "%-20s %-10s %-20s\n" THREAD TID AFFINITY
    ps --no-headers  H -C Analyzer -o 'comm tid' | while read -a p ; do 
#         echo "${p[*]} ${affinity_list[$c]}"
        printf "%-20s %-10s %-20s\n" ${p[*]} ${affinity_list[$c]}
        (( c++ ));
    done
}

ips_sockets () 
{
    local continues=$1;
    local analyzer_pid=$( ps  h -C Analyzer -o pid ) ;
    [ -z ${analyzer_pid} ] && return ;

    if [ $(id -u) -ne 0 ] ; then 
        echo "!!!! invoke as root !!!!"
        return;
    fi

    if [ -z ${continues} ] ; then 
        netstat -taulpn  | grep ${analyzer_pid};
    else
        netstat -taulpnc | grep ${analyzer_pid};
    fi
}

acs_sockets () 
{
    local continues=$1;
    local acs_pid=$( ps  h -C acs -o pid ) ;
    [ -z ${acs_pid} ] && return ;

    if [ $(id -u) -ne 0 ] ; then 
        echo "!!!! invoke as root !!!!"
#         return;
            su  -c "acs_sockets"
    fi

    if [ -z ${continues} ] ; then 
        netstat -taulpn  | grep ${acs_pid};
    else
        netstat -taulpnc | grep ${acs_pid};
    fi
}

ips_threads () 
{
    local watch_interval=$1;
    if [ -z ${watch_interval} ] ; then 
        watch_threads 0 Analyzer;
    else 
        watch_threads watch_interval Analyzer;
    fi
}

acs_threads () 
{
    local watch_interval=$1;
    if [ -z ${watch_interval} ] ; then 
        watch_threads 0 acs;
    else 
        watch_threads ${watch_interval} acs;
    fi
}

watch_threads () 
{
    local watch_interval=$1;
    local threadName=$2;
    local analyzer_pid=$( ps  h -C ${threadName} -o pid ) ;
    [ -z ${analyzer_pid} ] && return ;

    if (( 0 == ${watch_interval} )) ; then 
        ps H -C ${threadName} -o 'comm tid pid stat psr nice pri time pcpu' 
    else
#         watch -t -n1 --differences=cumulative "ps H -C Analyzer -o 'comm tid pid psr nice pri time pcpu sgi_p'"
        watch -t -n${watch_interval} "ps H -C ${threadName} -o 'comm tid pid stat psr nice pri time pcpu sgi_p'"
    fi        
#     local analyzer_pid=$(pgrep Analyzer);
#     local -a tid_list;
#     local -a core_affinity_list;
#     local -a core_list;
# 
#     if [ -z ${analyzer_pid} ] ; then 
#         echo "Analyzer not running"
#         return;
#     fi
# 
#     pstree ${analyzer_pid}; 
#     tid_list=( $(ps hH -o tid ${analyzer_pid}) )
# #   core_list=( "$(ps hH -o sgi_p ${analyzer_pid})" )
#     for (( i=0 ; i < ${#tid_list[*]} ; i++ )) ; do 
#         core_affinity_list[$i]="$(taskset -c -p ${tid_list[$i]} | awk '{print $6}')"
#     done
# 
#     for (( i=0 ; i < ${#tid_list[*]} ; i++ )) ; do 
#         printf "%s %s %s\n" ${tid_list[$i]} ${core_affinity_list[$i]} ${core_list[$i]} 
#     done
}

ips_kill () 
{
    local ips_pid;

    ips_pid=$(ps h -C Analyzer -o pid)

    if [ -z ${ips_pid} ] ; then 
        echo "ips is not running"
        return;
    else                
        kill -9 ${ips_pid}
        sleep 2;
        ips_pid="";
        ips_pid=$(ps h -C Analyzer -o pid);
        if [ -n "${ips_pid}" ] ; then 
            echo "failed to kill ips (${ips_pid})";
        fi
    fi
}

acx_threads ()
{
    ps H -C acx -o 'comm tid pid stat psr nice pri time pcpu sgi_p' --sort '+time'
}

# ips_run () 
# {
    # for this to work you need to add the following to /etc/sudoers
    # kuser ALL=(ALL) NOPASSWD:ALL

#     sudo NTI_CONFIG_PATH=${NTI_CONFIG_PATH} LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${LD_LIBRARY_PATH}/Analyzer
# }

ips_telnet () 
{
    echo "user/pass : ipsuser 1234"
    telnet 127.0.01 24987
#     rlwrap telnet 127.0.01 24987
#     socat readline,history=$HOME/.telnet_history TCP:127.0.0.1:24987

}

acs_telnet ()
{
    echo "user/pass : acsuser 1234"
    telnet 127.0.01 24987
}

task_list () 
{
    find ~/share/tasks/  -maxdepth 1 -type d
    echo 
}

# export IFS="\n";

complete_task_list () 
{
    if [ -d ~/share/tasks/ ] ; then 
        complete -W "$(find ~/share/tasks/ -maxdepth 1 -mindepth 1 -type d -exec basename {} \; ) release" sbuild_vars icm_sbuild_vars acs_build_vars cdsrc cdtask
#       complete -F task_list sbuild_vars
    fi

}

TASK_PATH=~/share/tasks

sbuild_vars () 
{
    local working_path=$1; 
	local debug_release=${2:-debug}
    local project="";

    if [ -n "$working_path" ] ; then 

        if [ "$1" = '-z' ] ; then 
            unset TASK_PATH;
            unset IPS_PATH;
            unset NICETRACKDIR;
            unset LD_LIBRARY_PATH;
            unset NTI_CONFIG_PATH;
            unset NTI_INJECTOR_CONFIG_PATH;
            unset CFG;

			if [ -e ${SBUILD_VARS_BAK_FILE_NAME} ] ; then 
				rm -f ${SBUILD_VARS_BAK_FILE_NAME} ;		
			fi

        else 

            if ! [ -d ${working_path} ] ; then
                project=$(readlink -f ${HOME}/work/${working_path});
            fi                


            if [ -d "${project}" ] ; then 
                working_path=${project};
            else
                working_path=$(readlink -f ${working_path});
            fi


            if [ -d ${working_path} -a  -n ${working_path} ] ; then 

                export NICETRACKDIR=${working_path}/src/NiceTrackI/bin/${debug_release}/
                echo "export NICETRACKDIR=${NICETRACKDIR}" > ${SBUILD_VARS_BAK_FILE_NAME}

                if [ "${debug_release}" = "release" ] ; then
                    export CFG=Release;
                    echo "export CFG=Release" >> ${SBUILD_VARS_BAK_FILE_NAME};
                else
                    export CFG=Debug;
                    echo "export CFG=Debug" >> ${SBUILD_VARS_BAK_FILE_NAME};
                fi

                export LD_LIBRARY_PATH=$NICETRACKDIR
                echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME} 

                export NTI_CONFIG_PATH=${working_path}/config
                echo "export NTI_CONFIG_PATH=${NTI_CONFIG_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME}

                export NTI_INJECTOR_CONFIG_PATH=${working_path}/config
                echo "export NTI_INJECTOR_CONFIG_PATH=${NTI_INJECTOR_CONFIG_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME}

                export IPS_PATH=${working_path}/src
                echo "export IPS_PATH=${IPS_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME}
                
                export TASK_PATH=${working_path}
                echo "export TASK_PATH=${TASK_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME}

                cd ${IPS_PATH}/NiceTrackI;
            fi 
        fi 
    fi
    
    printf "%-30s = %s\n" "TASK_PATH"                ${TASK_PATH};
    printf "%-30s = %s\n" "IPS_PATH"                 ${IPS_PATH};
    printf "%-30s = %s\n" "NTI_CONFIG_PATH"          ${NTI_CONFIG_PATH};
    printf "%-30s = %s\n" "NICETRACKDIR"             ${NICETRACKDIR};
    printf "%-30s = %s\n" "LD_LIBRARY_PATH"          ${LD_LIBRARY_PATH};
    printf "%-30s = %s\n" "CFG"                      ${CFG};

	source ~/share/ipteam_env/aliases

    complete_task_list;
}

generate_wbe () 
{ 
    customer=$1
    
    if ! [ -z "${customer}" ] ; then 
        customer=$(readlink -f ${customer})
        ! [ -e ${customer} ] && return 1;
    fi             

    pushd $NTI_PATH/Applications/HTTPWebEngine/resources/blacklistsGenerator 1>/dev/null;
	python blackListGenerator.py -i $XML_DIR; 
	popd  1>/dev/null;

	pushd $XML_DIR
    if [ -z "${customer}" ] ; then 
        echo "generating wbe files for all xml files"
        find . -name "*xml" | while read xml ; do cp --parent $xml $WBEIN_DIR ; done
    else
        echo "generating wbe files only for xml files listed in ${customer}"
        cat ${customer} |
            sed 's/xmlfiles\///g' | 
                while read xml ; do 
                    cp --parent $xml $WBEIN_DIR ;
                done 
    fi
	popd  1>/dev/null;

	pushd $NTI_PATH/Applications/HTTPWebEngine/resources/wbeGenerator 1>/dev/null;
	python WbeGenerator.py -i $WBEIN_DIR; 
	popd  1>/dev/null;

#     pushd $WBEIN_DIR
#     find . -type f ! -name "*.wbe" -exec rm -f {} \;
# 	popd  1>/dev/null;
} 

getconfigdir () 
{
    if [ -z ${NTI_CONFIG_PATH}  ] ; then 
        if [ -d /etc/nice/ips ] ; then 
            echo "/etc/nice/ips"
        fi
    else
        echo ${NTI_CONFIG_PATH}            
    fi

}

alias cdconfig='cd $(getconfigdir)'

getlogdir () 
{
    local c=/etc/nice/ips/analyzer_log.ini;
    local l=appender.rolling.fileName;

    if [ -z ${NTI_CONFIG_PATH}  ] ; then 
        if [ -e $c ] ; then 
            export LOG_DIR=$(grep  ${l} ${c} | sed 's/.*=//g'|xargs dirname)
        fi
    fi 

    echo ${LOG_DIR};

}

alias cdlog='cd $(getlogdir)'

cdbundle () 
{
    local c=/etc/nice/ips/IPS_Analyzer.xml;
    local l=BundleDataFile;

    if [ -z ${NTI_CONFIG_PATH}  ] ; then 
        if [ -e $c ] ; then 
            export BUNDLE_PATH=$( grep ${l} ${c} | sed 's/\(<.*>\)\(.*\)\(<.*>\)/\2/' | xargs dirname ) 
        fi
    fi 

    cd ${BUNDLE_PATH}
}

cdtask () 
{
    local task=$1;

    complete_task_list        

    if [ -z ${task} ] ; then 
        cd ${TASK_PATH}
    else
        t=~/share/tasks/${task};
        [ -d $t ] && cd $t 
    fi
}

cdsrc () 
{
    local task=$1;
    if [ -z ${task} ] ; then 
        cd ${TASK_PATH}/src
    else
        t=~/work/${task}/src
        [ -d $t ] && cd $t 
    fi
}

setup_ips_gdbinit () 
{
    setup_gdbinit ${NTI_PATH} Analyzer ${LD_LIBRARY_PATH}
}

setup_icm_gdbinit () 
{
    setup_gdbinit ${ICM_SRC_PATH} icm ${LD_LIBRARY_PATH}
}

setup_acs_gdbinit () 
{
    setup_gdbinit ${ACS_PATH} acs ${ACS_PATH}/Projects/ACS/5.0.0/output/Linux/bin/
}

# ===================== ICM Stuff ================================
#  ___   ___  _   _
# |_ _| / __|| \_/ |
#  | | | (__ | | | | 
# |___| \___||_| |_|
#                  

icm_sockets () 
{
    local continues=$1;
    local icm_pid=$( ps  h -C icm -o pid ) ;
    [ -z ${icm_pid} ] && return ;

#    if [ $(id -u) -ne 0 ] ; then 
#        echo "!!!! invoke as root !!!!"
#        return;
#    fi

    if [ -z ${continues} ] ; then 
        netstat -taulpn  | grep ${icm_pid};
    else
        netstat -taulpnc | grep ${icm_pid};
    fi
}

icm_threads () 
{
    local watch_interval=$1
    local icm_pid=$( ps  h -C icm -o pid ) ;
    [ -z ${icm_pid} ] && return ;

    if [ -z ${watch_interval} ] ; then 
        ps H -C icm -o 'comm tid pid stat psr nice pri time pcpu' 
    else
#         watch -t -n1 --differences=cumulative "ps H -C icm -o 'comm tid pid psr nice pri time pcpu sgi_p'"
        watch -t -n${watch_interval} "ps H -C icm -o 'comm tid pid stat psr nice pri time pcpu sgi_p'"
    fi        
}

icm_sbuild_vars ()
{
    local working_path=$1; 
	local debug_release=${2:-debug}
    local project="";

    if [ -n "$working_path" ] ; then 

        if [ "$1" = '-z' ] ; then 
            unset NICETRACKDIR
            unset LD_LIBRARY_PATH
            unset ICM_CONFIG_PATH
			unset ICM_SRC_PATH
			unset TASK_PATH
            unset CFG;

			if [ -e ${ICMBUILD_VARS_BAK_FILE_NAME} ] ; then 
				rm -f ${ICMBUILD_VARS_BAK_FILE_NAME} ;		
			fi

        else 

            if ! [ -d ${working_path} ] ; then
                project=$(readlink -f ${HOME}/work/${working_path});
            fi                


            if [ -d "${project}" ] ; then 
                working_path=${project};
            else
                echo -e "!! PROJECT '${project}' DOES NOT EXIST !!";
            fi


            if [ -d ${working_path} -a  -n ${working_path} ] ; then 

                export NICETRACKDIR=${working_path}/bin/${debug_release}/
                echo "export NICETRACKDIR=${NICETRACKDIR}" > ${ICMBUILD_VARS_BAK_FILE_NAME}

                if [ "${debug_release}" = "release" ] ; then
                    export CFG=Release;
                    echo "export CFG=Release" >> ${ICMBUILD_VARS_BAK_FILE_NAME};
                else
                    export CFG=Debug;
                    echo "export CFG=Debug" >> ${ICMBUILD_VARS_BAK_FILE_NAME};
                fi

                export LD_LIBRARY_PATH=$NICETRACKDIR
                echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> ${ICMBUILD_VARS_BAK_FILE_NAME} 

                export ICM_CONFIG_PATH=${working_path}/config/
                echo "export ICM_CONFIG_PATH=${ICM_CONFIG_PATH}" >> ${ICMBUILD_VARS_BAK_FILE_NAME}

                export ICM_SRC_PATH=${working_path}/src/
                echo "export ICM_SRC_PATH=${ICM_SRC_PATH}" >> ${ICMBUILD_VARS_BAK_FILE_NAME}

                export TASK_PATH=${working_path}
                echo "export TASK_PATH=${TASK_PATH}" >> ${ICMBUILD_VARS_BAK_FILE_NAME}

                cd ${TASK_PATH}/;
            fi 
        fi 
    fi
    
    printf "%-30s = %s\n" "TASK_PATH"                ${TASK_PATH}
    printf "%-30s = %s\n" "ICM_SRC_PATH"             ${ICM_SRC_PATH}
    printf "%-30s = %s\n" "ICM_CONFIG_PATH"          ${ICM_CONFIG_PATH}
    printf "%-30s = %s\n" "NICETRACKDIR"             ${NICETRACKDIR}
    printf "%-30s = %s\n" "LD_LIBRARY_PATH"          ${LD_LIBRARY_PATH}
    printf "%-30s = %s\n" "CFG"                      ${CFG};

	source ~/share/ipteam_env/aliases

    complete_task_list;
}

complete_task_list;

icm_kill () 
{
    local icm_pid;

    icm_pid=$(ps h -C icm -o pid)

    if [ -z ${icm_pid} ] ; then 
        echo "icm is not running"
        return;
    else                
        kill -9 ${icm_pid}
        sleep 2;
        icm_pid="";
        icm_pid=$(ps h -C icm -o pid);
        if [ -n "${icm_pid}" ] ; then 
            echo "failed to kill icm (${icm_pid})";
        fi
    fi
}

#        _    ___  ___ 
#       /_\  / __|/ __|
#      / _ \| (__ \__ \
#     /_/ \_\\___||___/
#                      
acs_build_vars () 
{
    local working_path=$1; 
	local debug_release=${2:-debug}
    local project="";
    
    if [ -n "$working_path" ] ; then 

        if [ "$1" = '-z' ] ; then 
            unset TASK_PATH;
            unset ACS_PATH;
            unset LD_LIBRARY_PATH;
            unset NT_CONFIG_PATH;
            unset NTI_CONFIG_PATH;
            unset CFG;

			if [ -e ${SBUILD_VARS_BAK_FILE_NAME} ] ; then 
				rm -f ${SBUILD_VARS_BAK_FILE_NAME} ;		
			fi

        else 

            if ! [ -d ${working_path} ] ; then
                project=$(readlink -f ${HOME}/work/${working_path});
            fi                


            if [ -d "${project}" ] ; then 
                working_path=${project};
            else
                working_path=$(readlink -f ${working_path});
            fi


            if [ -d ${working_path} -a  -n ${working_path} ] ; then 

                export ACS_PATH=${working_path}/
                echo "export ACS_PATH=${ACS_PATH}" > ${SBUILD_VARS_BAK_FILE_NAME}

                export NICETRACKDIR=${ACS_PATH}/Projects/ACS/5.0.0/output/Linux/bin
                echo "export NICETRACKDIR=${NICETRACKDIR}" >> ${SBUILD_VARS_BAK_FILE_NAME}

                if [ "${debug_release}" = "release" ] ; then
                    export CFG=Release;
                    echo "export CFG=Release" >> ${SBUILD_VARS_BAK_FILE_NAME};
                else
                    export CFG=Debug;
                    echo "export CFG=Debug" >> ${SBUILD_VARS_BAK_FILE_NAME};
                fi

                LD_LIBRARY_PATH="${ACS_PATH}/3d_party/ASN1/oss/linux64/output/Linux/lib"
                LD_LIBRARY_PATH+=":${ACS_PATH}/3d_party/ASN1/oss/linux64/output/Linux/usr/lib64/"
                LD_LIBRARY_PATH+=":${ACS_PATH}/3d_party/Oracle/output/Linux/usr/lib64"
                LD_LIBRARY_PATH+=":${ACS_PATH}/3d_party/Oracle/linux64/lib"
                LD_LIBRARY_PATH+=":${ACS_PATH}/LKP/4.6/output/Linux/lib/"
                LD_LIBRARY_PATH+=":${ACS_PATH}/Infrastructure/5.0.0/output/Linux/lib"
                LD_LIBRARY_PATH+=":${ACS_PATH}/Projects/Common/5.0.0/output/Linux/lib"
                LD_LIBRARY_PATH+=":${ACS_PATH}/Projects/ACS/5.0.0/output/Linux/lib/"
                export LD_LIBRARY_PATH
                echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME} 
                export NT_CONFIG_PATH=${working_path}/config
                echo "export NT_CONFIG_PATH=${NT_CONFIG_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME}
                export NTI_CONFIG_PATH=${NT_CONFIG_PATH}
                echo "export NTI_CONFIG_PATH=${NTI_CONFIG_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME}

                export TASK_PATH=${working_path}
                echo "export TASK_PATH=${TASK_PATH}" >> ${SBUILD_VARS_BAK_FILE_NAME}

                cd ${ACS_PATH};
            fi 
        fi 
    fi
    
    printf "%-30s = %s\n" "TASK_PATH"                ${TASK_PATH};
    printf "%-30s = %s\n" "ACS_PATH"                 ${ACS_PATH};
    printf "%-30s = %s\n" "NT_CONFIG_PATH"           ${NT_CONFIG_PATH};
    printf "%-30s = %s\n" "CFG"                      ${CFG};
    printf "%-30s = %s\n" "LD_LIBRARY_PATH"          "$(echo ${LD_LIBRARY_PATH} | sed 's/:/\n\t\t\t\t\ /g')";

	source ~/share/ipteam_env/aliases

    complete_task_list;
}

export wifiNotLanGlobal=0

# 
#  when wifi does not load try 
#     service wpa_supplicant start
#  
#  when there is no ip address try to 
#  dhclient -r wlan0 
#  dhclient wlan0 


showState()
{ 
    echo "---state : $([ ${wifiNotLanGlobal} -eq 1 ] && echo "Wifi" || echo "Lan")---"
}
export -f showState

changeState () 
{
    wifiNotLanGlobal=$( [ ${wifiNotLanGlobal} -eq 1 ] && echo 0 || echo 1 );	
}
export -f changeState

validateState ()
{
    local lan=$(ip link show eth0 | grep "state UP" | wc -l )
    local wifi=$(ip link show wlan0 | grep "state UP" | wc -l )
    echo "lan: $lan, wifi: $wifi" 
    [ ${wifi} -eq ${lan} ] && return 1;
    wifiNotLanGlobal=${wifi}
}
export -f validateState

restartDhcp () 
{
    local dev=${1};       
    dhclient -r ${dev};
    dhclient ${dev};
}
export -f restartDhcp

startNotStopLan () 
{
    local start=$1
    if [ ${start} -eq 1 ] ; then  
        ifup   eth0; 
        restartDhcp eth0;
    else
        ifdown eth0;
    fi        
}
export -f startNotStopLan

startNotStopWifi () 
{
    local start=$1;
    if [ ${start} -eq 1 ] ; then  
        service wpa_supplicant start;
	    ifup wlan0;
        restartDhcp wlan0;
    else
        service wpa_supplicant stop;
	    ifdown wlan0;
    fi
}
export -f startNotStopWifi

wifiNotLan ()
{ 
    local ret;
    validateState
    ret=$?
    [ ${ret} -ne 0 ] && return 1
    
    changeState;

    if [ ${wifiNotLanGlobal} -eq 1 ] ; then 
        startNotStopLan  0
        startNotStopWifi 1
	else	    
        startNotStopWifi 0
        startNotStopLan  1 
    fi 
    
    showState;

    ethlist

}
export -f wifiNotLan

#     _     ____ __  __
#    / \   / ___|\ \/ /
#   / _ \ | |     \  / 
#  / ___ \| |___  /  \ 
# /_/   \_\\____|/_/\_\
#                      

alias cdacxsrc="cd /home/kuser/work/acx/acx/"
alias cdacx="cd /home/kuser/work/acx/acx/acx"
alias cdacxbin="cd /home/kuser/work/acx/acx/acx/Debug"
alias cdacxconfig="cd /home/kuser/work/acx/config"
alias cdacxlogs="cd /home/kuser/work/acx/logs"
alias cdacxstorage="cd /home/kuser/work/acx/storage"
alias runacx="cdacx; ./Debug/acx -f /home/kuser/work/ACX_TRUNK/acx/acx/acx-fc-dum-rep.xml"
alias makeacx="cdacx; make --makefile=acx.mak CFG=Debug"

acx_threads ()
{
        ps H -C acx -o 'comm tid pid stat psr nice pri time pcpu sgi_p' --sort '+time'
}
