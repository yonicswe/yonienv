export YONI_CLUSTER=
 
trident_cluster_list=(WX-D0902 WX-D0910 WX-G4033 WX-D0909 WX-D0733 WX-G4011 WX-D0896 WX-D1116 WX-D1111 WX-D1126 RT-G0015 RT-G0017 WK-D0675 WK-D0677 WK-D0666 WX-D1140 RT-G0060 RT-G0068 RT-G0069 RT-G0074 RT-G0072 RT-D0196 RT-D0042 RT-D0064 RT-G0037 WX-H7060 WK-D0023 );
trident_cluster_list_nodes=$(for c in ${trident_cluster_list[@]} ; do echo $(echo $c|awk '{print tolower($0)}' ) $c $c-A $c-B $c-a $c-b ; done)

complete -W "$(echo ${trident_cluster_list_nodes[@]})" dellclustergeneratecfg
export HISTTIMEFORMAT="%D %T " 

# LESS or MAN with color
export LESS_TERMCAP_mb=$'\e[1;32m'      # begin blinking
export LESS_TERMCAP_md=$'\e[1;32m'      # being bold
export LESS_TERMCAP_me=$'\e[0m'         # end mode
export LESS_TERMCAP_se=$'\e[0m'         # end stand-out mode
export LESS_TERMCAP_so=$'\e[30;2;43m'      # being stand-out mode (e.g higlight search results on man page)
export LESS_TERMCAP_ue=$'\e[0m'         # end underline
export LESS_TERMCAP_us=$'\e[1;4;31m'    # begin underline

alias y='source ~/yonidell.sh'
alias l='ls -ltr --color'
alias c='cd'
alias ..='cd ..'
alias p='pwd -P'
alias v='vim -u ~/vimrcyoni.vim'
alias vs='vim -S Session.vim'
alias f='fg'
alias j='jobs'
alias lessin='less -IN'
alias r='source ~/yonidell.sh'

alias yonidellcptobsc='docker cp yonidell.sh  cyc_bsc_docker:/home/cyc/ ; docker cp vimrcyoni.vim cyc_bsc_docker:/home/cyc/'
alias yonidellsshkeyset='ssh-copy-id -i ~/.ssh/id_rsa.pub y_cohen@10.55.226.121'
alias delllistdc='find . -maxdepth 1 -regex ".*service-data\|.*dump-data"'
alias d='sudo dmesg --color -HxP'
alias dp='sudo dmesg --color -Hx'
alias dw='sudo dmesg --color -Hxw'
alias dcc='sudo dmesg -C'

dmesg-level-get () 
{
    echo "current|default|minimum|boot-time-default";
    sudo cat /proc/sys/kernel/printk;
    ask_user_default_no "see legend ?";
    [ $? -eq 0 ] && return;

    echo -e "KERN_EMERG    \"0\" pr_emerg()"
    echo -e "KERN_ALERT    \"1\" pr_alert()"
    echo -e "KERN_CRIT     \"2\" pr_crit()"
    echo -e "KERN_ERR      \"3\" pr_err()"
    echo -e "KERN_WARNING  \"4\" pr_warn() "
    echo -e "KERN_NOTICE   \"5\" pr_notice() "
    echo -e "KERN_INFO     \"6\" pr_info()"
    echo -e "KERN_DEBUG    \"7\" pr_debug() and pr_devel() if DEBUG is defined"
    echo -e "KERN_DEFAULT  \"”\""
    echo -e "KERN_CONT     \"c\" pr_cont()"

    echo ""
}

dmesg-level-set ()
{
    local level=${1};
    if [ -z ${level} ] ; then
        echo "missing level";
        ask_user_default_yes "set to debug level ?";
        [ $? -eq 0 ] && return;
        echo 8 | sudo tee /proc/sys/kernel/printk;
    fi;

    sudo dmesg -n ${level};
}

alias dellcdcoredumps='cd /cyc_var/cyc_dumps/processed/cyc_dumps/'
alias dellcddatacollectlogs='cd /disks/jiraproduction2'

