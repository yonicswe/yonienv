#export YONI_CLUSTER=
 
######################################
# colors
# echo -e "${RED} text ${NC}"
RED="\033[1;31m"
REDBLINK="\033[1;5;31m"
REDITALIC="\033[1;3;31m"
REDREVERSE="\033[1;7;31m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
BROWN="\033[0;33m"
YELLOW="\033[1;33m"
NC="\033[0m"
######################################

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
alias la='ls -d .?*  --color'
alias c='cd'
alias ..='cd ..'
alias p='pwd -P'
alias v='vim'
alias vs='vim -S Session.vim'
alias f='fg'
alias j='jobs'
ww () 
{ 
    w --no-header | awk '{print $3}' | while read i; do
        nslookup $i;
    done | grep name
}

k ()
{
    local job=$1 ; 
    local j;
    local kill_str;

    if [ -z "$job" ] ; then
        ask_user_default_no "kill all jobs";
        if [ $? -eq 0 ] ; then
            return;
        fi;

        jobs -p | xargs kill -9
        return;
    fi;

    for j in ${@:1} ; do
        kill_str="kill -9 %${j}" ; 
        eval ${kill_str}; 
    done;
}

alias lessin='less -IN'
alias r='source ~/yonidell.sh'

alias yonidellcptobsc='docker cp ~/yonidell.sh  cyc_bsc_docker:/home/cyc/ ; docker cp ~/vimrcyoni.vim cyc_bsc_docker:/home/cyc/'
alias yonidellsshkeyset='ssh-copy-id -i ~/.ssh/id_rsa.pub y_cohen@10.55.226.121'
alias delllistdc='find . -maxdepth 1 -regex ".*service-data\|.*dump-data"'
alias d='sudo dmesg --color -HxP'
alias dp='sudo dmesg --color -Hx'
alias dw='sudo dmesg --color -Hxw'
alias dcc='sudo dmesg -C'

tagcscope ()
{
    source_path=${1:-.};
    find ${source_path} -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -vqb;
}

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
}

dmesg-level-set ()
{
    local level=${1};
    if [ -z ${level} ] ; then
        ask_user_default_yes "missing level!! would you list to set to debug level ?";
        [ $? -eq 0 ] && return;
        # echo 8 | sudo tee /proc/sys/kernel/printk;
        sudo dmesg -n 8;
        return;
    fi;

    sudo dmesg -n ${level};
}

alias dellcdcore-dumps='cd /cyc_var/cyc_dumps/processed/cyc_dumps/'
alias dellcdcore-kernelmodules='cd /cyc_software_0/cyc_host/cyc_common/modules'
alias dellcdbsc-kernelmodules='cd /cyc_host/cyc_common/modules'
alias dellcdcore-scripts='cd /cyc_software_0/cyc_host/cyc_bsc/scripts'
alias dellcdbsc-scripts='cd /cyc_host/cyc_bsc/scripts'
alias dellcdcore-bin='cd /cyc_software_0/cyc_host/cyc_bin'
alias dellcdbsc-bin='cd /cyc_host/cyc_bin'
alias dellcd-datacollectlogs='cd /disks/jiraproduction2'

if [ -e ~/vimrcyoni.vim ] ; then
    ln -snf  ~/vimrcyoni.vim ~/.vimrc;
fi;

yonidellupdate ()
{
    1>/dev/null pushd ${HOME};
    #scp y_cohen@10.55.226.121:"~/yonienv/scripts/{yonidell.sh,vimrcyoni.vim}" ~/;
    scp y_cohen@10.55.226.121:~/yonienv/scripts/*yoni* ~/;
    #sed -i "1s/YONI_CLUSTER=.*/YONI_CLUSTER=${YONI_CLUSTER}/" yonidell.sh;
    source ~/yonidell.sh;
    1>/dev/null popd;
     
    if [ $(grep "alias y=" ~/.bashrc | wc -l) -eq 1 ] ; then
        return 0;
    fi;

    echo "alias y='source ~/yonidell.sh'" >> ~/.bashrc;
    return 0;
}
alias yy='yonidellupdate'
alias yyy='yonidellsshkeyset'

