#!/bin/bash

alias editbashhabana='${v_or_g} ${yonienv}/bashrc_habana.sh'

create_habana_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};
    user_name=${3};
    user_pass=${4};
    alias ${alias_name}="sshpass -p ${user_pass} ssh ${user_name}@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

create_habana_alias_for_host omer  oshpigelman-vm ycohen  yo1st21Hab

create_habana_alias_for_host k62     kvm-srv62-csr labuser Hab12345
create_habana_alias_for_host k62a k62-u18-a     labuser Hab12345
create_habana_alias_for_host k62b k62-u18-b     labuser Hab12345
create_habana_alias_for_host k62c k62-u18-c     labuser Hab12345
create_habana_alias_for_host k62d k62-u18-d     labuser Hab12345


create_habana_alias_for_host k227    kvm-srv227-csr labuser Hab12345

create_habana_alias_for_host k61     kvm-srv61-csr labuser Hab12345
create_habana_alias_for_host k61a k61-u18-a  labuser Hab12345
create_habana_alias_for_host k61b k61-u18-b  labuser Hab12345
create_habana_alias_for_host k61c k61-u18-c  labuser Hab12345
create_habana_alias_for_host k61d k61-u18-d  labuser Hab12345

create_habana_alias_for_host k20 kvm-srv20-csr labuser Hab12345

create_habana_alias_for_host pldm2 pldm-edk0-csr  labuser Hab12345
create_habana_alias_for_host pldm2controler  vlsi-palad01-csr.iil.intel.com palad "Cho\$ShaChu2"
create_habana_alias_for_host pldm6 pldm-edk0-idc  labuser Hab12345

create_habana_alias_for_host dali23 dali-srv23 labuser Hab12345

hlsetupenvironment ()
{
    # setup git and gerrit 
    git config --global user.name "labuser";
    git config --global user.email "labuser@habana.ai";
    git config --global pull.rebase true;
	git config --global push.default simple;
	git config --global core.editor vim;

    ssh-keyscan -p 29418 gerrit.habana-labs.com >> $HOME/.ssh/known_hosts;
    ssh-keyscan -p 29418 gerrit >> $HOME/.ssh/known_hosts;

    # create the source tree and build directories 
    mkdir $HOME/bin;
	mkdir -p $HOME/trees/npu-stack;

    # clone 3 basic directories  
	cd $HOME/trees/npu-stack;
    git clone ssh://gerrit:29418/habanalabs;
    git clone ssh://gerrit:29418/hl-thunk;
    git clone ssh://gerrit:29418/automation;

    # copy the automation scripts to labuser home directory.
    cp $HOME/trees/npu-stack/automation/habana_scripts/.bashrc ~/
	cp $HOME/trees/npu-stack/automation/habana_scripts/.bash_aliases ~/
	cp $HOME/trees/npu-stack/automation/habana_scripts/git-completion.bash ~/bin/
	cp $HOME/trees/npu-stack/automation/habana_scripts/.vimrc ~/
	source ~/.bashrc

    # for the creation of /dev/hl0 we setup udev
    sudo cp $HOME/trees/npu-stack/automation/habana_scripts/habana.rules /etc/udev/rules.d/
	sudo udevadm control --reload


}

kmsl () 
{ 
    local filter=${1:-' '};
    kmdServers=( $(~/kmd-srv.py|grep -i "${filter}" | cut -f 1 -d ' ') );
    complete -W "$( echo ${kmdServers[@]})" kms kmsssh kmsping kmstake kmsrelease;
    ~/kmd-srv.py | grep -i "${filter}" | column -t;
}

hlsl ()
{
    /software/data/hls-srv.py |column -t
}

