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
create_habana_alias_for_host k62a k62-u20-a     labuser Hab12345
create_habana_alias_for_host k62b k62-u20-b     labuser Hab12345
create_habana_alias_for_host k62c k62-u20-c     labuser Hab12345
create_habana_alias_for_host k62d k62-u20-d     labuser Hab12345


create_habana_alias_for_host k227    kvm-srv227-csr labuser Hab12345
create_habana_alias_for_host k227b    k227-u20-3b labuser Hab12345

create_habana_alias_for_host k61     kvm-srv61-csr labuser Hab12345
create_habana_alias_for_host k61a k61-u18-a  labuser Hab12345
create_habana_alias_for_host k61b k61-u18-b  labuser Hab12345
create_habana_alias_for_host k61c k61-u18-c  labuser Hab12345
create_habana_alias_for_host k61d k61-u18-d  labuser Hab12345

create_habana_alias_for_host k20 kvm-srv20-csr labuser Hab12345

create_habana_alias_for_host pldm2 pldm-edk0-csr  labuser Hab12345
create_habana_alias_for_host pldm2controler  vlsi-palad01-csr.iil.intel.com palad "Cho\$ShaChu2"
create_habana_alias_for_host pldm6 pldm-edk0-idc  labuser Hab12345
create_habana_alias_for_host pldm8 pldm-edk02-idc  labuser Hab12345

create_habana_alias_for_host pldmfsm1 fmepsb0001.fm.intel.com labuser Hab12345
create_habana_alias_for_host pldmfsm2 fmepsb0002.fm.intel.com labuser Hab12345

create_habana_alias_for_host dali23 dali-srv23 labuser Hab12345
create_habana_alias_for_host srv649 kvm-srv649-csr labuser Hab12345
create_habana_alias_for_host srv621 kvm-srv621-csr labuser Hab12345
create_habana_alias_for_host srv693 kvm-srv693-csr labuser Hab12345
create_habana_alias_for_host k2033e k203-u18-3e labuser Hab12345

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
    done | column -t
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

# alias checkpatchhabana="$linuxkernelsourcecode/scripts/checkpatch.pl  --max-line-length=100 --ignore gerrit_change_id --ignore='FILE_PATH_CHANGES,GERRIT_CHANGE_ID,NAKED_SSCANF,SSCANF_TO_KSTRTO,PREFER_PACKED,SPLIT_STRING,CONSTANT_COMPARISON,MACRO_WITH_FLOW_CONTROL,MULTISTATEMENT_MACRO_USE_DO_WHILE,SINGLE_STATEMENT_DO_WHILE_MACRO,COMPLEX_MACRO'"
alias checkpatchhabana="$linuxkernelsourcecode/scripts/checkpatch.pl  --max-line-length=100 --ignore gerrit_change_id --ignore='FILE_PATH_CHANGES,VSPRINTF_SPECIFIER_PX,VSPRINTF_POINTER_EXTENSION,IF_0,LINUX_VERSION_CODE,CONSTANT_COMPARISON,UNKNOWN_COMMIT_ID'"
# alias checkpatchhabana="$linuxkernelsourcecode/scripts/checkpatch.pl  --max-line-length=80 --ignore gerrit_change_id --ignore='FILE_PATH_CHANGES,VSPRINTF_SPECIFIER_PX,VSPRINTF_POINTER_EXTENSION,IF_0,LINUX_VERSION_CODE,CONSTANT_COMPARISON'"
hlcheckpatches ()
{
    local num_of_patches=${1:-1};

    ((num_of_patches--));

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
# 	echo "run_func_sim6 -spdlog 0  -i -r -D 12";
# 	run_func_sim6 -spdlog 0  -i -r -D 12
    echo "run_coral_sim -C gaudi2 -D 16"
    run_coral_sim -C gaudi2 -D 16
}


hl_driver_file=~/builds/habanalabs_build/drivers/misc/habanalabs/habanalabs.ko;
hl_driver_en_file=~/builds/habanalabs_build/drivers/net/ethernet/habanalabs/habanalabs_en.ko;

