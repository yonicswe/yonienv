#!/bin/bash

alias editbashdell='${v_or_g} ${yonienv}/bashrc_dell.sh'

create_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};
    user_name=${3};
    user_pass=${4};
    alias ${alias_name}="sshpass -p ${user_pass} ssh ${user_name}@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

dellenvsetup ()
{
	git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git
	cd cyclone
	git submodule update --init source/cyc_core
	git submodule update --init source/devops-scripts
	git submodule update --init source/bedrock
	git submodule update --init source/stack
	git submodule update --init source/cyclone-controlpath
    git submodule update --init source/nt-nvmeof-frontend
    git c int/foothills-prime/main-pl
    git submodule update
    git fetch origin
    git reset --hard origin/int/foothills-prime/main-pl
}

dellbuilddebug ()
{
    make prune
    make cyc_core flavor=RETAIL force=yes
}

alias dellclusterlist='/home/public/scripts/xpool_trident/prd/xpool list -a -g Trident-kernel-IL'
alias dellclusterlease='/home/public/scripts/xpool_trident/prd/xpool lease 7d -c '
alias dellcdconfigs='cd /home/y_cohen/devel/cyclone/source/cyc_core/cyc_platform/src/package/cyc_configs'
alias dellcdcyc_helpers='cd /home/y_cohen/devel/cyclone/source/cyc_core/cyc_platform/src/package/cyc_helpers'

dellclusterdeploy ()
{
    local cluster=${1};
    if [ -z ${cluster} ] ; then 
        echo "usage dellclusterlease <cluster name>";
        return;
    fi
    echo "export CYC_CONFIG=/home/amite/cyclone/cyclone/source/cyc_core/cyc_platform/src/package/cyc_configs/cyc-cfg.txt.${1}"
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return; 
    export CYC_CONFIG=/home/amite/cyclone/cyclone/source/cyc_core/cyc_platform/src/package/cyc_configs/cyc-cfg.txt.${1};
    
    dellcdcyc_helpers;

    echo "./deploy  --deploytype san ${1}"; 
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return; 
    ./deploy  --deploytype san ${1}; 
    (set -x ; sleep 20; set +x);

    echo "./reinit_array.sh -F Retail factory";
    ./reinit_array.sh -F Retail factory;

    echo "./create_cluster.py -sys ${1} -stdout -y -post"
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return; 
    ./create_cluster.py -sys ${1} -stdout -y -post
}

