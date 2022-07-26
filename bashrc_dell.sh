#!/bin/bash

alias editbashdell='nvim ${yonienv}/bashrc_dell.sh'
alias ssh2amitvm='echo cycpass; ssh cyc@10.207.202.38'
alias ssh2eladvm='echo cycpass; ssh cyc@10.227.204.131'
alias ssh2yonivm='echo cycpass; ssh cyc@10.244.196.23'

trident_cluster_list=(WX-D0733 WX-G4011 WX-D0896 WX-D1116 WX-D1111 WX-D1126 RT-G0015 RT-G0017 WX-D1132 WX-D1138 WX-D1161 WX-D1140 RT-G0060 RT-G0068 RT-G0069 RT-G0074 RT-G0072 RT-D0196 RT-D0042 RT-D0064 RT-G0037 WX-H7060 WK-D0023);

[ -f /home/build/xscripts/xxsh ] && . /home/build/xscripts/xxsh 

create_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};
    user_name=${3};
    user_pass=${4};
    alias ${alias_name}="sshpass -p ${user_pass} ssh ${user_name}@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

dellcyclonedevelenvsetup ()
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

alias gitclone-dell-cyclone='git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git'

dellsubmodulesdiscard ()
{
	git submodule update --checkout source/cyc_core
	git submodule update --checkout source/devops-scripts
	git submodule update --checkout source/bedrock
	git submodule update --checkout source/stack
	git submodule update --checkout source/cyclone-controlpath
    git submodule update --checkout source/nt-nvmeof-frontend
}

dellcyclonebuild ()
{
	if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
		echo "you must be in arwen to build";
		return;
	fi
    
	dellcdcyclonefolder;
	[[ $? -ne 0 ]] && return -1;
	
    dellclusterruntimeenvget
    ask_user_default_yes "continue ?"
    [[ $? -eq 0 ]] && return -1;

	ask_user_default_no "prune before build ?"
	if [[ $? -eq 1 ]] ; then
	    echo "=============== make prun =========================";
	    make prune;
	fi;
	
	echo -e "\n========== start build ($(pwd)) ===================\n"
	echo "make cyc_core flavor=RETAIL force=yes"
	echo "========================================================"
	make cyc_core flavor=RETAIL force=yes
}

alias dellclusterlist='/home/public/scripts/xpool_trident/prd/xpool list -f -a'
alias dellclusterlisttrident='/home/public/scripts/xpool_trident/prd/xpool list -f -a -g Trident-kernel-IL'
alias dellclusterlistyoni='/home/public/scripts/xpool_trident/prd/xpool list -f -u y_cohen'
alias dellclusterleaserelease='/home/public/scripts/xpool_trident/prd/xpool release '
alias dellclusterlease='/home/public/scripts/xpool_trident/prd/xpool lease 7d -c '

dellclusterruntimeenvbkpfile=~/.dellclusterruntimeenvbkpfile

dellclusterruntimeenvget ()  
{ 
    local last_used_cluster=;
    
    if [[ -z ${YONI_CLUSTER} ]] ; then
        if [[ -e ${dellclusterruntimeenvbkpfile} ]] ; then
            last_used_cluster=$(grep YONI_CLUSTER ${dellclusterruntimeenvbkpfile});
        fi;
        
        echo "CYC_CONFIG not set";
        if [[ -n ${last_used_cluster} ]] ; then
            echo "last used cluster : ${last_used_cluster}"
        fi;
        
        return;
    fi;
    
    echo -e "YONI_CLUSTER=$YONI_CLUSTER\nCYC_CONFIG=${CYC_CONFIG}"
    echo -e "cyc_helpers_folder=${cyc_helpers_folder}";
    echo -e "cyclone_folder=${cyclone_folder}";
}

cyclone_folder=;
dellcdcyclonefolder ()
{
    if [[ -z ${cyclone_folder} ]] ; then
        echo "cyclone_folder not set. use dellclusterruntimeenvset <cluster>"
        return -1;
    fi;

    if ! [[ -e ${cyclone_folder} ]] ; then
        echo "${cyclone_folder} does not exist";
        return -1;
    fi;

    cd $cyclone_folder;
    return 0;
}