yonidellupdate ()
{
    1>/dev/null pushd ${HOME};
    scp y_cohen@10.55.226.121:"~/yonienv/scripts/{yonidell.sh,vimrcyoni.vim}" ~/;
    sed -i "1s/YONI_CLUSTER=.*/YONI_CLUSTER=${YONI_CLUSTER}/" yonidell.sh;
    source ~/yonidell.sh;
    1>/dev/null popd;
}

probe_topology ()
{
    local core=( $(cat /proc/cpuinfo | awk '/processor/{print $3}') );
    local socket=( $(cat /proc/cpuinfo | awk '/physical id/{print $4}') );
    echo "core=(echo ${core[@]})";
    echo "socket=(echo ${socket[@]})";
}

alias tt='probe_topology'

yonidellcptopeer ()
{
    scp yonidell.sh vimrcyoni.vim peer:~/;
}

# return 0:no 1:yes
ask_user_default_no ()
{
    local choice=;
    local user_string=${1};
    read -p "${user_string} [y|N]?" choice
    case "$choice" in
      y|Y ) return 1;;
      * ) return 0;;
#       y|Y ) echo "yes";;
#       n|N ) echo "no";;
#       * ) echo "no";;
    esac
}

# return 0:no 1:yes
ask_user_default_yes ()
{
    local choice=;
    local user_string=${1};
    read -p "${user_string} [Y|n]?" choice
    case "$choice" in
      n|N ) return 0;;
      * ) return 1;;
#       n|N ) echo "no";;
#       y|Y ) echo "yes";;
#       * ) echo "yes";;
    esac
}

h ()
{
    local a=$1;

    if [ -z $a ] ; then
        history
    else
        history | /bin/grep --color -i $a
    fi
}

lld ()
{
    ls -ltrd --color $(ls -l | awk '/^d/{print $9}')
}

coregetversion ()
{
    local version_file=/working/cyc_host/.version
    grep -A 2 pnvmet ${version_file};
    grep source-reference ${version_file};
}

coregetkernelversion ()
{
   echo -e "modinfo  /cyc_software_0/cyc_host/cyc_common/modules/nvmet-power.ko";
   echo    "-------------------------------------------------------------------";
   modinfo  /cyc_software_0/cyc_host/cyc_common/modules/nvmet-power.ko | grep -m 1 githash;

   echo -e "\ncat /sys/modules/nvmet_power/parameters/githash";
   echo    "-------------------------------------------------";
   cat /sys/module/nvmet_power/parameters/githash;
}

corelistkernelmodules ()
{
    local kernel_modules_folder=/cyc_software_0/cyc_host/cyc_common/modules/;
    ls -ltr ${kernel_modules_folder};
}