hldriverstartsimulator ()
{
    local ports=${1:-0xffff};
    local driver_args="${2}";
    local driver_en_args;

    driver_args+=" timeout_locked=40000";
#     driver_args+=" bringup_flags_enable=1";
    driver_args+=" nic_ports_mask=${ports}";
    driver_args+=" nic_ports_ext_mask=${ports}"
#     driver_args+=" bfe_mmu_enable=1";
#     driver_args+=" bfe_pmmu_pgt_hr=1";
#     driver_args+=" bfe_security_enable=0";
#     driver_args+=" bfe_tpc_mask=0";
    driver_args+=" sim_mode=1";
    driver_args+=" dyndbg==pf";

    driver_en_args="dyndbg==pf"

    set -x;
    sudo insmod ${hl_driver_en_file} ${driver_en_args};
    sudo insmod ${hl_driver_file} ${driver_args};
    set +x;
}

hldriverrestartsimulator()
{
    local port_mask=${1:-0xfffff};
    local driver_args="${2}";
    hldriverstop;
    hldriverstartsimulator ${port_mask} ${driver_args};
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
    if [ $(lsmod | cut -d' ' -f 1 | grep -w habanalabs  | wc -l) -eq 1 ] ; then 
        echo "sudo rmmod habanalabs";
        sudo rmmod habanalabs;
    fi;

    if [ $(lsmod | cut -d' ' -f 1 | grep -w habanalabs_en  | wc -l) -eq 1 ] ; then 
        echo "sudo rmmod habanalabs_en";
        sudo rmmod habanalabs_en;
    fi;
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
alias hldriverbuild='build_and_insmod_habanalabs -b'
alias hlthunkbuild='2>&1 build_hlthunk | tee build.log'
alias hlthunkbuildverbose='2>&1 VREBOSE=1 build_hlthunk | tee build.log'

alias hlfirmwareversion='sudo hl-smi|grep -i version'

alias cdhabanalabs='cd ~/trees/npu-stack/habanalabs'
alias cdhlthunk='cd ~/trees/npu-stack/hl-thunk'
alias cdautomation='cd ~/trees/npu-stack/automation'
alias cdspecs='cd ~/trees/npu-stack/specs'
alias cdhldk='cd ~/trees/npu-stack/hldk'
alias cdtmp='cd /home_local/ycohen/tmp'
alias hlcoverity-hlthunk='/home/ycohen/trees/npu-stack/automation/habana_scripts/run_coverity.sh -p hlthunk --local -f -F'
alias hlcoverity-habanalabs='/home/ycohen/trees/npu-stack/automation/habana_scripts/run_coverity.sh -p habanalabs --local -f -F'
alias hlcopyenvtopldmfsm1='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@fmepsb0001.fm.intel.com:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvtopldmfsm2='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@fmepsb0002.fm.intel.com:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvtopldm2='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@pldm-edk0-csr:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvtopldm6='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@pldm-edk0-idc:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvtopldm8='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@pldm-edk02-idc:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvtok61a='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k61-u18-a:/local_home/labuser/Documents/users/ycohen/'
alias hlcopyenvtok61b='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k61-u18-b:/local_home/labuser/Documents/users/ycohen/'
alias hlcopyenvtok61c='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k61-u18-c:/local_home/labuser/Documents/users/ycohen/'
alias hlcopyenvtok61d='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k61-u18-d:/local_home/labuser/Documents/users/ycohen/'
alias hlcopyenvtok62a='sshpass -p Hab12345 rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k62-u20-a:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvtok62b='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k62-u20-b:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-hls2-srv11-csr='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@hls2-srv11-csr:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-srv649='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@kvm-srv649-csr:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-srv621='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@kvm-srv621-csr:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-srv693='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@kvm-srv693-csr:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-k203u18a='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k203-u18-1a:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-k203u18b='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k203-u18-1b:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-k203u18d='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k203-u18-3d:/home/labuser/Documents/users/ycohen/'
alias hlcopyenvto-k203u18e='rsync -av -e ssh --exclude='.git' /home/ycohen/share/tasks/yonienv.files/ labuser@k203-u18-3e:/home/labuser/Documents/users/ycohen/'
alias hlclonehabanalabs='git clone ssh://gerrit:29418/habanalabs'