yonidelldelete ()
{
    rm -f ~/yonidell.sh ~/vimrcyoni.vim ~/.vimrc
    sed -i '/alias y=.*/d' ~/.bashrc;
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

yonidellcptobscandpeer ()
{
    yonidellcptopeer;
    yonidellcptobsc;
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
    grep program_name ${version_file};
    grep branch ${version_file};
    grep -w flavor ${version_file};
    echo "--------------------------------------------"
    echo "nt_nvmeof_frontend $(grep -A 2 nt_nvmeof_frontend ${version_file} | awk '/hash/{print $2}')";
    echo "pnvmet $(grep -A 2 pnvmet ${version_file} | awk '/hash/{print $2}' )";
    echo "cyc_core : $(awk '/git-hash/{print $2}' ${version_file} )";
    grep core-version ${version_file};
    grep source-reference ${version_file};
    ask_user_default_no "would you like to open : ${version_file} ? ";
    if [ $? -eq 0 ] ; then return ; fi;
    less ${version_file};
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

bsclist-tcp-controllers ()
{
    echo 1 | sudo tee  /sys/module/nvmet_tcp/parameters/nr_tcp_queues
}

bsclistkernelmodules ()
{
    local kernel_modules_folder=/cyc_host/cyc_common/modules/;
    (set -x ; ls -ltr ${kernel_modules_folder};);
}

corecdkernelmodules ()
{
    local kernel_modules_folder=/running/cyc_host/cyc_common/modules/;
    #local kernel_modules_folder_0=/cyc_software_0/cyc_host/cyc_common/modules/;
    #local kernel_modules_folder_1=/cyc_software_1/cyc_host/cyc_common/modules/;
    #local kernel_modules_folder;

    #if [ -e ${kernel_modules_folder_0} ] ; then
        #kernel_modules_folder=${kernel_modules_folder_0};
    #elif [ -e ${kernel_modules_folder_1} ] ; then
        #kernel_modules_folder=${kernel_modules_folder_1};
    #else
        #echo "path not found ${kernel_modules_folder_0} or ${kernel_modules_folder_1}";
        #return;
    #fi;

    if [ -d ${kernel_modules_folder} ] ; then
        cd ${kernel_modules_folder};
    fi;
}

corelistkernelmodules ()
{
    local kernel_modules_folder_0=/cyc_software_0/cyc_host/cyc_common/modules/;
    local kernel_modules_folder_1=/cyc_software_1/cyc_host/cyc_common/modules/;
    local kernel_modules_folder;

    if [ -e ${kernel_modules_folder_0} ] ; then
        kernel_modules_folder=${kernel_modules_folder_0};
    elif [ -e ${kernel_modules_folder_1} ] ; then
        kernel_modules_folder=${kernel_modules_folder_1};
    else
        echo "path not found ${kernel_modules_folder_0} or ${kernel_modules_folder_1}";
        return;
    fi;

    if [ -d ${kernel_modules_folder} ] ; then
        (set -x ; ls -ltr ${kernel_modules_folder};);
    fi;
    #bsclistkernelmodules;
}

_bsclistscsiports ()
{
    local p=/sys/class/fc_host/;
    echo " path | node-name | port-name | port_state";
    echo " ---- | --------- | --------- | ----------"
    ls ${p} | while read h ; do 
        echo -n "${p}${h} | nn:$(cat ${p}/${h}/node_name)";
        echo -n " | pn:$(cat ${p}/${h}/port_name)";
        echo " | pn:$(cat ${p}/${h}/port_state)";
    done;
}
alias bsclistscsiports='_bsclistscsiports| column -t'

bsclistsubsystem ()
{
    local subsystem=;

    subsystem=$(ls /sys/kernel/config/nvmet/subsystems);
    echo "subsystem = ${subsystem}";
}

alias bsclistnvmefcports='bsclistnvmeports|grep \|fc'
alias bsclistnvmetcpports='bsclistnvmeports|grep \|tcp'

bsclistnvmeports ()
{
    bsclistsubsystem;
    echo "==================================================="
    printf  "%-20s" idx ;
    printf  "%-90s" file;
    printf  "%-28s" addr;
    printf  "%-7s" port;
    printf  "%-7s\n" type;
    for i in /sys/kernel/config/nvmet/ports/* ; do
        echo -n "$(cat $i/user_port_idx) |";
        echo -n "$i |";
        echo -n "$(cat $i/addr_traddr) |";
        echo -n "$(cat $i/addr_trsvcid) |";
        echo "$(cat  $i/addr_trtype) |";
    done | column -t;
}

bsclistports ()
{
    echo "===================================================";
    echo " nvme ports";
    echo "===================================================";
    bsclistnvmeports;

    echo "===================================================";
    echo " scsi ports";
    echo "===================================================";
    bsclistscsiports;

}

_bsclistbroadcomscsiports ()
{
    local p=/sys/kernel/scst_tgt/targets/ocs_xe201/;
    echo " scsi-ports | node-name | port-name | enabled | link_up";
    echo " ---------- | --------- | --------- | ------- | -------"
    find ${p} -maxdepth 1 -type d  | sed '1d' | while read h ; do
        echo -n "${h} | nn:$(cat ${h}/wwnn|head -1)";
        echo -n " | pn:$(cat ${h}/wwpn|head -1)";
        echo -n " | $(cat ${h}/enabled)";
        echo    " | $(cat ${h}/link_up)";
    done;
}
alias bsclistbroadcomscsiports='_bsclistbroadcomscsiports | column -t'

_bsclistbroadcomnvmeports ()
{
    local p=/sys/kernel/debug/ocs_fc_scst/;
    echo " nvme-ports | node-name | port-name | enabled ";
    echo " ---------- | --------- | --------- | ------- "
    sudo find ${p} -maxdepth 1 -type d  | sed '1d' | while read h ; do
        echo -n "${h} | nn:$(sudo cat ${h}/vport_spec0/wwnn|head -1)";
        echo -n " | pn:$(sudo cat ${h}/vport_spec0/wwpn|head -1)";
        echo " | $(sudo cat ${h}/vport_spec0/enable)";
    done;
}
alias bsclistbroadcomnvmeports='_bsclistbroadcomnvmeports | column -t'

bsclistbroadcomports ()
{
    bsclistbroadcomscsiports;
    echo;
    bsclistbroadcomnvmeports;

    echo -e "try also :\ndellcdbsc-bin ; ./cyc_wwn_initializer -d";
}

bsclistbroadcomvports ()
{
    if [ -e /cyc_host/cyc_bin/elxsdkutil ] ; then
        echo "sudo /cyc_host/cyc_bin/elxsdkutil list";
        sudo /cyc_host/cyc_bin/elxsdkutil list;
        return 0;
    fi;
    echo "/cyc_host/cyc_bin/elxsdkutil is missing";
    return -1;
}

bsclistfcports ()
{
    for f in /sys/class/fc_host/* ; do 
        echo $f;
        echo -e "\t|-$f/node_name : $(cat $f/node_name)";
        echo -e "\t|-$f/port_name : $(cat $f/port_name)";
        echo -e "\to-$f/port_state : $(cat $f/port_state)";
    done;
}

alias dellnvme-list-fcports='bsclistfcports'

alias bscshowfctable='/cyc_host/cyc_bin/cyc_wwn_initializer -d'
alias bsclistqlaports='ls -l /sys/class/nvme_qla2xxx/'

bsclistindusdevices ()
{
    /cyc_bsc/datapath/bin/cli.py raid get_dev_info;
}

bsclistfeatureflags ()
{
    local feature=${1};
    local feature_flags_file=/cyc_var/feature_flags.json;

    if [[ -z "${feature}" ]] ; then
        awk '/\"name\"/{printf $0; getline; print $0 }' ${feature_flags_file}  | sed -e 's/\"\|\,\|\://g' -e 's/default_state\|name//g' | column -t;
    else
        awk '/\"name\"/{printf $0; getline; print $0 }' ${feature_flags_file}  | sed -e 's/\"\|\,\|\://g' -e 's/default_state\|name//g' | column -t | grep ${feature};
    fi;
}
alias corelistfeatureflags='bsclistfeatureflags';

corelist-fc-devices ()
{
    echo "ls -l /sys/class/fc_host";
    if [ -d /sys/class/fc_host ] ; then
        ls -l /sys/class/fc_host/;
    else
        echo "you might need to modprobe [qla2xxx|lpfc|ocs_fc_scst]";
    fi;

    echo "sudo lspci |grep -i fibre";
    if [ $(sudo lspci | grep -i fibre | grep -i emulex| wc -l ) -gt 0 ] ; then
        sudo lspci | grep -i fibre | grep -i emulex;
        echo -e "found emulex/marvell card installed on pci bus, you need to \"modprobe lpfc or modprobe ocs_fc_scst\"";
    elif [ $(sudo lspci | grep -i fibre | grep -i qlogic| wc -l ) -gt 0 ] ; then
        sudo lspci | grep -i fibre | grep -i qlogic;
        echo -e "found qlogic card installed on pci bus, you need to \"modprobe qla2xxx\"";
    elif [ $(sudo lspci | grep -i fibre| wc -l ) -gt 0 ] ; then
        sudo lspci | grep -i fibre;
    else
        echo "NO!! fc devices found on pci bus";
    fi;
}
alias bsclist-fc-devices='corelist-fc-devices'
alias delllist-fc-devices='corelist-fc-devices'

corelist-fc-devices-with-fcc-script ()
{
    sudo /working/cyc_host/cyc_bsc/scripts/fcc.sh
}

_bsclist-xtremapp ()
{
    local xtremapp_pid=;

    pgrep xtremapp -a;
    echo "--------------------------";
    
}
alias bsclist-xtremapp='_bsclist-xtremapp | column -t; echo "sudo kill $(pgrep -x xtremapp)";'

_delljournalctl ()
{
    local node=${1};
    local component=${2};
    local since="${3}";
    local pager=0;
    local options;
    local journal_cmd=;

    if [[ -z ${node} ]] ; then
        echo "missing node";
        return -1;
    fi;

    if [[ ${node}  == "a" ]] ; then
        # options="--utc -o short-precise -a -D node_a/var/log/journal";
        options="-a -D node_a/var/log/journal";
    elif [[ ${node} == "b" ]] ; then
        # options="--utc -o short-precise -a -D node_b/var/log/journal";
        options="-a -D node_b/var/log/journal";
    else
        echo "node can be a or b only";
    fi;

    if [[ -z ${component} ]] ; then
        echo "missing component";
        return -1;
    fi;
    
    ask_user_default_no "use pager ?";
    if [ $? -eq 1 ] ; then
        options+=" --no-pager | less -N -I" 
    fi;

    case ${component} in
        "all") 
            ;;
        "nt") 
            options+=" SUB_COMPONENT=nt";
            ;;
        "kernel") options+=" -k";
            ;;
        *)
            echo "no such componenet ${componenet}";
            return 1;
            ;;
    esac;

    journal_cmd=
    if [[ -n "${since}" ]] ; then
        (set -x ; eval journalctl --since=\"${since}\" ${options});
    else
        (set -x ; eval journalctl ${options});
    fi;
}

tmuxsetup ()
{
    echo "copy tmux conf from y_cohen@10.55.226.121";
    scp y_cohen@10.55.226.121:~/yonienv/tmux.conf ~/.tmux.conf;

    echo "cloning tmux-plugin manager tpm";
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm;

    echo "source .tmux.conf"
    tmux source-file .tmux.conf
}

# 
# tn - create a new tmux session 
tn () 
{
    local sess_list=$(tmux ls 2>/dev/null | awk 'BEGIN{FS=":"}{print $1}');
    local sess_name=${1};
    if [ -z "${sess_name}" ] ; then
        read -p "Enter session name : " sess_name;
        [ -z "${sess_name}" ] && sess_name=yoni;
    fi;

    complete -W "$(echo ${sess_list})" tl ta tk
    tmux -u new -s ${sess_name};
}

tl ()
{
    local sess_list=$(tmux ls 2>/dev/null | awk 'BEGIN{FS=":"}{print $1}');
    complete -W "$(echo ${sess_list})" tl ta tk;
    tmux ls 2>/dev/null;
}

ta ()
{
    local sess_name=${1};

    if [ -z "${sess_name}" ] ; then
        tmux -u attach;
    else 
        tmux -u attach -t ${sess_name};
    fi
}

alias tk='tmux kill-session -t'

alias delljournalctl-all-logs-node-a='_delljournalctl a all'
alias delljournalctl-all-logs-node-b='_delljournalctl b all'
alias delljournalctl-kernel-logs-node-a='_delljournalctl a kernel'
alias delljournalctl-kernel-logs-node-b='_delljournalctl b kernel'
alias delljournalctl-nt-logs-node-a='_delljournalctl a nt'
alias delljournalctl-nt-logs-node-b='_delljournalctl b nt'

# ############ for cluster only #############################################################
alias journal-grep-panic='journalctl | grep --color "PANIC\|log_backtrace_backend"'
alias journal-grep-connect='journalnt | grep  --color "nvme.*allocate"'
alias journal-grep-discover='journalnt | grep  --color "discover.*allocate"'
alias journal-grep-nt-start='journalnt | grep --color "nt_start"'
alias journal-grep-pnvmet-start='journalkernel | grep --color "nvmet_power.*driver.*start"'
alias journal-grep-nt-set-active='journalnt | grep --color "nt_disc_set_active\|nt_disc_set_inactive"'
alias journal-grep-nt-add-ports='journalnt | grep --color "add_ports.*is_local true"'
alias journal-grep-nt-add-subsys='journalnt | grep --color "add_subsystem"'
alias journal-grep-nt-ports='echo "====> use debuc-list-ports" ; journalnt | grep --color "log_port"'
alias journal-grep-nt-local-ports='echo "====> use debuc-list-ports" ; journalnt | grep --color "log_port.*is_local true"'
alias journal-grep-nt-local-tcp-ports='echo "====> use debuc-list-ports" ; journalnt | grep --color "log_port.*trtype tcp.*is_local true"'
alias journal-grep-nt-local-fc-ports='echo "====> use debuc-list-ports" ; journalnt | grep --color "log_port.*trtype fc.*is_local true"'
alias journal-grep-nt-remote-ports='echo "====> use debuc-list-ports" ; journalnt | grep --color "log_port.*is_local false"'
alias journal-grep-nt-remote-tcp-ports='echo "====> use debuc-list-ports" ; journalnt | grep --color "log_port.*trtype tcp.*is_local false"'
alias journal-grep-nt-remote-fc-ports='echo "====> use debuc-list-ports" ; journalnt | grep --color "log_port.*trtype fc.*is_local false"'
alias journal-grep-cluster-name='journalall | grep --color -i "cyc_config.*creating cluster"'
alias journal-grep-version='journalcycconfig | grep --color -i "package version"'
alias journal-grep-nt-kernel='journalall |grep "\[nt\]\|kernel|less -I"'

alias journalall='journalctl'
alias journalalllast3minutes='journalctl --since="3 minutes ago"'
alias journalallf='journalctl -f'

alias journalnt='journalctl SUB_COMPONENT=nt'
alias journalntf='journalctl -f SUB_COMPONENT=nt'
alias journalntlast3minutes='journalctl --since="3 minutes ago" SUB_COMPONENT=nt'

alias journalcycconfig='journalctl -t cyc_config'

alias journalcycbsc='journalctl -t cyc_bsc'
alias journalcycbscf='journalctl -f -t cyc_bsc'
alias journalcycbsclast3minutes='journalctl --since="3 minutes ago" -t cyc_bsc'

alias journaldcengine='journalctl -t dc_engine'
alias journaldcenginef='journalctl -f -t dc_engine'
alias journaldcenginelast3minutes='journalctl --since="3 minutes ago" -t dc_engine'

alias journalpm='journalctl |grep xtremapp-pm | less'
alias journalpmf='journalctl -f |grep xtremapp-pm'
alias journalpmlast3minutes='journalctl --since="3 minutes ago" |grep xtremapp-pm|less'

alias journalcrypto='journalctl |grep CryptoApi | less'
alias journalcryptof='journalctl -f |grep CryptoApi'
alias journalcryptolast3minutes='journalctl --since="3 minutes ago" |grep CryptoApi|less'

alias journalsym='journalctl |grep xtremapp-sym | less'
alias journalsymf='journalctl -f |grep xtremapp-sym'
alias journalsymlast3minutes='journalctl --since="3 minutes ago" |grep xtremapp-sym|less'

alias journalmbe-r='journalctl SUB_COMPONENT=mbe_r'
alias journalmbe-rf='journalctl -f SUB_COMPONENT=mbe_r'
alias journalmbe-rlast3minutes='journalctl --since="3 minutes ago" SUB_COMPONENT=mbe_r'

alias journalkernel='journalctl -k'
alias journalkernelf='journalctl -k -f'
alias journalkernellast3minutes='journalctl -k --since="3 minutes ago"'

alias journalservicemode='journalctl SUB_COMPONENT=servicemode'

alias journal-clear-1d='journalctl --vacuum-time=1d'

# ##################################################################################

alias delltriage-all-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -a"
alias delltriage-all-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -a"
alias delltriage-all-logs-node-a-r="nice -20 ./cyc_triage.pl -b . -n a -j -- -a -r"
alias delltriage-all-logs-node-b-r="nice -20 ./cyc_triage.pl -b . -n b -j -- -a -r"

alias delltriage-nt-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j SUB_COMPONENT=nt"
alias delltriage-nt-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j SUB_COMPONENT=nt"
alias delltriage-nt-logs-node-a-r="nice -20 ./cyc_triage.pl -b . -n a -j SUB_COMPONENT=nt -r"
alias delltriage-nt-logs-node-b-r="nice -20 ./cyc_triage.pl -b . -n b -j SUB_COMPONENT=nt -r"

alias delltriage-kernel-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -t kernel"
alias delltriage-kernel-logs-node-a-r="nice -20 ./cyc_triage.pl -b . -n a -j -- -t kernel -r"
alias delltriage-kernel-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -t kernel"
alias delltriage-kernel-logs-node-b-r="nice -20 ./cyc_triage.pl -b . -n b -j -- -t kernel-r"

alias delltriage-sym-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -t xtremapp"
alias delltriage-sym-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -t xtremapp"

alias delltriage-grep-panic-a='delltriage-all-logs-node-a | grep "PANIC\|log_backtrace_backend"'
alias delltriage-grep-panic-b='delltriage-all-logs-node-b | grep "PANIC\|log_backtrace_backend"'

alias delltriage-grep-connect-a='delltriage-nt-logs-node-a | grep "nvme.*allocate"'
alias delltriage-grep-connect-b='delltriage-nt-logs-node-b | grep "nvme.*allocate"'

alias delltriage-grep-add-port-a='delltriage-nt-logs-node-a | grep "add_ports.*is_local true"'
alias delltriage-grep-add-port-b='delltriage-nt-logs-node-b | grep "add_ports.*is_local true"'

alias delltriage-grep-nt-start-a='delltriage-nt-log-node-a | grep --color "nt_start"'
alias delltriage-grep-nt-start-b='delltriage-nt-log-node-b | grep --color "nt_start"'

alias delltriage-grep-set-active-a='delltriage-nt-logs-node-a | grep --color "nt_disc_set_active\|nt_disc_set_inactive"'
alias delltriage-grep-set-active-b='delltriage-nt-logs-node-b | grep --color "nt_disc_set_active\|nt_disc_set_inactive"'

alias delltriage-grep-pnvmet-start-a='delltriage-kernel-log-node-a | grep --color "nvmet_power.*driver.*start"'
alias delltriage-grep-pnvmet-start-b='delltriage-kernel-log-node-b | grep --color "nvmet_power.*driver.*start"'

alias delltriage-node-a-grep-cluster-name='delltriage-all-logs-node-a | grep -i "cyc_config.*creating cluster"'
alias delltriage-node-b-grep-cluster-name='delltriage-all-logs-node-b | grep -i "cyc_config.*creating cluster"'

dellnvme-show-timeout ()
{
    echo "/sys/module/nvme_core/parameters/io_timeout";
    cat /sys/module/nvme_core/parameters/io_timeout;
    echo "/sys/module/nvme_core/parameters/admin_timeout";
    echo /sys/module/nvme_core/parameters/admin_timeout;
}

_delldc-node-x ()
{
    local node_dir=${1};
    local flags="${2}";
    local journalctl_cmd=;

    if ! [ -d ${node_dir} ] ; then
        echo "directory ${node_dir} does not exist";
        return -1;
    fi;

    if ! [ -d ${node_dir}/journalctl ] ; then
        echo "directory ${node_dir}/journalctl does not exist";
        return -1;
    fi;

    cd ${node_dir};

    journalctl_cmd="nice -20 ./journalctl/ld-linux-x86-64.so.2 --library-path ./journalctl ./journalctl/journalctl -o short-precise --utc -D var/log/journal/ ${flags}";
    echo "${journalctl_cmd}";
    ask_user_default_yes "continue ";
    if [ $? -eq 1 ] ; then
        eval ${journalctl_cmd};
    fi;
    
    cd -;
}

alias delldc-all-node-a='_delldc-node-x node_a'
alias delldc-all-node-b='_delldc-node-x node_b'
alias delldc-all-node-a-r='_delldc-node-x node_a -r'
alias delldc-all-node-b-r='_delldc-node-x node_b -r'

alias delldc-kernel-node-a='_delldc-node-x node_a -k'
alias delldc-kernel-node-a-r='_delldc-node-x node_a -k -r'
alias delldc-kernel-node-b='_delldc-node-x node_b -k'
alias delldc-kernel-node-b-r='_delldc-node-x node_b "-k -r"'

alias delldc-nt-node-a='_delldc-node-x node_a SUB_COMPONENT=nt'
alias delldc-nt-node-b='_delldc-node-x node_b SUB_COMPONENT=nt'
alias delldc-nt-node-a-r='_delldc-node-x node_a "SUB_COMPONENT=nt -r"'
alias delldc-nt-node-b-r='_delldc-node-x node_b "SUB_COMPONENT=nt -r"'

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

dellnvme-list-modules ()
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

bsclist-target-ports ()
{
    for i in /sys/kernel/config/nvmet/ports/* ; do
        echo -n "$i |"  ; echo -n "$(cat $i/addr_traddr) |" ; echo  "$(cat $i/addr_trsvcid) |" ;
    done |column -t;
    echo "________________________________________________________";
    ls -ltr /sys/kernel/config/nvmet/subsystems
}

get_node_id ()
{
    #local node=$(hostname |sed 's/.*-//g');

    #if [[ ${node} == 'A' ]] ; then
        #echo "31010";
    #elif [[ ${node} == 'B' ]] ; then
        #echo "31011"
    #else
        #echo 0;
    #fi;

    if [ -e /cyc_var/cyc-system-node-id.txt ] ; then
        if [ 1 -eq $(cat /cyc_var/cyc-system-node-id.txt) ] ; then
            echo "31010";
        else
            echo "31011"
        fi;
    else
        echo "none";
    fi;

}

export debuc_node="$(get_node_id)";

# set SYM_SYSTEM_NAME with cluster name
# eval $(export $(grep SYM_SYSTEM_NAME /dev/shm/xenv_1.ini | sed 's/\ //g'));
#if [ -e /dev/shm/xenv_1.ini ] ; then
    #export $(grep SYM_SYSTEM_NAME /dev/shm/xenv_1.ini | sed 's/\ //g' | sed 's/"//g');
    #export YONI_CLUSTER=${SYM_SYSTEM_NAME};

    #if [[ ${debuc_node} != 0 ]] ; then
        #echo "YONI_CLUSTER: ${YONI_CLUSTER}";
        #echo "debuc_node: $debuc_node";
    #fi;
#fi;

bscedit-xenv-ini-file ()
{
    if [ "${debuc_node}" == "31010" ] ; then
        less /dev/shm/xenv_10.ini;
    else
        less /dev/shm/xenv_11.ini;
    fi;
}

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
        echo "debug log in: journalctl SUB_COMPONENT=nt";
    else
        echo "${debuc_file} not found";
        return -1;
    fi;

    return 0;
}

alias debuc-data-collect='debuc-command "log data collect"';

alias debuc-log-version='debuc-command "log version"';
alias debuc-log-auth-enable='debuc-command "log auth enable"';
alias debuc-log-auth-disable='debuc-command "log auth disable"';

alias debuc-log-commands-enable='debuc-command "log commands enable"';
alias debuc-log-commands-disable='debuc-command "log commands disable"';

alias debuc-host-add='debuc-command "add hostgroup"';
alias debuc-host-add-secret='debuc-command "add hostgroup grp_idx=1 host_name=nqn.2014-08.org.nvmexpress:uuid:4c4c4544-005a-3710-8051-b1c04f445732 host_secret=DHHC-1:00:TATezKzRaxSMwvxnSwtvCD9XMxK9tM2bZLkjkM2qeu/d+5VC: subsys_secret=DHHC-1:00:TATezKzRaxSMwvxnSwtvCD9XMxK9tM2bZLkjkM2qeu/d+5VC: "'

alias debuc-qos-get-incoming-stats='debuc-command "get qos incoming stats"';
alias debuc-qos-log-enable='debuc-command "log qos enable"';
alias debuc-qos-log-disable='debuc-command "log qos disable"';
alias debuc-qos-delete-bucket-0='debuc-command "del qos bucket idx=0"'

alias debuc-list-hosts='debuc-command "log hosts"'
alias debuc-list-host-groups='debuc-command "log host groups"'
alias debuc-list-ports='debuc-command "log ports"'
alias debuc-list-devices='debuc-command "log devices"';
alias debuc-list-controllers='debuc-command "log controllers all"';
alias debuc-list-controllers-io='debuc-command "log controllers io"';
alias debuc-list-controllers-discovery='debuc-command "log controllers discovery"';
alias debuc-list-subsystem='debuc-command "log subsystem"';

alias bsclist-hosts=debuc-list-hosts
alias bsclist-host-groups=debuc-list-host-groups
alias bsclist-ports=debuc-list-ports
alias bsclist-devices=debuc-list-devices
alias bsclist-controllers=debuc-list-controllers
alias bsclist-controllers-io=debuc-list-controllers-io
alias bsclist-controllers-discovery=debuc-list-controllers-discovery

alias debuc-set-inactive='debuc-command "set inactive"';
alias debuc-set-active='debuc-command "set active"';

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
        echo "debuc-qos-configure ${i} ${kiops}k";
        debuc-qos-configure ${i} ${kiops}k;
    done;
}

alias debuc-qos-configure-5k-vols-1-to-100="debuc-qos-configure-kiops-vols-1-to-100 5k"
alias debuc-qos-configure-500k-vols-1-to-100="debuc-qos-configure-kiops-vols-1-to-100 500k"
alias debuc-qos-configure-1000k-vols-1-to-100="debuc-qos-configure-kiops-vols-1-to-100 1000k"
alias bsc-qos-dump='cat /sys/module/nvmet_power/parameters/qos_dump'
bsc-tcp-log-queues ()
{
    echo "nr_queues: $(cat /sys/module/nvmet_tcp/parameters/nr_tcp_queues)";
    echo 1 | sudo tee /sys/module/nvmet_tcp/parameters/nr_tcp_queues
}

bsc-fc-log-queues ()
{
    echo "nr_queues: $(cat /sys/module/nvmet_fc/parameters/nr_associations)";
    echo 1 | sudo tee /sys/module/nvmet_fc/parameters/nr_associations;
}

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
    # maybe this is a docker
    if [[ -e /.dockerenv ]] ; then
        echo "this is a docker (found /.dockerenv)";
        ask_user_default_no "try another method ? ";
        [ $? -eq 0 ] && return 0;
    fi;
     
    if [[ $(cat /proc/1/cgroup | grep docker | wc -l ) -gt 0 ]] ; then
        echo "this is a docker (/proc/1/cgroup)"
        return 0;
    fi;

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

    echo "examples";
    echo "-------------";
    echo "echo 'module nvmet_fc +p' | sudo tee /sys/kernel/debug/dynamic_debug/control";
    echo "echo 'module nvmet +p' | sudo tee /sys/kernel/debug/dynamic_debug/control";
    echo "echo 'module nvmet_power +p' | sudo tee /sys/kernel/debug/dynamic_debug/control";
    echo "echo 'module nvme_qla2xxx +p' | sudo tee /sys/kernel/debug/dynamic_debug/control";
    echo "--------------------------------------------------------------------------------";
    echo "enable all functions in the kernel module qla2xxx.ko";
    echo "echo 'module qla2xxx +p' | sudo tee /sys/kernel/debug/dynamic_debug/control";
    echo "--------------------------------------------------------------------------------";
    echo "disable all functions in the kernel module qla2xxx.ko";
    echo "echo 'module qla2xxx -p' | sudo tee /sys/kernel/debug/dynamic_debug/control";
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
        #sudo cat /sys/kernel/debug/dynamic_debug/control |awk '/.*=pfl/{print $0}';
        sudo cat /sys/kernel/debug/dynamic_debug/control |awk '/.*=p/{print $0}';
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
    local password=${2};
    local host=$(hostname -i|cut -f 1 -d ' ');
    local user=$(id -un);

    if [[ -z ${file} ]] ; then
        echo -e "${RED}missing file name${NC}";
        echo -e "${RED}usage scpcommandforfile <file> [password]${NC}";
        return -1;
    fi;

    file=$(readlink -f ${file});
    if [ -z ${password} ] ; then
        echo "scp ${user}@${host}:${file} .";
    else
        echo -e "sshpass -p \"${password}\" scp ${user}@${host}:${file} .";
    fi;
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

dellnvme-fc-host-nodename-portname ()
{
    local qla_mod=0;
    local brcm_mod=0;

    if [[  $(lsmod | grep qla2xxx | wc -l) > 0 ]] ; then
        qla_mod=1;
        #echo "qla module not loaded";
        #echo "modprobe qla2xxx and try again";
        #return;
    fi;

    if [[  $(lsmod | grep lpfc | wc -l) > 0 ]] ; then
        brcm_mod=1;
        #echo "qla module not loaded";
        #echo "modprobe qla2xxx and try again";
        #return;
    fi;

    if [[ ${qla_mod} == 0 && ${brcm_mod} == 0 ]] ; then
        echo -e "${RED}!! no fc driver is loaded !!${NC}";
    fi;

    for h in /sys/class/fc_host/* ; do
        echo -n "$(basename $h) : nn-$(cat $h/node_name):pn-$(cat $h/port_name)";
        echo    " | $(cat $h/port_state)";
    done;
}

alias dellnvme-host-nqn='cat /etc/nvme/hostnqn'
 
dellnvme-fc-connect ()
{
    local cluster_nn_pn=${1};
    local host_nn_pn=;
    local cluster_subnqn=;

    if [ -z ${cluster_nn_pn} ] ; then
        echo "$FUNCNAME <cluster nn:pn>";
        echo -e "${PURPLE}use bsclistports to get one${NC}";
        return -1;
    fi;

    # there could more than one host nn:pn
    host_nn_pn=$(dellnvme-fc-host-nodename-portname|head -1|cut -d ' ' -f 3  );

    # assuming that all logs in the discovery log would have the same subnqn
    # so I use uniq here.
    cluster_subnqn=( $(nvme discover -t fc -a ${cluster_nn_pn} -w ${host_nn_pn} | awk '/subnqn/{print $2}' | uniq) );
    if (( ${#cluster_subnqn[@]} > 1 )) ; then
        echo "found more than one subnqn : ${cluster_subnqn[@]}";
        return -1;
    fi;

    echo "nvme connect -t fc -a ${cluster_nn_pn} -w ${host_nn_pn} -n ${cluster_subnqn[0]}";
    # nvme connect -t fc -a ${cluster_subnqn} -w ${host_nn_pn} -n ${cluster_sub_nqn}";
}
 
core-list-fc-ports ()
{
    systool -c fc_host -v | grep -i "device\|inuse\|state";
}

core-restart-bsc ()
{ 
    docker restart cyc_bsc_docker;
}

core-attach-bsc ()
{
    docker exec -it cyc_bsc_docker bash
}

core-list-kernel-configs ()
{
    #echo "ls -ltr /sys/kernel/config/nvmet/ports/";
    ls -ltrR /sys/kernel/config/nvmet/ports/;
    #echo "ls -ltr /sys/kernel/config/nvmet/subsystems/";
    ls -ltrR /sys/kernel/config/nvmet/subsystems/;
    #echo "ls -ltr /sys/kernel/config/nvmet/hosts/";
    ls -ltrR /sys/kernel/config/nvmet/hosts/;
}

coreid ()
{
    local system_name;
    local system_node;

    if [ -e /cyc_var/cyc-system-name.txt ] ; then
        system_name=$(cat /cyc_var/cyc-system-name.txt);
    fi;

    if [ -e /cyc_var/cyc-system-node-id.txt ] ; then
        if [ 1 -eq $(cat /cyc_var/cyc-system-node-id.txt) ] ; then
            system_node=A;
        else
            system_node=B;
        fi;
    fi;
    #echo ${YONI_CLUSTER}-$(hostname |sed 's/.*-//g');
    echo ${system_name}-${system_node};
    echo debuc_node : ${debuc_node};

    if [ $(grep "alias y=" ~/.bashrc | wc -l) -eq 1 ] ; then
        return 0;
    fi;

    echo "alias y='source ~/yonidell.sh'" >> ~/.bashrc;
}

coreid;

#        service mode
#=============================
# docker exec -it service bash 
alias core-servicemode-start-docker='docker exec -it service bash' 
core-servicemode ()
{
    echo "core-servicemode-start-docker";
    echo "/cyc_host/cyc_service/bin/svc_rescue_state list";
    echo "/cyc_host/cyc_service/bin/svc_rescue_state clear";
    echo "/cyc_host/cyc_service/bin/svc_node reboot local -f";
}
#=============================

# nvme discover|connect example
# nvme discover -t tcp -a <take from bsclistports>
# nvme discover -t tcp -a 10.181.193.11
# nvme connect -t tcp -a 10.181.193.11 -n nqn.1988-11.com.dell:powerstore:00:133a0e05d77e9473A5F6 //  -n <nqn from discovery>
# nvme discover -t fc -a <take from bsclistports> -w <take from dellnvme-fc-host-nodename-portname>
# nvme connect -t fc -a <take from bsclistports> -w <take from dellnvme-fc-host-nodename-portname> -n nqn.1988-11.com.dell:powerstore:00:133a0e05d77e9473A5F6 //  -n <nqn from discovery>
# nvme discover -t rdma --traddr=10.219.146.182 -w 10.219.146.186
# nvme connect -t rdma -a 10.219.146.182 -n nqn.1988-11.com.dell:powerstore:00:60148e5c7660A3D9C763 -s 4420 -w 10.219.146.186 -D 
#
# connect with tcp with secrets genereated with 'nvme gen-dhchap-key -m 1'
# nvme connect -t tcp -a 10.181.193.11 -n nqn.1988-11.com.dell:powerstore:00:133a0e05d77e9473A5F6 -s 4420  -S DHHC-1:01:C7XNT6VDFTFfbGtrSimOlLFg7BAdH+UwUgkLTuSA5gcd+7/H: -C DHHC-1:01:97vgjyw8YRnwFPn0LYjeGW5/ClRhS5YuVnwTNIwUNHUWmp6v:



# btest examples
# /home/qa/btest/btest -D  -t 10 -l 10m -b 4k   R 30 /dev/dm-0
# /home/qa/btest/btest -D  -t 10 -l 10m -b 4k   R 30 /dev/nvme0n1
# if /home/qa is missing you need to mount it like so
# mount 10.55.160.100:/home/qa /home/qa

# multipath -ll
# nvme discover -t tcp -a <port from bsclistports>
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

# get cluser name from within the cluster
# grep SYM_SYSTEM_NAME /dev/shm/xenv_1.ini


unset PROMPT_COMMAND
# PS1="[\D{%H:%M %d.%m}][\u@\h:\w]\n==> "
PS1="[\D{%H:%M %d.%m}] \[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\w\[\033[0m\] \[\033[01;34m\]\n\[\033[00m\]$\[\033[00m\]=> "