bsclistports ()
{
    for i in /sys/kernel/config/nvmet/ports/* ; do
        echo -n "$(cat $i/user_port_idx) |";
        echo -n "$i |";
        echo -n "$(cat $i/addr_traddr) |";
        echo -n "$(cat $i/addr_trsvcid) |";
        echo "$(cat  $i/addr_trtype) |";
    done | column -t;
}

# delljournalctlnode-a ()
# {
#     local all=${1};
#     if [[ $all == 'a' ]] ; then
#         journalctl                  --utc --no-pager -o short-precise -a -D node_a/var/log/journal |less -N -I
#     else
#         journalctl SUB_COMPONENT=nt --utc --no-pager -o short-precise -a -D node_a/var/log/journal |less -N -I
#     fi
# }
#
# delljournalctl-node-b ()
# {
#     local all=${1};
#     if [[ $all == 'a' ]] ; then
#         journalctl --no-pager -a -D node_b/var/log/journal | less -N -I
#     else
#         journalctl SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_b/var/log/journal | less -N -I
#     fi
# }

delljournalctl-nt-logs-node-a ()
{
    local since="${1}";
    local options="--utc SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_a/var/log/journal";

    if [[ -n "${since}" ]] ; then
      (set -x ; eval journalctl --since=\"${since}\" ${options} | less -N -I);
    else
      (set -x ; eval journalctl ${options}  | less -N -I);
    fi;
}

delljournalctl-nt-logs-node-b ()
{
    local since="${1}";
    local options="--utc SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_b/var/log/journal";

    if [[ -n "${since}" ]] ; then
        eval journalctl --since=\"${since}\" ${options} | less -N -I
    else
        eval journalctl ${options} | less -N -I
    fi;
}

delljournalctl-all-logs-node-a ()
{
    local since="${1}";
    local options="--utc --no-pager -o short-precise -a -D node_a/var/log/journal";

    if [[ -n "${since}" ]] ; then
      (set -x ; eval journalctl --since=\"${since}\" ${options} | less -N -I);
    else
      (set -x ; eval journalctl ${options} | less -N -I);
    fi;
}

delljournalctl-all-logs-node-b ()
{
    local since="${1}";
    local options="--utc --no-pager -o short-precise -a -D node_b/var/log/journal";

    if [[ -n "${since}" ]] ; then
        eval journalctl --since=\"${since}\" ${options} | less -N -I
    else
        eval journalctl ${options} | less -N -I
    fi;
}

alias journalall='sudo journalctl'
alias journalallf='sudo journalctl -f'

alias journalnt='sudo journalctl SUB_COMPONENT=nt'
alias journalntf='sudo journalctl -f SUB_COMPONENT=nt'
alias journalnt3minutes='sudo journalctl --since="3 minutes ago" SUB_COMPONENT=nt'

alias journalkernel='sudo journalctl -k'
alias journalkernelf='sudo journalctl -k -f'

alias delltriage-all-logs-node-a="./cyc_triage.pl -b . -n a -j -- -a"
alias delltriage-all-logs-node-b="./cyc_triage.pl -b . -n b -j -- -a"
alias delltriage-nt-logs-node-a="./cyc_triage.pl -b . -n a -j SUB_COMPONENT=nt"
alias delltriage-nt-logs-node-b="./cyc_triage.pl -b . -n b -j SUB_COMPONENT=nt"
alias delltriage-kernel-logs-node-a="./cyc_triage.pl -b . -n a -j -- -t kernel"
alias delltriage-kernel-logs-node-b="./cyc_triage.pl -b . -n b -j -- -t kernel"
alias delltriage-sym-logs-node-a="./cyc_triage.pl -b . -n a -j -- -t xtremapp"
alias delltriage-sym-logs-node-b="./cyc_triage.pl -b . -n b -j -- -t xtremapp"

dyoni ()
{
    sudo su -c "echo =============yoni-debug============= > /dev/kmsg"
}

dellnvmestart ()
{
    modprove qla2xxx
    modprobe

}

ismoduleup ()
{
    local module=$1;
    if [ $(lsmod |grep -w ${module} | wc  -l ) -gt 0 ] ; then
        echo yes;
    else
        echo no;
    fi
}

loadmoduleifnotloaded ()
{
    local module=$1
    if [ "$(ismoduleup ${module})"  == "no" ] ; then
        sudo modprobe ${module} ;
        echo "load ${module}"
    fi
}

removemoduleifloaded ()
{
    local module=$1
    if [ "$(ismoduleup ${module})"  == "yes" ] ; then
#       sudo modprobe -r ${module} ;
        if [ $(sudo rmmod ${module} 2>&1  | grep ERROR  |wc -l) -eq 0 ] ; then
            echo "removed ${module}"
        else
            echo "failed to remove ${module}"
        fi

    fi
}

reloadmodule ()
{
    local module=$1;
    removemoduleifloaded ${module};
    loadmoduleifnotloaded ${moule};
}

dellnvmemodules ()
{
    lsmod |grep "nvme\|qla";

}

dellnvmemodulesload ()
{
    loadmoduleifnotloaded nvme_core
    loadmoduleifnotloaded nvme_fabrics
    loadmoduleifnotloaded nvme_fc
    loadmoduleifnotloaded nvme_tcp
    loadmoduleifnotloaded qla2xxx
}

dellnvmemodulesunload ()
{
    # systemctl stop multipathd
    # systemctl stop multipathd.socket
    # iscsiadm -k 0
    removemoduleifloaded nvme_rdma
    removemoduleifloaded scst_qla2xxx
    removemoduleifloaded nvme_qla2xxx
    removemoduleifloaded qla2xxx
    removemoduleifloaded nvme_tcp
    removemoduleifloaded nvme_fc
    removemoduleifloaded nvme_fabrics
    removemoduleifloaded nvme_core
}

dellnvmetargetlist ()
{
    for i in /sys/kernel/config/nvmet/ports/* ; do
        echo -n "$i |"  ; echo -n "$(cat $i/addr_traddr) |" ; echo  "$(cat $i/addr_trsvcid) |" ;
    done |column -t;
    echo "________________________________________________________";
    ls -ltr /sys/kernel/config/nvmet/subsystems
}

alias debuc-set-inactive-node-a='echo "set inactive" > /xtremapp/debuc/127.0.0.1\:31010/commands/nt'
alias debuc-set-inactive-node-b='echo "set inactive" > /xtremapp/debuc/127.0.0.1\:31011/commands/nt'
alias debuc-set-active-node-a='echo "set active" > /xtremapp/debuc/127.0.0.1\:31010/commands/nt'
alias debuc-set-active-node-b='echo "set active" > /xtremapp/debuc/127.0.0.1\:31011/commands/nt'

get_node_id ()
{
    local node=$(hostname |sed 's/.*-//g');

    if [[ ${node} == 'A' ]] ; then
        echo "31010";
    elif [[ ${node} == 'B' ]] ; then
        echo "31011"
    else
        echo 0;
    fi;
}

export debuc_node="$(get_node_id)";
if [[ ${debuc_node} != 0 ]] ; then
    echo "${YONI_CLUSTER}";
    echo "debuc_node: $debuc_node";
fi;

debuc-command ()
{
    local command="${1}";
    local debuc_file=;
    local dfile=;

    if [[ ${debuc_node} == 0 ]] ; then
        echo "did not resolve node";
        return -1;
    fi;

    debuc_file="/xtremapp/debuc/127.0.0.1:${debuc_node}/commands/nt";
    dfile_base=/xtremapp/debuc/127.0.0.1;
    dfile_node=${debuc_node}/commands/nt;

    if [[ -e ${debuc_file} ]] ; then
        echo -e "echo \"${command}\" > ${debuc_file}";
        echo "${command}" > ${dfile_base}\:${dfile_node};
    else
        echo "${debuc_file} not found";
        return -1;
    fi;

    return 0;
}

alias debuc-log-devices='debuc-command "log devices"';
alias debuc-qos-get-incoming-stats='debuc-command "get qos incoming stats"';
alias debuc-qos-log-enable='debuc-command "log qos enable"';
alias debuc-qos-log-disable='debuc-command "log qos disable"';
alias debuc-qos-delete-bucket-0='debuc-command "del qos bucket idx=0"'

_debuc-qos-configure-usage ()
{
    echo "debuc-qos-configure <nsid> <iops>";
}

debuc-qos-configure ()
{
    local nsid=${1};
    local iops=${2};
    local debuc_file=;
    local dfile=;

    if [[ -z ${nsid} ]] ; then
        echo "error : missing nsid";
        _debuc-qos-configure-usage
        return -1;
    fi;

    if [[ -z ${iops} ]] ; then
        echo "error : missing iops";
        _debuc-qos-configure-usage
        return -1;
    fi;

    if [[ ${debuc_node} == 0 ]] ; then
        echo "did not resolve node (debuc_node=${debuc_node})";
        return -1;
    fi;

    debuc_file="/xtremapp/debuc/127.0.0.1:${debuc_node}/commands/nt";
    dfile_base=/xtremapp/debuc/127.0.0.1;
    dfile_node=${debuc_node}/commands/nt;

    if [[ -e ${debuc_file} ]] ; then
        echo -e "echo \"add qos bucket idx=0 bw=100g iops=${iops} burst=0% nsid=${nsid}\" > ${debuc_file}";
        echo "add qos bucket idx=0 bw=100g iops=${iops} burst=0% nsid=${nsid}" > ${dfile_base}\:${dfile_node};
    else
        echo "${debuc_file} not found";
        return -1;
    fi;

    return 0;
}

debuc-qos-configure-kiops-vols-1-to-100 ()
{
    local kiops=${1:-500};

    if [[ -z ${kiops} ]] ; then
        echo "missing iops using default ${kiops} kiops";
    fi;

    for (( i=1; i<100; i++)) ; do
        echo "debuc-qos-configure ${i} ${kiops}";
        debuc-qos-configure ${i} ${kiops};
    done;
}

alias debuc-qos-configure-5k-vols-1-to-100="debuc-qos-configure-kiops-vols-1-to-100 5k"
alias debuc-qos-configure-500k-vols-1-to-100="debuc-qos-configure-kiops-vols-1-to-100 500k"
alias debuc-qos-configure-1000k-vols-1-to-100="debuc-qos-configure-kiops-vols-1-to-100 1000k"
alias bsc-qos-dump='cat /sys/module/nvmet_power/parameters/qos_dump'
alias bsc-tcp-log-objects='echo 1 | sudo tee /sys/module/nvmet_tcp/parameters/nr_tcp_queues'
alias bsc-count-controllers='cat /sys/module/nvmet/parameters/nr_ctrls'

_debuc_port_add ()
{
    local node=${1};
    local type=${2};
    local id=${3:-1};
    local address=${4:-10.219.157.164};
    local svc_id=${5:-4420};
    local cmd=;

    local debuc_file="/xtremapp/debuc/127.0.0.1:${node}/commands/nt";
    local dfile_base=/xtremapp/debuc/127.0.0.1;
    local dfile_node=${node}/commands/nt;

    if [[ -z ${node} ]] ; then
        return -1;
    fi;

    cmd="add port id=${id} svc_id=${svc_id} address=${address} type=${type} is_local";
    if [[ -e ${debuc_file} ]] ; then
        echo -e "echo \"${cmd}\" > ${debuc_file}";
        ask_user_default_yes "continue ? ";
        [[ $? -eq 0 ]] && return -1;
        eval echo \"${cmd}\" > ${debuc_file};
        # eval echo \"${cmd}\" > ${dfile_base}\:${dfile_node};
    else
        echo "${debuc_file} not found";
        return -1;
    fi;

    return 0;
}

alias debuc-rdma-port-add-node-a='_debuc_port_add 31010 rdma'
alias debuc-rdma-port-add-node-b='_debuc_port_add 31011 rdma'

debuc-rdma-port-add ()
{
   local port=${1:-4420};
   local address=${2}; 
    
   if [[ -z ${address} ]] ; then
       echo "debuc-rdma-port-add <port> <ip address>";
       complete -W "$(bsclistports |awk -F '|' '/4420/{print $3 " " $4}')" debuc-rdma-port-add
       return -1;
   fi;

   debuc-command "add port id=1 svc_id=${port} address=${address} type=rdma is_local";
   return 0;
}

ethlist ()
{
    ip -4  -o a show |awk '{print $2" "$4}' | column -t | grep -v lo
}

mydistro ()
{
    hostnamectl | grep  -i "operating system" | sed 's/.*:\ /OS: /g';
    hostnamectl | grep  -i "kernel" | sed 's/.*:\ /Kernel:\ /g';
    hostnamectl | grep  -i "chassis" | sed 's/.*:\ /Chassis:\ /g';
}

redpill () 
{
    local ret=0;

    ################################################# 
    # try dmidecode
    which dmidecode 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        echo "vendor : $(sudo dmidecode -s system-manufacturer)";
        echo "product: $(sudo dmidecode -s system-product-name)";

        if [ $( sudo dmidecode | grep -i product | grep -i "qemu\|kvm" | wc -l ) -gt 0 ] ; then 
            echo "I am a virtual machine (dmidecode)";
            # return 0;
        fi
        echo "I am a hypervisor (dmidecode)";
        # return 1;
    fi

    ################################################# 
    # try virt-what
    which virt-what 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        if [ $( sudo virt-what |  wc -l ) -gt 0 ] ; then 
            echo "I am a virtual machine (virt-what)";
            # return 0;
        fi;
        echo "I am a hypervisor (virt-what)";
        # return 1;
    fi;


    ################################################# 
    #  try lshw
    which lshw 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        sudo lshw -class system -sanitize | grep -i product
        if [ $( sudo lshw -class system -sanitize | grep -i product | grep -i kvm | wc -l ) -gt 0 ] ; then 
            echo "I am a virtual machine (lshw)";
            # return 0;
        fi;
        echo "I am a hypervisor (lshw)";
        # return 1;
    fi

    ################################################# 
    # try systemd-detect-virt
#     which systemd-detect-virt 2>/dev/null;
#     ret=$?;
#     if [ ${ret} -eq 0 ] ; then
#         if [ $( systemd-detect-virt | grep -i none | wc -l ) -gt 0 ] ; then
#             echo "I am a hypervisor (systemd-detect-virt)";
#             return 1;
#         fi
#         echo "I am a virtual-machine (systemd-detect-virt)";
#         return 0;
#     fi

    ################################################# 
    # try hostnamectl
    which hostnamectl 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        if [ $( hostnamectl | grep -i virt | wc -l ) -gt 0 ] ; then
            echo "I am a virtual-machine (hostnamectl)";
            # return 0;
        fi
        echo "I am a hypervisor (hostnamectl)";
        # return 1;
    fi

    if [ $( cat /proc/cpuinfo | grep --color -i hypervisor | wc -l ) -gt 0 ] ; then 
        echo -e "i might be am a virtual machine NO \"hypervisor\" in /proc/cpuinfo"; 
        # return 0;
    fi 

    echo "i am a hypervisor (/proc/cpuinfo)";
    # return 1;

# using dmesg is not safe as it can be deleted
#     if [ $(dmesg | grep --color -i hypervisor | wc -l ) -gt 0 ] ; then 
#         echo "i am a virtual machine (dmesg)";
#     else
#         echo "i am a hypervisor (dmesg)";
#     fi 

}

m ()
{
#   myip;
    ethlist;
    mydistro;
#     ofedversion;
}

prdebug-list-methods ()
{
    local method=${1:-rdma}
    sudo cat /sys/kernel/debug/dynamic_debug/control  | sed 's/.*]//g' |awk '{print $1} ' |grep ${method}
}

prdebug-list-all ()
{
	sudo cat /sys/kernel/debug/dynamic_debug/control
}

prdebug-add-method ()
{
    local method=${1};
    if [[ -z ${method} ]] ; then
        echo "usage $FUNCNAME <method>"
        return -1;
    fi;
    
    echo "func ${method} +pfl" |sudo tee /sys/kerenl/debug/dynamic_debug/control;
    
}

_pr_debug_usage ()
{
    echo "pr_debug [-f <func>] [-d ] [-e] [-h]";
    echo "-f <func> [-d]: enable debug prints in func, -d to remove it";
    echo "-e            : show functions that with enabled pr_debug";
    echo "-h            : print this help";
}

prdebug () 
{
    local func="";
    local delete=0;
    local show_enabled=0;
    local usage=0;

    OPTIND=0;
    while getopts "f:d:eh" opt; do
        case $opt in 
        f)
            func=${OPTARG}
            ;;
        d)
            delete=1;
            func=${OPTARG}
            ;;
        e)
            show_enabled=1;                
            ;;
        h)  
            usage=1;                
            ;;
        esac;
    done;

    if [ ${usage} -eq 1 ] ; then 
        _pr_debug_usage;
        return;
    fi

    if [ ${show_enabled} -eq 1 ] ; then 
        sudo cat /sys/kernel/debug/dynamic_debug/control |awk '/.*=pfl/{print $0}';
        return;
    fi; 

    if [ -z "${func}" ] ; then 
        # sudo cat /sys/kernel/debug/dynamic_debug/control;
        echo "missing func";
        _pr_debug_usage;
        return -1;
    fi;

    if [ ${delete} -eq 1 ] ; then 
        su - -c "echo \"func ${func} =_\" > /sys/kernel/debug/dynamic_debug/control";
    else 
        for f in ${func} ; do 
            echo "pr_debug : $f";
            if [ $(id -u) -eq 0 ] ; then 
                echo "func ${f} +pfl" > /sys/kernel/debug/dynamic_debug/control;
            else
                su - -c "echo \"func ${f} +pfl\" > /sys/kernel/debug/dynamic_debug/control";
            fi
        done
    fi;
}

dellibdev2netdev ()
{
    for ibdev in /sys/class/infiniband/* ; do
	    # echo "ibdev ${ibdev}";
	    for p in ${ibdev}/ports/* ; do
		    for d in  $p/gid_attrs/ndevs/* ; do 
			    # echo "ndev $i";
			    ndev=$(cat $d 2>/dev/null);
			    if [[ -n ${ndev} ]] ; then
				    gid=$(basename $d); 
				    gtype=$(cat $p/gid_attrs/types/$gid);
				    guid=$(cat $p/gids/$gid);
				    echo "$d ndev: ${ndev} gid: $gid $guid $gtype"; 
			    fi;
		    done 
	    done 
    done  | column -t;
}

scpcommandforfile ()
{
    local file=${1};
    local host=$(hostname -i|cut -f 1 -d ' ');
    local user=$(id -un);

    if [[ -z ${file} ]] ; then
        echo -e "${RED}missing file name${NC}";
        return -1;
    fi;

    file=$(readlink -f ${file});
    echo "scp ${user}@${host}:${file} .";
}

dellclustergeneratecfg ()
{
    local cluster=${1};

    if [ 0 -eq $(git remote -v | grep "cyclone\/cyc_core.git" | wc -l) ] ; then
        echo "you must be in a cyc_core repo https://y_cohen@eos2git.cec.lab.emc.com/cyclone/cyc_core.git";
        return -1;
    fi;

    if [[ -z ${cluster} ]] ; then
        echo "to which cluster ?";
        return -1;
    fi;

    if ! [[ -e cyc_platform/src/package/cyc_helpers ]] ; then
        echo "missing cyc_platform/src/package/cyc_helpers (forget to checkout ?)";
        return -1;
    fi;

    pushd cyc_platform/src/package/cyc_helpers > /dev/null;

    if ! [[ -e swarm-to-cfg-centos8.sh ]] ; then
        echo "missing script file swarm-to-cfg-centos8.sh";
        return -1;
    fi;

    echo "./swarm-to-cfg-centos8.sh ${cluster}";
    ./swarm-to-cfg-centos8.sh ${cluster};
     
    ls ../cyc_configs/*${cluster}* | while read c ; do readlink -f $c ; done;

    popd > /dev/null;

    return 0;
}

dellnvme-nodename-portname ()
{
    for h in /sys/class/fc_host/* ; do echo "$(basename $h) : nn-$(cat $h/node_name):pn-$(cat $h/port_name)" ; done
}

# nvme discover|connect example
# nvme discover -t tcp -a <take from bsclistports>
# nvme discover -t fc -a <take from bsclistports> -w <take from dellnvme-nodename-portname>
# nvme discover -t rdma --traddr=10.219.146.182 -w 10.219.146.186
# nvme connect -t rdma -a 10.219.146.182 -n nqn.1988-11.com.dell:powerstore:00:60148e5c7660A3D9C763 -s 4420 -w 10.219.146.186 -D 

# btest examples
# /home/qa/btest/btest -D  -t 10 -l 10m -b 4k   R 30 /dev/dm-0

# multipath -ll
# sudo nvme discover -t rdma  --traddr=10.219.157.164 -w 10.219.157.167
# nvme connect -t tcp -a 10.219.157.164  -n nqn.1988-11.com.dell:powerstore:00:b4fea1b05549F7A1A429 -s 4420 -D
# nvme port and node name
# nvme dsm /dev/nvme0n1 -b 1 -s 0 -d 1
# nvme write-zeroes /dev/nvme0n1

# read write with dd
# sudo dd if=/dev/zero of=/dev/nvme0n1 bs=1M  count=1 
# sudo dd if=/dev/urandom of=/dev/nvme0n1 bs=1M 
# sudo dd of=/dev/nvme0n1 bs=512 count=1
# from/to file
#   sudo dd if=text-file of=/dev/nvme0n1
#   dd if=/dev/nvme0n1 count=$(stat --printf="%s" text-file )

# see which devices are connected on the lg
# sudo lshw -C network -businfo
# ibdev2netdev

# vlan tag
# ip link add link p2p1 name p2p1.1713 type vlan id 1713
# ip addr add 10.219.157.167/20 dev p2p1.1713
# sudo ip link set p2p1.1713 up

# triage 
# search for these
# allocate.*ctrl|allocate.*cont|alloc_target_queu|kernel|nvmet|pnvmet

# copy files between nodes 
# scp <file> peer:~/



unset PROMPT_COMMAND
# PS1="[\D{%H:%M %d.%m}][\u@\h:\w]\n==> "
PS1="[\D{%H:%M %d.%m}] \[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\w\[\033[0m\] \[\033[01;34m\]\n\[\033[00m\]$\[\033[00m\]=> "