dellclusterruntimeenvset ()
{
    local cluster=${1};
    local cluster_config_file=;

    # user should give cluster parameter. in case he did not
    # use the default from YONI_CLUSTER
    if [[ -z ${cluster} ]] ; then 
        if [[ -z ${YONI_CLUSTER} ]] ; then
            echo "usage : dellclusterlease <cluster name>";
            return;
        fi;
        ask_user_default_yes "you did not specify <cluster> use ? ${YONI_CLUSTER}";
        [ $? -eq 0 ] && return;
        cluster=${YONI_CLUSTER};
    fi

    if [[ "cyclone" != "$(basename $(git remote get-url origin 2>/dev/null) .git)" ]] ; then
        echo "you should do this from a cyclone pdr repo";
        return -1;
    fi;

    if ! [[ -d source/cyc_core/cyc_platform/src/package/cyc_configs ]] ; then
        echo "source/cyc_core/cyc_platform/src/package/cyc_configs not found!!"
        return;
    fi;
    
    cyclone_folder=$(pwd -P);
    cyc_configs_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_configs);
    cyc_helpers_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_helpers);
    cluster_config_file=${cyc_configs_folder}/cyc-cfg.txt.${cluster}-BM;
    third_party_folder=$(readlink -f source/cyc_core/cyc_platform/src/third_party/PNVMeT);

    echo "export CYC_CONFIG=${cluster_config_file}";
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return;
    
    export CYC_CONFIG=${cluster_config_file};
    export YONI_CLUSTER=${cluster};

    echo "export CYC_CONFIG=${CYC_CONFIG}" > ${dellclusterruntimeenvbkpfile};
    echo "export YONI_CLUSTER=${cluster}"  >> ${dellclusterruntimeenvbkpfile};

    dellclusterruntimeenvget;
}

dellclusterleaseextend () 
{
    local cluster=${1};
    local extend=${2};

    if [[ -z ${cluster} ]] ; then 
        cluster=${YONI_CLUSTER};
    fi;

    if [[ -z ${cluster} ]] ; then 
        echo "no cluster name given";
        return -1;
    fi;

    if [[ -z ${extend} ]] ; then 
        extend=7d;
    fi;

    echo "/home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend}"
    /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend};

}

complete -W "$(echo ${trident_cluster_list[@]})" dellclusterruntimeenvset dellclusterlease dellclusterleaseextend dellclusterleaserelease
complete -W "$(for c in ${trident_cluster_list[@]} ; do echo $c-A $c-B ; done)" xxssh xxbsc

cyc_configs_folder=;
dellcdclusterconfigs ()
{
    if [[ -z ${cyc_configs_folder} ]] ; then 
        echo "cluster runtime env not set"
        return;
    fi;
    
    if [[ -d ${cyc_configs_folder} ]] ; then
        cd ${cyc_configs_folder}
    else
        echo "${cyc_configs_folder} does not exist";
    fi;
}

cyc_helpers_folder=;
dellcdclusterscripts ()
{
    if [[ -z ${cyc_helpers_folder} ]] ; then
        echo "cluster runtime env not set"
        return -1;
    fi
    
    if [[ -d ${cyc_helpers_folder} ]] ; then
        cd ${cyc_helpers_folder};
    else
        echo "${cyc_helpers_folder} does not exist";
        return -1;
    fi;
    
    return 0;
}

dellclusterdeploy ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        if [ -n "${YONI_CLUSTER}" ] ; then
            ask_user_default_yes "deploy to ${YONI_CLUSTER} ? "
            if [ $? -eq 1 ] ; then 
                cluster=${YONI_CLUSTER};
            else
                echo "usage dellclusterdeploy <cluster name>"; return;
            fi;
        else
            echo "usage dellclusterdeploy <cluster name>"; return;
        fi;
    fi

    if [[ -z ${CYC_CONFIG} ]] ; then
        echo "CYC_CONFIG not set. use dellclusterruntimeenvset <cluster>";
        return -1;
    fi;
    
    if ! [[ -e ${CYC_CONFIG} ]] ; then
        echo "${CYC_CONFIG} !! not found"
        return -1;
    fi;
    
    echo "install ${cluster} with ${CYC_CONFIG}"
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return; 
    
    dellcdclusterscripts;

    echo "==> $(pwd)";
    echo -e "\n./deploy  --deploytype san ${cluster}"; 
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return; 
    ./deploy  --deploytype san ${cluster}; 
    if [[ $? -ne 0 ]] ; then 
        echo "deploy failed";
        return;
    fi;

    echo -e "\n\n./reinit_array.sh -F Retail factory\n\n";
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return; 
    ./reinit_array.sh -F Retail factory;
    if [[ $? -ne 0 ]] ; then 
        echo "reinit failed";
        return;
    fi;

    echo -e "\n\n./create_cluster.py -sys ${cluster}-BM -stdout -y -post\n\n";
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return; 
    ./create_cluster.py -sys ${cluster}-BM -stdout -y -post
}