alias kms='~/kmd-srv.py'
alias kmsfree='kmsl  free'
alias kmsfreegaudi='kmsl  "free.*gaudi"'
alias kmsyoni='kmsl  ycohen'
alias kmsgoya='kmsl  goya'
alias kmsgaudi='kmsl  gaudi'
alias kmsfreegaudi='kmsl  "free.*gaudi"'
alias kmsping='ping'
kmsrelease ()
{
    if [ -z ${1} ] ; then 
        echo "your missing a <server> to release";
        return;
    fi;

    ~/kmd-srv.py -r ${1};
}
kmsreleaseyoni ()
{
    kmsyoni |awk '{print $1}' |  while read s ; do 
        ~/kmd-srv.py -r $s   ; 
    done
}

kmsretake ()
{
    local yoni_server;
    yoni_server=$(kmsyoni|cut -f 1 -d ' ');
    for i in `echo ${yoni_server[@]}` ; do 
        echo "retaking $i";
        kmsrelease $i; 
        kms -t ${i};
    done;
}

alias kmstake='kms --force -t '


kmsssh ()
{ 
    sshpass -p Hab12345 ssh -YX labuser@$1
}

kmssshyoni ()
{
    local yonihost;
    yonihost=$(kmsyoni|cut -f 1 -d ' ');
    kmsssh ${yonihost};
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

alias hlpcidevicelist="lspci |grep Proc |cut -f 1 -d' ' "
alias hlpcideviceshow='sudo lspci -vv -nn -s '
showlspci ()
{
    local i;
    local dev;
    hl_pci_devices=( $(hlpcidevicelist) );
    if (( ${#hl_pci_devices[@]} == 1 )) ; then 
       hlpcidevicehow ${hl_pci_devices[0]} ;
    elif ( ${hl_pci_devices[*]} > 1 ) ; then
        # ask user which device to print
        for i in ${!hl_pci_devices[@]} ; do 
            echo "${i}) ${hl_pci_devices[$i]}";
            read -p "Enter device number : " dev;
            if (( $dev >= 0 && $dev < ${#hl_pci_devices[@]})) ; then
                hlpcidevicehow ${hl_pci_devices[$dev]};
            fi
        done
    else
        echo "No habana devices found on pci bus";
    fi
}

hlpcideviceremove ()
{
    pci_device=${1};
    echo 1 | sudo tee /sys/bus/pci/device/${pci_device}/remove
}

alias hlasictype='cat /sys/class/habanalabs/hl0/device_type'
alias hlsetloopbackmode="echo 0x3ff | sudo tee  /sys/kernel/debug/habanalabs/hl0/nic_mac_loopback"
alias hlprintnetworkstatus="~/trees/npu-stack/automation/habana_scripts/manage_network_ifs.sh --status"
alias hlstartnetword="~/trees/npu-stack/automation/habana_scripts/manage_network_ifs.sh --up"

alias hlbuildsimulator='build_func_sim6 -c -r'

hlrepoupdate ()
{
    repo init -u ssh://gerrit.habana-labs.com:29418/software-repo -m default.xml -b master 
}

hlstartdriversimulator ()
{
    pushd ~/builds/habanalabs_build/drivers/misc/habanalabs
    sudo insmod habanalabs.ko timeout_locked=40000 bringup_flags_enable=1 nic_ports_mask=1 nic_ports_ext_mask=1 bfe_tpc_mask=0 bfe_mmu_enable=1 bfe_pmmu_pgt_hr=1 bfe_security_enable=0 sim_mode=1 dyndbg==pf
    popd 2>&1 > /dev/null
}

hlstopdriver ()
{
    sudo rmmod habanalabs
}

hlrestartdriver ()
{
    hlstopdriver;
    hlstartdriversimulator;
}

alias checkpatchhabana="$linuxkernelsourcecode/scripts/checkpatch.pl  --max-line-length=80 --ignore gerrit_change_id --ignore='FILE_PATH_CHANGES,GERRIT_CHANGE_ID,NAKED_SSCANF,SSCANF_TO_KSTRTO,PREFER_PACKED,SPLIT_STRING,CONSTANT_COMPARISON,MACRO_WITH_FLOW_CONTROL,MULTISTATEMENT_MACRO_USE_DO_WHILE,SINGLE_STATEMENT_DO_WHILE_MACRO,COMPLEX_MACRO'"
hlcheckpatches ()
{
    local num_of_patches=${1:-1};

    $((num_of_patches--));

    for (( i=${num_of_patches}; i >= 0  ; i-- )) ; do 
        echo;
        git log --pretty=format:'%C(yellow)%h %Cblue%an %Creset%s' HEAD~${i}^!
        echo "==================================================================="
        git show --format=email HEAD~${i}^! | checkpatchhabana 
        echo "==================================================================="
        echo;
        
        if (( $i > 0 )) ; then 
            ask_user_default_yes "Continue to next patch"; 
            [ $? -eq 0 ] && break; 
        fi 
    done;
}

hlsimulatorstart ()
{
	echo "run_func_sim6 -spdlog 0  -i -r -D 12";
	run_func_sim6 -spdlog 0  -i -r -D 12
}

hldriverstartsimulator ()
{
    local ports=${1:-0x1};
    local driver_args;

    driver_args="timeout_locked=40000";
    driver_args+=" bringup_flags_enable=1";
    driver_args+=" nic_ports_mask=${ports}";
    driver_args+=" nic_ports_ext_mask=${ports}"
    driver_args+=" bfe_mmu_enable=1";
    driver_args+=" bfe_pmmu_pgt_hr=1";
    driver_args+=" bfe_security_enable=0";
    driver_args+=" bfe_tpc_mask=0";
    driver_args+=" sim_mode=1";
    driver_args+=" dyndbg==pf";

    pushd ~/builds/habanalabs_build/drivers/misc/habanalabs
    set -x;
    sudo insmod habanalabs.ko ${driver_args};
    set +x;
    popd 2>&1 > /dev/null
}

hldriverstart()
{
    local driver_args;

    driver_args+=" dyndbg==pf";

    pushd ~/builds/habanalabs_build/drivers/misc/habanalabs
    set -x;
    sudo insmod habanalabs.ko ${driver_args};
    set +x;
    popd 2>&1 > /dev/null
}

hldriverstop()
{
    sudo rmmod habanalabs
}

hlethlist () 
{ 
    header=(INTF DRIVER IP-ADDR)

    intf=( $(ls /sys/class/net/ ) );
    ipaddr=( $( for i in $(echo ${intf[*]}) ; do ip a s $i | awk '/inet/{print $2}' ; done ) );
    driver=( $( for i in $(echo ${intf[*]}) ; do ethtool -i $i  2>/dev/null; done | awk '/driver/{print $2}' ) ) 

    (echo ${header[*]}
    for ((i=0 ; i<${#intf[*]} ; i++)) ; do 
    	echo "${intf[$i]} ${driver[$i]} ${ipaddr[$i]}"	
    done) | column -t
}

alias hldriverstatus='lsmod |grep habanalabs'

alias hlnetwork='~/trees/npu-stack/automation/habana_scripts/manage_network_ifs.sh'
alias hlnetworkstatus='hlnetwork --status'
alias hlnetworkup='hlnetwork --up'
alias hlnetworkdown='hlnetwork --down'
alias buildhabanalabs='build_and_insmod_habanalabs -b'
alias buildhlthunk='build_hlthunk -c'

alias hlfirmwareversion='sudo hl-smi|grep -i version'

alias cdhabanalabs='cd ~/trees/npu-stack/habanalabs'
alias cdhlthunk='cd ~/trees/npu-stack/hl-thunk'
alias cdautomation='cd ~/trees/npu-stack/automation'
alias cdspecs='cd ~/trees/npu-stack/specs'
alias hlcoverity-hlthunk='/home/ycohen/trees/npu-stack/automation/habana_scripts/run_coverity.sh -p hlthunk --local -f -F'
alias hlcoverity-habanalabs='/home/ycohen/trees/npu-stack/automation/habana_scripts/run_coverity.sh -p habanalabs --local -f -F'
