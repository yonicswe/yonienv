#!/bin/bash

alias editbashhabana='${v_or_g} ${yonienv}/bashrc_habana.sh'

create_habana_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};
    user_name=${3};
    user_pass=${4};
    alias ${alias_name}="sshpass -p ${user_pass} ssh -YX ${user_name}@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

create_habana_alias_for_host omer  oshpigelman-vm ycohen  yo1st21Hab
create_habana_alias_for_host k62 kvm-srv62-tlv labuser Hab12345
create_habana_alias_for_host k62u18a k62-u18-a  labuser Hab12345
create_habana_alias_for_host k62u18b k62-u18-b  labuser Hab12345
create_habana_alias_for_host k62u18c k62-u18-c  labuser Hab12345
create_habana_alias_for_host k62c75a k62-c75-a  labuser Hab12345
create_habana_alias_for_host k62c75b k62-c75-b  labuser Hab12345

create_habana_alias_for_host k61 kvm-srv61-tlv labuser Hab12345
create_habana_alias_for_host k61u18a k62-u18-a  labuser Hab12345
create_habana_alias_for_host k61u18b k62-u18-b  labuser Hab12345
create_habana_alias_for_host k61c k62-c75-a  labuser Hab12345
create_habana_alias_for_host k61c k62-c75-b  labuser Hab12345

create_habana_alias_for_host dali23 dali-srv23 labuser Hab12345

kmsl () 
{ 
    local filter=${1:-' '};
    kmdServers=( $(~/kmd-srv.py|grep -i "${filter}" | cut -f 1 -d ' ') );
    complete -W "$( echo ${kmdServers[@]})" kms kmsssh;
    ~/kmd-srv.py | grep -i "${filter}" | column -t;
}

alias kms='~/kmd-srv.py'
alias kmsfree='kmsl  free'
alias kmsyoni='kmsl  ycohen'
alias kmsgoya='kmsl  goya'
alias kmsgaudi='kmsl  gaudi'
kmsrelease ()
{
    kmsyoni |awk '{print $1}' |  while read s ; do 
        ~/kmd-srv.py -r $s   ; 
    done
}

kmsretake ()
{
    local yoni_server;
    yoni_server=$(kmsyoni|cut -f 1 -d ' ');
    kmsrelease;
    kms -t ${yoni_server};
}

kmsssh ()
{ 
    sshpass -p Hab12345 ssh -YX labuser@$1
}


gitcommithabana ()
{
    local jira_ticket=${1};
    if [ -n "${jira_ticket}" ] ; then 
        sed -i "s/\[SW-.*\]/\[SW-${jira_ticket}\]/g" ${yonienv}/git_templates/git_commit_habana_template;
    fi

    git config commit.template ${yonienv}/git_templates/git_commit_habana_template;
    git commit;
    git config --unset commit.template;
}

alias listhlpci="lspci |grep Proc |cut -f 1 -d' ' "
alias showhlpcidevice='sudo lspci -vv -nn -s '
showlspci ()
{
    local i;
    local dev;
    hl_pci_devices=( $(listhlpci) );
    if (( ${#hl_pci_devices[@]} == 1 )) ; then 
       showhlpcidevice ${hl_pci_devices[0]} ;
    elif ( ${hl_pci_devices[*]} > 1 ) ; then
        # ask user which device to print
        for i in ${!hl_pci_devices[@]} ; do 
            echo "${i}) ${hl_pci_devices[$i]}";
            read -p "Enter device number : " dev;
            if (( $dev >= 0 && $dev < ${#hl_pci_devices[@]})) ; then
                showhlpcidevice ${hl_pci_devices[$dev]};
            fi
        done
    else
        echo "No habana devices found on pci bus";
    fi
}

alias hlasictype='cat /sys/class/habanalabs/hl0/device_type'
alias hlsetloopbackmode="echo 0x3ff | sudo tee  /sys/kernel/debug/habanalabs/hl0/nic_mac_loopback"
alias hlprintnetworkstatus="~/trees/npu-stack/automation/habana_scripts/manage_network_ifs.sh --status"
alias hlstartnetword="~/trees/npu-stack/automation/habana_scripts/manage_network_ifs.sh --up"
