export HISTTIMEFORMAT="%D %T " 

alias y='source ~/yonidell.sh'
alias l='ls -ltr --color'
alias c='cd'
alias ..='cd ..'
alias p='pwd -P'
alias v='vim -u ~/yonidellvim.vim'
alias vs='vim -S Session.vim'
alias f='fg'
alias j='jobs'

alias yonidellupdate='scp y_cohen@10.55.227.146:~/yonienv/scripts/yonidell* ~/ ; source ~/yonidell.sh'
alias yonidellsshkeyset='ssh-copy-id -i ~/.ssh/id_rsa.pub y_cohen@10.55.227.146'
alias delllistdc='find . -maxdepth 1 -regex ".*service-data\|.*dump-data"' 
alias d='sudo dmesg --color -HxP'
alias dp='sudo dmesg --color -Hx'
alias dw='sudo dmesg --color -Hxw'
alias dcc='sudo dmesg -C'

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


dellbsclistports ()
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

delljournalctl-nt-node-a ()
{
    local since="${1}";

    if [[ -n "${since}" ]] ; then
        eval journalctl --since=\"${since}\" SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_a/var/log/journal | less -N -I
    else
        eval journalctl                      SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_a/var/log/journal | less -N -I
    fi;
}

delljournalctl-nt-node-b ()
{
    local since="${1}";

    if [[ -n "${since}" ]] ; then
        eval journalctl --since=\"${since}\" SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_b/var/log/journal | less -N -I
    else
        eval journalctl                      SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_b/var/log/journal | less -N -I
    fi;
}

delljournalctl-all-node-a ()
{
    local since="${1}";

    if [[ -n "${since}" ]] ; then
        eval journalctl --since=\"${since}\" --no-pager -o short-precise -a -D node_a/var/log/journal | less -N -I
    else
        eval journalctl                      --no-pager -o short-precise -a -D node_a/var/log/journal | less -N -I
    fi;
}

delljournalctl-all-node-b ()
{
    local since="${1}";

    if [[ -n "${since}" ]] ; then
        eval journalctl --since=\"${since}\" --no-pager -o short-precise -a -D node_b/var/log/journal | less -N -I
    else
        eval journalctl                      --no-pager -o short-precise -a -D node_b/var/log/journal | less -N -I
    fi;
}

alias jnt3minutes='sudo journalctl --since="3 minutes ago" SUB_COMPONENT=nt'
alias jnt='sudo journalctl SUB_COMPONENT=nt'
alias jn='sudo journalctl'

alias delltriage-node-a="./cyc_triage.pl -b . -n a -j"
alias delltriage-node-b="./cyc_triage.pl -b . -n b -j"

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

debuc-qos-configure ()
{
    local node=${1};
    local nsid=${2};
    local debuc_file=;
    local dfile=;
    local iops=5k;

    if [[ -z ${nsid} ]] ; then
        echo "error : missing nsid";
        return -1;
    fi;
    
    debuc_file="/xtremapp/debuc/127.0.0.1:${node}/commands/nt";
    dfile_base=/xtremapp/debuc/127.0.0.1;
    dfile_node=${node}/commands/nt;
    
    if [[ -e ${debuc_file} ]] ; then
        echo -e "echo \"add qos bucket idx=0 bw=100g iops=${iops} burst=0% nsid=${nsid}\" > ${debuc_file}"; 
        echo "add qos bucket idx=0 bw=100g iops=${iops} burst=0% nsid=${nsid}" > ${dfile_base}\:${dfile_node};
    else
        echo "${debuc_file} not found";
        return -1;
    fi;
    
    return 0;
}

_debuc-qos-disable ()
{
    local node=${1};
    local debuc_file="/xtremapp/debuc/127.0.0.1:${node}/commands/nt";
    local dfile_base=/xtremapp/debuc/127.0.0.1;
    local dfile_node=${node}/commands/nt;

    if [[ -z ${node} ]] ; then
        return -1;
    fi;
    
    if [[ -e ${debuc_file} ]] ; then
        echo -e "echo \"del qos bucket idx=0\" > ${debuc_file}";
        echo "del qos bucket idx=0" > ${dfile_base}\:${dfile_node};
    else
        echo "${debuc_file} not found";
        return -1;
    fi;

    return 0;
}

alias debuc-qos-disable-node-a='_debuc-qos-disable 31010'
alias debuc-qos-disable-node-b='_debuc-qos-disable 31011'

alias debuc-qos-configure-node-a='debuc-qos-configure 31010'
alias debuc-qos-configure-node-b='debuc-qos-configure 31011'
alias dell-qos-dump='sudo echo 1 > /sys/module/nvmet_power/parameters/qos_dump'

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
    cat /sys/kernel/debug/dynamic_debug/control  | sed 's/.*]//g' |awk '{print $1} ' |grep ${method}
}

prdebug-add-method ()
{
    local method=${1};
    if [[ -z ${method} ]] ; then
        echo "usage $FUNCNAME <method>"
        return -1;
    fi;
    
    sudo echo "func ${method} +p" > /sys/kerenl/debug/dynamic_debug/control;
    
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

# btest examples
# /home/qa/btest/btest -D  -t 10 -l 10m -b 4k   R 30 /dev/dm-0

# multipath -ll
# nvme discover
# nvme connect
# nvme port and node name
# nvme dsm /dev/nvme0n1 -b 1 -s 0 -d 1
# nvme write-zeroes /dev/nvme0n1

# read write with dd
# sudo dd if=/dev/zero of=/dev/nvme0n1 bs=1M  count=1 
# sudo dd if=/dev/urandom of=/dev/nvme0n1 bs=1M 
# sudo dd of=/dev/nvme0n1 bs=512 count=1

# sudo lshw -C network -businfo


unset PROMPT_COMMAND
# PS1="[\D{%H:%M %d.%m}][\u@\h:\w]\n==> "
PS1="[\D{%H:%M %d.%m}] \[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\w\[\033[0m\] \[\033[01;34m\]\n\[\033[00m\]$\[\033[00m\]=> "