dellclusteruserspaceupdate ()
{
	dellcdclusterscripts;
	if ! [ -e fast_code_loader.sh ] ; then
		echo "fast_code_loader.sh not found";
		return 1;
	fi
	if [ -z $CYC_CONFIG ] ; then
		echo "CYC_CONFIG not defined. use dellclusterenvsetup";
		return 1;
	fi

	echo "CYC_CONFIG=$CYC_CONFIG";
	ask_user_default_yes "continue ?";
	[ $? -eq 0 ] && return 1;
	
	echo "./fast_code_loader.sh 10 -o -w /home/y_cohen/devel/cyclone/source/cyc_core"
	ask_user_default_yes "continue ?"
	[ $? -eq 0 ] && return 1;
	./fast_code_loader.sh 10 -o -w /home/y_cohen/devel/cyclone/source/cyc_core
	
	echo "./fast_code_loader.sh 11 -o -w /home/y_cohen/devel/cyclone/source/cyc_core"
	ask_user_default_yes "continue ?"
	[ $? -eq 0 ] && return 1;
	./fast_code_loader.sh 11 -o -w /home/y_cohen/devel/cyclone/source/cyc_core

	return 0;
}

# rba training
# https://confluence.cec.lab.emc.com/display/CYCLONE/Using+RBA+Tracing

dellrbatraceenable ()
{
    # do this from cyc_helpers
    if [[ -z ${cyc_helpers_folder} ]] ; then
        echo "runtime env is not set";
        return;
    fi;
    
    dellcdclusterscripts;
    
    # utils/dp_cli_a.sh rba configure -c usher all -c mapper all -c logging all -c namespace all -c cache all -c front_end all -c raid all -c backend all -c ics all --tier_size 16384
    echo "utils/dp_cli_a.sh rba configure -c front_end all --tier_size 16384"
          utils/dp_cli_a.sh rba configure -c front_end all --tier_size 16384
    echo "utils/dp_cli_a.sh rba enable";
          utils/dp_cli_a.sh rba enable
    echo "utils/dp_cli_b.sh rba configure -c front_end all --tier_size 16384";
          utils/dp_cli_b.sh rba configure -c front_end all --tier_size 16384
    echo "utils/dp_cli_b.sh rba enable";
          utils/dp_cli_b.sh rba enable
}

dellrbatracedisable ()
{
    # do this from cyc_helpers
    if [[ -z ${cyc_helpers_folder} ]] ; then
        echo "runtime env is not set";
        return;
    fi;
    
    dellcdclusterscripts;
    
    echo "utils/dp_cli_a.sh rba disable";
    utils/dp_cli_a.sh rba disable;
    echo "utils/dp_cli_b.sh rba disable";
    utils/dp_cli_b.sh rba disable;
}
 
dellrbatracerun ()
{
    node=${1:-a};

    # do this from cyc_helpers
    if [[ -z ${cyc_helpers_folder} ]] ; then
        echo "runtime env is not set";
        return;
    fi;
    
    dellcdclusterscripts;
    
    echo "./offload_rba_cont.sh -L 1 -n ${node} -O /home/y_cohen/tmp/rba/node-${node} -v"
    ./offload_rba_cont.sh -L 1 -n ${node} -O /home/y_cohen/tmp/rba/node-${node} -v
}

alias dellrbatracerun-a='dellrbatracerun a'
alias dellrbatracerun-b='dellrbatracerun b'


dellrbatracedump ()
{ 
    # use rba_sort and gunzip
    rba_zip_file=${1};
    rba_file=$(basename ${rba_zip_file} .gz);

    if [[ -z ${rba_file} ]] ; then
        echo "usage : dellrbatracedump <rba zip file>"
        return -1;
    fi;

    if ! [[ -e ${rba_zip_file} ]] ; then
        echo "${rba_zip_file} does not exist";
        return -1;
    fi;

    # do this from cyc_helpers
    if [[ -z ${cyc_helpers_folder} ]] ; then
        echo "runtime env is not set";
        return;
    fi;

    dellcdclusterscripts;

    gunzip -k ${rba_zip_file};

    ./rba_sort -f bin -p ${rba_file} -o ${rba_file}.ktr
}

dellclusterkernelspaceupdate ()
{
	dellcdclusterscripts;
	[[ $? -ne 0 ]] && return -1;
	
	# script is in repo:cyc_core, in branch:dev/grupie/fast_loader_for_nvmet_driver
	if ! [ -e fast_nvmet_driver_loader.sh ] ; then
	    echo "git checkoutfilefrombranch remotes/origin/dev/grupie/fast_loader_for_nvmet_driver cyc_platform/src/package/cyc_helpers/fast_nvmet_driver_loader.sh";
	    git checkoutfilefrombranch remotes/origin/dev/grupie/fast_loader_for_nvmet_driver cyc_platform/src/package/cyc_helpers/fast_nvmet_driver_loader.sh
	    if ! [ -e fast_nvmet_driver_loader.sh ] ; then
		    echo "fast_nvmet_driver_loader.sh not found"
		    return -1;
		fi;
	fi
	if [ -z $CYC_CONFIG ] ; then
		echo "CYC_CONFIG not defined. use dellclusterruntimeenvset";
		return -1;
	fi

	echo "CYC_CONFIG=$CYC_CONFIG";
	ask_user_default_yes "continue ?";
	[ $? -eq 0 ] && return -1;

	./fast_nvmet_driver_loader.sh;

	return 0;

}

dellclusterinfo ()
{
    local cluster=${1};

	if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
		echo "you must be in arwen";
		return;
	fi
	if ! [ -e /home/public/devutils/bin/swarm ] ; then 
		echo "/home/public/devutils/bin/swarm not found";
		return;
	fi;

    if [[ -z ${cluster} ]] ; then 
        if [ -z ${YONI_CLUSTER} ] ; then
            echo "run dellclusterenvsetup <cluster name> or dellclusterinfo <cluster name>";
            return;
        else
            cluster=${YONI_CLUSTER};
        fi;
	fi;

	print_underline_size "_" 80	 
	echo "/home/public/devutils/bin/swarm -ping ${cluster}";
	print_underline_size "_" 80	 
	/home/public/devutils/bin/swarm -ping ${cluster};

	print_underline_size "_" 80	 
	echo "/home/public/scripts/xpool_trident/prd/xpool list -f"
	print_underline_size "_" 80	 
	/home/public/scripts/xpool_trident/prd/xpool list -f

	return 0;
}

third_party_folder=
dellkernelshaget ()
{
    local mfile=${third_party_folder}/CMakeLists.txt
    
    if [[ -z ${third_party_folder} ]] ; then
        echo "runtime env not set"
        return -1;
    fi;
    
    if [[ -f ${mfile} ]] ; then
        sed -n "/Set.*PNVMET_GIT_TAG.*/p" $mfile;
    else
        echo "${mfile} not found";
        return -1
    fi;
    
    return 0;
}

dellkernelshaupdate ()
{
    local sha=${1};
    local mfile=${third_party_folder}/CMakeLists.txt
    
    # make sure dest file/folder exist.
    if [[ -z ${third_party_folder} ]] ; then
        echo "runtime env not set"
        return -1;
    fi;
    
    if ! [[ -f ${mfile} ]] ; then
        echo "${mfile} not found";
        return -1;
    fi;

    # if user did not supply sha, we can still use HEAD
    if [[ -z ${sha} ]] ; then
        # make sure were in the git repo
        git remote 2>&1 1>/dev/null;
        if [[ $? -ne 0 ]] ; then
            echo "you need to be in the linux folder";
            return -1;
        fi;

        if [[ "linux.git" != $(git remote -v |awk '{if (FNR==1) {print $2} }'  | sed 's/.*\///g') ]] ; then
            echo "you need to be in the linux folder";
            return -1;
        fi
    
        sha=$(git log -1 | awk '/commit/{print $2}');
        echo "you did not supply commit sha. using HEAD ${sha}";
    fi
    
    sed -i "s/\(Set.*PNVMET_GIT_TAG.*\"\).*\(\".*\)/\1${sha}\2/g" $mfile;
    pushd /home/y_cohen/devel/cyclone/source/cyc_core 2>/dev/null;
    git diff
    popd 2>/dev/null;
}

dellibid2commit ()
{
    local ibid=$1;
    phlibid.pl --ibid ${ibid};
    echo ===============================================================
    phlibid.pl --ibid ${ibid} | grep -i commit
}

# howto
# journalctl SUBCOMPONENT=nt
# journalctl -o short-precise --since "2022-07-04 07:56:00"
