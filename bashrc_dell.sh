#!/bin/bash

alias editbashdell='v ${yonienv}/bashrc_dell.sh'
alias ssh2amitvm='echo cycpass; ssh cyc@10.207.202.38'
alias ssh2eladvm='echo cycpass; ssh cyc@10.227.204.131'
alias ssh2yonivm='sshpass -p cycpass ssh cyc@10.244.196.235'
export YONI_CLUSTER=;
export CYC_CONFIG=;

dell_clusters_file=${yonienv}/bashrc_dell_clusters.sh;
dell_cluster_list_file=${yonienv}/bashrc_dell_cluster_list_file.sh;
# trident_cluster_list=(RT-G0082 RT-D3082 WX-D0902 WX-D0910 WX-G4033 WX-D0909 WX-D0733 WX-G4011 WX-D0896 WX-D1116 WX-D1111 WX-D1126 RT-G0015 RT-G0017 WK-D0675 WK-D0677 WK-D0666 WX-D1140 RT-G0060 RT-G0068 RT-G0069 RT-G0074 RT-G0072 RT-D0196 RT-D0042 RT-D0064 RT-G0037 WX-H7060 WK-D0023 );
trident_cluster_list=( $(cat ${dell_clusters_file}) );
# trident_cluster_list_nodes=$(for c in ${trident_cluster_list[@]} ; do echo $(echo $c|awk '{print tolower($0)}' ) $c $c-A $c-B $c-a $c-b ; done)
# trident_cluster_list_nodes=$(for c in ${trident_cluster_list[@]} ; do echo $(echo $c|awk '{print toupper($0)}' ) $c $c-A $c-B ; done)

# declare -A dell_cluster_list;
# export dell_cluster_list;

[ -f /home/build/xscripts/xxsh ] && . /home/build/xscripts/xxsh 

_trident_cluster_list_nodes_init ()
{
    trident_cluster_list_nodes=$(for c in ${trident_cluster_list[@]} ; do echo $(echo $c|awk '{print toupper($0)}' ) $c $c-A $c-B ; done) 
    complete -W "$(echo ${trident_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaserelease dellclusterdeploy dellclusterleasewithforce
    complete -W "$(echo ${trident_cluster_list_nodes[@]})" xxssh xxbsc dellclusterguiipget dellclusterinfo dellclusterlease dellclusterleaseextend 
}
_trident_cluster_list_nodes_init;

_dellclusterlistinit ()
{
    local cluster;
    local node_a;
    local node_b;
    declare -A dell_cluster_list;

    if ! [ -e ${dell_cluster_list_file} ] ; then
        touch ${dell_cluster_list_file};
    fi;

    for c in $(cat ${dell_cluster_list_file}) ; do
        echo "$FUNCNAME $cluster";
        cluster=$(echo $c | awk '{print toupper($0)}' )
        node_a=$(echo ${cluster}-A);
        node_b=$(echo ${cluster}-B);
        set -x;
        dell_cluster_list[$c]=1;
        dell_cluster_list[$node_a]=1;
        dell_cluster_list[$node_b]=1;
        set +x;
    done;

    echo "$FUNCNAME dell_cluster_list : ${!dell_cluster_list[@]}"
}

# _dellclusterlistinit;

# 
# return 1 if cluster in list
# return 0 if clutster not in list
#
_dellclusterlistfindcluster ()
{
    local cluster=${1};

    cluster=$(echo $cluster | awk '{toupper($0)}');

    # if [ ${dell_cluster_list[${cluster}]+_} ] ; then 
    if [[ " $( echo ${trident_cluster_list[@]}) " =~ " $cluster " ]] ; then 
        return 1 ; 
    else 
        return 0; 
    fi;
}

dellclusterlistaddcluster ()
{
    local cluster=${1};

    _dellclusterlistfindcluster ${cluster};

    if [[ 0 -eq $? ]] ; then
        # dell_cluster_list[${cluster}]=1;
        trident_cluster_list+=${cluster};
        echo "${cluster} " >> ${dell_clusters_file}; 
        _trident_cluster_list_nodes_init;
    fi;
}

create_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};
    user_name=${3};
    user_pass=${4};
    alias ${alias_name}="sshpass -p ${user_pass} ssh ${user_name}@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

alias dellclonepnvmet='git clone --branch pnvmet/v3.5-medusa --single-branch git@eos2git.cec.lab.emc.com:cyclone/linux.git pnvmet'
dellcyclonedevelreset ()
{
    # are you in cyclone folder ? 
    git fetch;
    git sm update;
    # git submodule update source/cyc_core
    # git submodule update source/devops-scripts
    # git submodule update source/bedrock
    # git submodule update source/stack
    # git submodule update source/cyclone-controlpath
    # git submodule update source/nt-nvmeof-frontend
    # git submodule update source/third-party
    git c . 
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
	git submodule update --init source/third-party
	git c int/foothills-prime/main-pl
	git submodule update
	git fetch origin
	git reset --hard origin/int/foothills-prime/main-pl
}

alias dell-clone-cyclone='git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git'
alias dell-clone-pnvmet='git clone git@eos2git.cec.lab.emc.com:cyclone/linux.git'

dellsubmodulesdiscard ()
{
	git submodule update --checkout source/cyc_core
	git submodule update --checkout source/devops-scripts
	git submodule update --checkout source/bedrock
	git submodule update --checkout source/stack
	git submodule update --checkout source/cyclone-controlpath
    git submodule update --checkout source/nt-nvmeof-frontend
}

_dellcyclonebuild ()
{
    local flavor;

	if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
		echo "you must be in arwen to build";
		return;
	fi
    
	dellcdcyclonefolder;
	[[ $? -ne 0 ]] && return -1;
	
    dellclusterruntimeenvget
    ask_user_default_yes "continue ?"
    [[ $? -eq 0 ]] && return -1;

    # dellcyclonebuildhistorylog;

    ask_user_default_no "flavor DEBUG ? ";
    if [[ $? -eq 0 ]] ; then
        flavor=RETAIL;
    else
        flavor=DEBUG;
    fi;

	ask_user_default_no "prune before build ?"
	if [[ $? -eq 1 ]] ; then
	    echo "=============== make prun =========================";
	    make prune;
	fi;

	echo -e "\n========== start build ($(pwd)) ===================\n"
	echo "make cyc_core flavor=${flavor} force=yes"
	echo "========================================================"
	make cyc_core flavor=${flavor} force=yes
}

alias dellcyclonebuild='time _dellcyclonebuild'

builds_journal_db="build-history";
builds_journal_db_path=~/devel;

dellcyclonebuildhistorylog () 
{
    local pnvmet_folder=${1};
    local pnvmet_branch=${2};
    local pnvmet_sha=${3};

    local cyclone_folder_sqlite_param=;
    local pnvmet_folder_sqlite_param=;
    local pnvmet_branch_sqlite_param=;
    local pnvmet_sha_sqlite_param=;

    [[ -z ${pnvmet_folder} ]] && return -1;
    [[ -z ${pnvmet_branch} ]] && return -1;
    [[ -z ${pnvmet_sha} ]] && return -1;

    cyclone_folder_sqlite_param=$(echo -n \' ; echo ${cyclone_folder} ; echo \');
    pnvmet_folder_sqlite_param=$(echo -n \'  ; echo ${pnvmet_folder}  ; echo \')
    pnvmet_branch_sqlite_param=$(echo -n \'  ; echo ${pnvmet_branch}  ; echo \');
    pnvmet_sha_sqlite_param=$(echo -n \'     ; echo ${pnvmet_sha}     ; echo \');

    pushd ${builds_journal_db_path} 1>/dev/null;

    sqlite3 -line ${builds_journal_db} "insert into cyclone_builds \
        values(${cyclone_folder_sqlite_param}, datetime('now', 'localtime'), ${pnvmet_folder_sqlite_param}, \
        ${pnvmet_branch_sqlite_param}, ${pnvmet_sha_sqlite_param})";

    popd 1>/dev/null;
}

dellcyclonebuildhistoryshow ()
{
    pushd ${builds_journal_db_path} 1>/dev/null;

    sqlite3 ${builds_journal_db} "select * from cyclone_builds";

    popd 1>/dev/null;
}

# dellcyclonebuildhistoryreset ()
# {
    # pushd ${builds_journal_db_path} 1>/dev/null;

    # sqlite3 -line ${builds_journal_db} "delete from cyclone_builds";

    # popd 1>/dev/null;
# }

dellcyclonebuildhistoryreset ()
{
    pushd ${builds_journal_db_path} 1>/dev/null;

    sqlite3 -line ${builds_journal_db} "drop table cyclone_builds";

    sqlite3 -line ${builds_journal_db} "create table cyclone_builds(cyc_folder text)";
    sqlite3 -line ${builds_journal_db} "alter table cyclone_builds add date text";
    sqlite3 -line ${builds_journal_db} "alter table cyclone_builds add pnvmet_folder text";
    sqlite3 -line ${builds_journal_db} "alter table cyclone_builds add pnvmet_branch text";
    sqlite3 -line ${builds_journal_db} "alter table cyclone_builds add pnvmet_sha text";

    popd 1>/dev/null;
}

_dellclusterlist ()
{
    local list_file=${1};
    local dell_group=${2};
    local dell_group_label=${3};

    echo "$FUNCNAME: list_file=${list_file} dell_group=${dell_group} dell_group_label=${dell_group_label}";

    if [ -e ${list_file} ] ; then
        ask_user_default_yes "re-generate ${list_file}";
        if [ $? -eq 0 ] ; then
            v ${list_file}
            return;
        fi;
    fi;
     
    if ! [ -z ${dell_group_label} ] ;then
        dell_group_label="-l ${dell_group_label}";
    fi;

    if [[ -z "${dell_group}" ]] ; then
        dell_group="-f";
    else
        dell_group="-a -f -g ${dell_group}";
    fi;

    echo "/home/public/scripts/xpool_trident/prd/xpool list ${dell_group} ${dell_group_label}";
    # /home/public/scripts/xpool_trident/prd/xpool list ${dell_group} ${dell_group_label} --sort lessee | tee ${list_file}; 
    echo "/home/public/scripts/xpool_trident/prd/xpool list ${dell_group} ${dell_group_label} | tee /tmp/cluster-list-file.txt"
    /home/public/scripts/xpool_trident/prd/xpool list ${dell_group} ${dell_group_label} | tee /tmp/cluster-list-file.txt

    # if [ 0 -eq $(grep -i "no clusters are leased" | wc -l) ] ; then
        # echo "no clusters were found";
        # return;
    # fi;

    (set -x ; mv /tmp/cluster-list-file.txt ${list_file});
    ask_user_default_yes "open with vim ${list_file} ?";
    [ $? -eq 0 ] && return;
    v ${list_file};
}

_dellclusterlistuser ()
{
    local user=${1};
    [ -z ${user} ] && return;
    /home/public/scripts/xpool_trident/prd/xpool list -u ${user};
}

# alias dellclusterlistall='/home/public/scripts/xpool_trident/prd/xpool list -a -f'
dellclusterlist-all ()
{
    ask_user_default_no "are you sure ? it might take a while..."
    [ $? -eq 0 ] && return;
    /home/public/scripts/xpool_trident/prd/xpool list -a -x -f;
}

alias dellclusterlist-yoni='          _dellclusterlist ~/docs/dell-cluster-list-yoni.txt'
alias dellclusterlist-user='          _dellclusterlistuser'
alias dellclusterlist-trident='       _dellclusterlist ~/docs/dell-cluster-list-trident.txt         Trident-kernel-IL'
alias dellclusterlist-pm-il='         _dellclusterlist ~/docs/dell-cluster-list-platformmanager.txt PM-IL'
alias dellclusterlist-xblock='        _dellclusterlist ~/docs/dell-cluster-list-xblock.txt          Xblock-NDU'
alias dellclusterlist-shared='        _dellclusterlist ~/docs/dell-cluster-list-shared.txt          Core-Dev-Shared'
alias dellclusterlist-shared-nvmeofc='_dellclusterlist ~/docs/dell-cluster-list-shared-nvmeofc.txt  Core-Dev-Shared NVMeOF-FC'
alias dellclusterlist-shared-indus='  _dellclusterlist ~/docs/dell-cluster-list-shared-indus.txt    Core-Dev-Shared-Indus'
alias dellclusterlist-qa-app-lab='    _dellclusterlist ~/docs/dell-cluster-list-qa-app-lab.txt      QA-AppLab'
alias dellclusterlist-trident-roce='  _dellclusterlist ~/docs/dell-cluster-list-trident-roce.txt    Trident-kernel-IL NVMeOF-RoCE'
alias dellclusterlist-trident-indus=' _dellclusterlist ~/docs/dell-cluster-list-trident-indus.txt    Trident-kernel-IL indus'

xpool_users=(y_cohen grupie engela eldadz levyi2);
complete -W "$(echo ${xpool_users[@]})" dellclusterlist-user dellclusterlease-update-user;

alias dellclusterleaserelease='/home/public/scripts/xpool_trident/prd/xpool release '
_dellclusterlease ()
{
    local lease_time=${1:-7d};
    local cluster=${2};

    if [ -z ${cluster} ] ; then
        echo "usage $FUNCNAME <lease time> <cluster>";
        return;
    fi;

    /home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster};
}

dellclusterlease-update-user ()
{
    local cluster=${1};
    local user=${1:-labmaintenance};

    if [[ -z ${cluster} ]] ; then
        echo "you must specify a cluster";
        return -1;
    fi;

    echo "/home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster}";
    ask_user_default_yes "continue ?";
    [ $? -eq 0 ] && return;

    /home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster};
}

alias dellclusterleasewithforce='/home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen '
alias dellclusterlease='_dellclusterlease 3d';
alias dellclusterleaseshared='_dellclusterlease 72h'

dellclusterruntimeenvbkpfile=~/.dellclusterruntimeenvbkpfile
# _dellclusterleaseshared ()
# {
    # local cluster=${1};
    # if [ -z ${cluster} ] ; then
        # echo -e "you did not specify cluster, leasing free one from shared group";
        # /home/public/scripts/xpool_trident/prd/xpool lease 72 -g Core-Dev-Shared;
        # return;
    # fi;

    # /home/public/scripts/xpool_trident/prd/xpool lease 72 -c ${cluster};
# }

#
# 0 - runtimeenv faulty
# 1 - runtimeenv ok
_dellclusterruntimeenvvalidate ()
{
    if [[ -z ${CYC_CONFIG} ]] ; then
        echo -e "\033[1;31mCYC_CONFIG not set\033[0m";
        return 0;
    fi;

    if ! [ -e ${CYC_CONFIG} ] ; then
        echo -e "\033[1;31m ${CYC_CONFIG} does not exist\033[0m";
        echo -e "use dellclustergeneratecfg ${YONI_CLUSTER} in yonivm";
        return 0;
    fi;

    return 1;
}

dellclusterruntimeenvget ()  
{ 
    local last_used_cluster=;
    
    if [[ -z ${YONI_CLUSTER} ]] ; then
        if [[ -e ${dellclusterruntimeenvbkpfile} ]] ; then
            last_used_cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ${dellclusterruntimeenvbkpfile});
        fi;
        
        echo -e "\033[1;31mYONI_CLUSTER not set\033[0m";
        if [[ -n ${last_used_cluster} ]] ; then
            echo -e "last used cluster : \033[1;32m${last_used_cluster}\033[0m";
        fi;
    fi;
     
    _dellclusterruntimeenvvalidate ;

    echo -e "\033[1;31mYONI_CLUSTER\033[0m\t\t\033[1;32m$YONI_CLUSTER\033[0m"
	print_underline_size "_" 80	 
    echo -e "\033[1;31mcyclone_folder\033[0m\t\t${cyclone_folder}";
    echo -e "\033[1;31mCYC_CONFIG\033[0m\t\t${CYC_CONFIG}"
    echo -e "\033[1;31mcyc_helpers_folder\033[0m\t${cyc_helpers_folder}";
    echo -e "\033[1;31mthird_party_folder\033[0m\t${third_party_folder}";
    echo -e "\033[1;31mpnvmet_folder\033[0m\t\t${pnvmet_folder}";
	print_underline_size "_" 80	 
    echo;
}

dellenvrebash ()
{
    local cluster=;

    if [[ "cyclone" != "$(basename $(git remote get-url origin 2>/dev/null) .git)" ]] ; then
        echo -e "${RED}you should do this from a cyclone pdr repo${NC}";
        return -1;
    fi;

    # this block assumes that you can run this from any folder 
    # and that cluster runtime env is set.
    # 
	# dellcdcyclonefolder;
	# [[ $? -ne 0 ]] && return -1;

    # dellclusterruntimeenvget | tee cluster_runtime_env.txt;
    # r;
    # cluster=$(awk '/YONI_CLUSTER/{print $2}' cluster_runtime_env.txt);
    # cd - ;

    if ! [[ -e ${dellclusterruntimeenvbkpfile} ]] ; then
        echo "${dellclusterruntimeenvbkpfile} not found! bailing out";
        return -1;
    fi;

    cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ${dellclusterruntimeenvbkpfile});
    dellclusterruntimeenvset ${cluster};

}
alias rd='dellenvrebash'

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

    if ! [ -z ${cluster} ] ;then
        if ! [[ " ${cluster} " =~ " ${trident_cluster_list[@]} " ]] ; then
            echo "new ${cluster} ?"
            # ask_user_default_no "add ${cluster} to list";
            # if [[ $? -eq 0 ]] ; then
            # echo "finished here";
            # return 0;
            # else
            # echo "!!tbd!! : add cluster to list"
            # fi;
        fi;
    fi;

    # user should give cluster parameter. in case he did not
    # use the default from YONI_CLUSTER
    if [[ -z ${cluster} ]] ; then 
        if [[ -e ${dellclusterruntimeenvbkpfile} ]] ; then
            last_used_cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ${dellclusterruntimeenvbkpfile});
            ask_user_default_yes "you did not specify <cluster> use ? ${last_used_cluster}";
            if [[ $? -eq 0 ]] ; then
                cluster="$(printf "%s\n" ${trident_cluster_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
                # cluster="$(printf "%s\n" ${!dell_cluster_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
                if [ -z ${cluster} ] ; then
                    echo "usage : dellclusterruntimeenvset <cluster name>";
                    return -1;
                fi;
            else
                cluster=${last_used_cluster};
            fi;
        fi;
    fi;

    if [[ "cyclone" != "$(basename $(git remote get-url origin 2>/dev/null) .git)" ]] ; then
        echo -e "${RED}you should do this from a cyclone pdr repo${NC}";
        return -1;
    fi;

    if ! [[ -d source/cyc_core/cyc_platform/src/package/cyc_configs ]] ; then
        echo "source/cyc_core/cyc_platform/src/package/cyc_configs not found!!"
        return;
    fi;

    cluster=$(echo ${cluster} | awk '{print toupper($0)}');

    cyclone_folder=$(pwd -P);
    cyc_configs_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_configs);
    cyc_helpers_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_helpers);
    cluster_config_file=${cyc_configs_folder}/cyc-cfg.txt.${cluster}-BM;
    third_party_folder=$(readlink -f source/third_party/cyc_platform/src/third_party/PNVMeT);
    dell_kernel_objects=$(readlink -f source/cyc_core/cyc_platform/obj_Release/third_party/PNVMeT/src/PNVMeT)

    echo "export CYC_CONFIG=${cluster_config_file}";
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return;
    
    export CYC_CONFIG=${cluster_config_file};
    export YONI_CLUSTER=${cluster};

    _dellclusterruntimeenvvalidate;
    if [[ $? -eq 0 ]] ; then
        echo "!!! failed to set runtimeenv !!!";
        return 1;
    fi;

    echo "export CYC_CONFIG=${CYC_CONFIG}" > ${dellclusterruntimeenvbkpfile};
    echo "export YONI_CLUSTER=${cluster}"  >> ${dellclusterruntimeenvbkpfile};

    # dellclusterlistaddcluster ${YONI_CLUSTER};
    dellclusterruntimeenvget;
}

dellclusterleaseextend () 
{
    local cluster=${1};
    local extend=${2:-14d};

    if [[ -z ${cluster} ]] ; then 
        cluster=${YONI_CLUSTER};
    fi;

    if [[ -z ${cluster} ]] ; then 
        echo "no cluster name given";
        return -1;
    fi;

    echo "/home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend}"
    /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend};

}

# complete -W "$(echo ${trident_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaserelease dellclusterdeploy dellclusterleasewithforce
# complete -W "$(echo ${trident_cluster_list_nodes[@]})" xxssh xxbsc dellclusterguiipget dellclusterinfo dellclusterlease dellclusterleaseextend 

# complete -W "$(echo ${!dell_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaserelease dellclusterdeploy dellclusterleasewithforce xxssh xxbsc dellclusterguiipget dellclusterinfo dellclusterlease dellclusterleaseextend 

ssh2arwen ()
{
    /bin/ssh -t arwen3 "cd $(pwd) ; exec \$SHELL -l";
    # /bin/ssh -t arwen3 "cd $(pwd) ; bash --login";
}

ssh2core ()
{
    local cluster=${1};

    if [[ -z ${cluster} ]] ; then
        if [[ -n "${YONI_CLUSTER}" ]] ; then
            ask_user_default_yes "cluster not specified. would you like to use ${YONI_CLUSTER} ? "
            if [[ 1 == $? ]] ; then
                cluster=${YONI_CLUSTER};
            fi;
        fi;
    fi;
    
    if [[ -z ${cluster} ]] ; then
        cluster="$(printf "%s\n" ${trident_cluster_list_nodes[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    fi;

    if [[ -z ${cluster} ]] ; then
        echo "you must specify a cluster";
        return -1;
    fi;

    echo "xxssh ${cluster}";
    xxssh ${cluster};
}

ssh2bsc ()
{
    local cluster=${1};

    if [[ -z ${cluster} ]] ; then
        if [[ -n "${YONI_CLUSTER}" ]] ; then
            ask_user_default_yes "cluster not specified. would you like to use ${YONI_CLUSTER} ? ";
            if [[ 1 == $? ]] ; then
                cluster=${YONI_CLUSTER};
            fi;
        fi;
    fi;

    if [[ -z ${cluster} ]] ; then
        cluster="$(printf "%s\n" ${trident_cluster_list_nodes[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    fi;

    if [[ -z ${cluster} ]] ; then
        echo "you must specify a cluster";
        return -1;
    fi;

    echo "xxbsc ${cluster}";
    xxbsc ${cluster};
}

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

_usage_dellclusterinstallibid ()
{
    echo "usage: dellclusterinstallibid <ibid> <cluster>";
}

# there are 2 optional commands to install ibid 
# using xpool : /home/public/scripts/xpool_trident/prd/xpool
# using /home/public/devutils/bin/autoInstall.pl
# e.g. 
#   /home/public/devutils/bin/autoInstall.pl -swarm WX-G4067 -type san -ibid 1916979 -flavor retail -dare -syncFirmware -provisionSRS -fetchSRS -skipFwCheck --verbose
dellclusterinstallibid ()
{
    local ibid=${1};
    local cluster=${2};
    local xpool_cmd=/home/public/scripts/xpool_trident/prd/xpool
   
    if [[ -z ${ibid} ]] ; then
        _usage_dellclusterinstallibid;
        return -1;
    fi;
   
    if [[ -z ${cluster} ]] ; then
        _usage_dellclusterinstallibid;
        return -1;
    fi;

    xpool_cmd=$(echo -e "${xpool_cmd} install ${cluster} --flavor RETAIL -u y_cohen --deploy --deploy_type san -t 1 --deployflags=\"-setupMgmtPostFailure -syncFirmware -mode block \" --ibid ${ibid}");
    
    echo ${xpool_cmd};

    ask_user_default_yes "continue ?";
    if [ $? -eq 0 ] ; then
        echo "Bye..";
        return -1;
    fi;

    eval ${xpool_cmd};
    
    # eval ${xpool_cmd} install ${cluster} --flavor RETAIL -u y_cohen --deploy --deploy_type san -t 1 --deployflags="-setupMgmtPostFailure -syncFirmware -mode block " --ibid ${ibid} ;
    return 0;
}

dellclusterinstall ()
{
    local cluster=${1};
    local asked_user=0;
    local ret=1;

    if [ -z "${cluster}" ] ; then 
        if [ -n "${YONI_CLUSTER}" ] ; then
            echo -e "\033[1;31mYou did not specify <cluster>\033[0m";
            ask_user_default_yes "deploy to ${YONI_CLUSTER} ? "
            if [ $? -eq 1 ] ; then 
                cluster=${YONI_CLUSTER};
            else
                echo "usage dellclusterdeploy <cluster name>"; return;
            fi;
            asked_user=1;
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
    
    # if [[ ${asked_user} -eq 0 ]] ; then
        # echo "install ${cluster} with ${CYC_CONFIG}"
        # ask_user_default_yes "Continue ? ";
        # [ $? -eq 0 ] && return; 
    # fi;

    echo -e "\nAbout to install cluster ${cluster}\n";
    dellclusterruntimeenvget;
    ask_user_default_yes "Continue ? ";
    [ $? -eq 0 ] && return; 
    
    dellcdclusterscripts;

    #############################################
    #            deploy
    #############################################
    echo "==> $(pwd)";
    echo -e "\n./deploy  --deploytype san ${cluster}"; 
    ask_user_default_yes "Skip  deploy ? "
    if [[ $? -eq 0 ]] ; then
        time ./deploy  --deploytype san ${cluster}; 
        if [[ $? -ne 0 ]] ; then 
            while (( 1 == $(ask_user_default_yes "retry deploy ? " ; echo $?) )) ; do
                time ./deploy  --deploytype san ${cluster}; 
                ret=$?
                [ ${ret} -ne 0 ] && continue;
            done;

            if [[ ${ret} -ne 0 ]] ; then
                echo "";
                echo -e "\033[0;31m\t\tdeploy failed ! ! !\033[0m";
                return;
            fi;
        fi;
        echo -e "\033[0;32mdeploy succeeded\033[0m";
    fi;

    #############################################
    #            reinit
    #############################################
    echo -e "\n\n./reinit_array.sh -F Retail factory sys_mode=block\n\n";
    ask_user_default_no "Skip reinit ? "
    if [[ $? -eq 0 ]] ; then
        time ./reinit_array.sh -F Retail factory sys_mode=block;
        ret=$?;
        if [[ ${ret} -ne 0 ]] ; then 
            echo -e "\033[0;31m\t\treinit failed ! ! !\033[0m";
            while (( 1 == $(ask_user_default_yes "retry reinit ? " ; echo $?) )) ; do
                time ./reinit_array.sh -F Retail factory sys_mode=block;
                ret=$?
                if [ ${ret} -ne 0 ] ; then
                    echo -e "\033[0;31m\t\treinit failed ! ! !\033[0m";
                    continue;
                fi;
            done;

            if [[ ${ret} -ne 0 ]] ; then 
                echo -e "\033[0;31m\t\treinit failed ! ! !\033[0m";
                return -1;
            fi;
        fi;
        echo -e "\033[0;32m\t\treinit succeeded\033[0m";
    fi;

    #############################################
    #            create_cluster
    #############################################
    echo -e "\n\n./create_cluster.py -sys ${cluster}-BM -stdout -y -post\n\n";
    ask_user_default_no "Skip create_cluster ? "
    [ $? -eq 1 ] && return;
    time ./create_cluster.py -sys ${cluster}-BM -stdout -y -post

    if [[ $? -ne 0 ]] ; then 
        ret=-1;
        echo -e "\033[0;31m\t\tcreate_cluster failed ! ! !\033[0m";
        while (( 1 == $(ask_user_default_yes "retry create_cluster.sh ? " ; echo $?) )) ; do
            echo -e "\n\n./create_cluster.py -sys ${cluster}-BM -stdout -y -post\n\n";
            time ./create_cluster.py -sys ${cluster}-BM -stdout -y -post
            ret=$?
            echo "ret=${ret}";
            if [[ ${ret} -ne 0 ]] ; then
                echo -e "\033[0;31m\t\tcreate_cluster failed ! ! !\033[0m ret=${ret}";
                continue;
            fi;
        done;

        if [[ ${ret} -ne 0 ]] ; then
            echo -e "\033[0;31m\t\tcreate_cluster failed ! ! !\033[0m ret=${ret}";
            return -1;
        fi;
    fi;

    echo -e "\033[0;32m\t\tGreat success\033[0m (ret=${ret})";
    return 0;
}

logged_to_arwen ()
{
    if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
        echo "you must be in arwen";
        return 0;
    fi;
    return 1
}

dellclusteruserspaceupdate ()
{
    local cyc_core_folder=;

    logged_to_arwen;
    [[ $? -eq 0 ]] && retrun -1;

	if [ -z $CYC_CONFIG ] ; then
		echo "CYC_CONFIG not defined. use dellclusterenvsetup";
		return -1;
	fi

    cyc_core_folder=${cyclone_folder}/source/cyc_core;
    if ! [[ -e ${cyc_core_folder} ]] ; then
        echo "${cyc_core_folder} !! does not exist";
        return -1;
    fi;

	echo "CYC_CONFIG=$CYC_CONFIG";
	ask_user_default_yes "continue ?";
	[ $? -eq 0 ] && return 1;
	
    echo "about to copy nt-nvmeof-frontend to node-a";
	echo "./fast_code_loader.sh 10 -o -w ${cyc_core_folder}";
	ask_user_default_yes "continue ?"
	[ $? -eq 0 ] && return 1;

	dellcdclusterscripts;
	if ! [ -e fast_code_loader.sh ] ; then
		echo "fast_code_loader.sh !!! script not found";
        dellcdcyclonefolder;
		return -1;
	fi

	time ./fast_code_loader.sh 10 -o -w ${cyc_core_folder};
	
    echo "about to copy nt-nvmeof-frontend to node-b";
	echo "./fast_code_loader.sh 11 -o -w ${cyc_core_folder}";
	ask_user_default_yes "continue ?"
	if [ $? -eq 0 ] ; then
        dellcdcyclonefolder;
        return 0;
    fi;

	time ./fast_code_loader.sh 11 -o -w ${cyc_core_folder};
    dellcdcyclonefolder;

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
	if [ -z $CYC_CONFIG ] ; then
		echo "CYC_CONFIG not defined. use dellclusterruntimeenvset";
		return -1;
	fi

	ask_user_default_yes "update ${YONI_CLUSTER} ?";
	[ $? -eq 0 ] && return -1;

	dellcdclusterscripts;
	
	# script is in repo:cyc_core, in branch:dev/grupie/fast_loader_for_nvmet_driver
	# if ! [ -e fast_nvmet_driver_loader.sh ] ; then
		# echo "git checkoutfilefrombranch remotes/origin/dev/grupie/fast_loader_for_nvmet_driver cyc_platform/src/package/cyc_helpers/fast_nvmet_driver_loader.sh";
		# git checkoutfilefrombranch remotes/origin/dev/grupie/fast_loader_for_nvmet_driver cyc_platform/src/package/cyc_helpers/fast_nvmet_driver_loader.sh
		# if ! [ -e fast_nvmet_driver_loader.sh ] ; then
			# echo "fast_nvmet_driver_loader.sh not found"
			# return -1;
		# fi;
	# fi

    /bin/cp ${yonienv}/scripts/fast_nvmet_driver_loader.sh .;
    time ./fast_nvmet_driver_loader.sh;

	return 0;
}

dellclusteryonienvupdate ()
{
	if [ -z $CYC_CONFIG ] ; then
		echo "CYC_CONFIG not defined. use dellclusterruntimeenvset";
		return -1;
	fi

	if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
		echo "you must be in arwen";
		return;
	fi;

	ask_user_default_yes "update ${YONI_CLUSTER} ?";
	[ $? -eq 0 ] && return -1;

	dellcdclusterscripts;

    sed -i "1s/YONI_CLUSTER=.*/YONI_CLUSTER=${YONI_CLUSTER}/" ~/yonienv/scripts/yonidell.sh;

    echo "copy yonidell.sh -> core-a@${YONI_CLUSTER}";
    ./scp_core_to_a.sh ~/yonienv/scripts/yonidell.sh
    echo "copy vimrcyoni.sh -> core-a@${YONI_CLUSTER}";
    ./scp_core_to_a.sh ~/yonienv/scripts/vimrcyoni.vim
    echo "copy yonidell.sh -> core-b@${YONI_CLUSTER}";
    ./scp_core_to_b.sh ~/yonienv/scripts/yonidell.sh
    echo "copy vimrcyoni.vim -> core-b@${YONI_CLUSTER}";
    ./scp_core_to_b.sh ~/yonienv/scripts/vimrcyoni.vim

    echo "copy yonidell.sh -> bsc-a@${YONI_CLUSTER}";
    ./scp_cyc_to_a.sh ~/yonienv/scripts/yonidell.sh;
    # ./run_core_a.sh 'docker cp yonidell.sh   cyc_bsc_docker:/home/cyc/';
    echo "copy vimrcyoni.vim -> bsc-a@${YONI_CLUSTER}";
    ./scp_cyc_to_a.sh ~/yonienv/scripts/vimrcyoni.vim;
    # ./run_core_a.sh 'docker cp vimrcyoni.vim cyc_bsc_docker:/home/cyc/';
    echo "copy yonidell.sh -> bsc-b@${YONI_CLUSTER}";
    ./scp_cyc_to_b.sh ~/yonienv/scripts/yonidell.sh;
    # ./run_core_b.sh 'docker cp yonidell.sh   cyc_bsc_docker:/home/cyc/';
    echo "copy vimrcyoni.vim -> bsc-b@${YONI_CLUSTER}";
    ./scp_cyc_to_b.sh ~/yonienv/scripts/vimrcyoni.vim;
    # ./run_core_b.sh 'docker cp vimrcyoni.vim cyc_bsc_docker:/home/cyc/';

    sed -i "1s/YONI_CLUSTER=.*/YONI_CLUSTER=/" ~/yonienv/scripts/yonidell.sh;
    cd -
}

# dellclusterkernelspaceupdate-fzf ()
# {
#     local cluster=${1};

#     if [ -z ${cluster} ] ; then
#         if [ -n ${YONI_CLUSTER} ] ; then
#             ask_user_default_yes "use ${YONI_CLUSTER} ? ";
#             if [[ $? -eq 0 ]] ; then
#                 cluster="$(printf "%s\n" ${trident_cluster_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
#             else
#                 cluster=${YONI_CLUSTER};
#             fi;
#         fi;
#     fi;

#     # echo ${trident_cluster_list[@]}
#     echo "cluster : ${cluster}";
#     if [ -z ${cluster} ] ; then
#         echo "you must specify a cluster";
#         return -1;
#     fi;

#     dellclusterkernelspaceupdate ${cluster};
# }

ssh2lg ()
{
    local lg_name=${1};

    if [[ -z ${lg_name} ]]; then 
        lg_name="$(printf "%s\n" ${lg_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    fi;

    if [[ -z ${lg_name} ]]; then 
        echo "missing LG_NAME param" 
        return -1;
    fi;

    ask_user_default_yes "ssh2lg ${lg_name} ? ";
    if [[ $? -eq 0 ]] ; then return 0 ; fi;

    sshpass -p Password123! ssh -o 'PubkeyAuthentication no' -o LogLevel=ERROR -F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  root@${lg_name};
}

lg_list=(nc9121236 nc9121238 nc9122231 host-g0359 host-g0360 nc5135221 nc5135223 host-g0199 nc5199007 nc5199009 nc5203051 nc9127122 nc9123070 nc9144126 nc9127152 hop240085038);
complete -W "$(echo ${lg_list[@]})" ssh2lg;

dellclusterlgipget ()
{
    local cluster=${1};
    xxlabjungle cluster "name:${cluster}" |  jq -r '.objects[0].lgs[0]'
}

dellclusterguiipget ()
{
    local cluster=${1};
    # local config_file_folder=/home/y_cohen/devel/cyclone/source/cyc_core/cyc_platform/src/package/cyc_configs;
    local config_file_folder=${cyc_configs_folder};
    local config_file_prefix="cyc-cfg.txt.";
    local config_file_postfix="-BM";
    local config_file=;

    if [[ -z ${cluster} ]] ; then
        echo "missing cluster";
        return -1;
    fi
     
    cluster=$(echo ${cluster} | awk '{print toupper($0)}');

    config_file=${config_file_folder}/${config_file_prefix}${cluster}${config_file_postfix};

    if [[ -e ${config_file} ]] ; then
        echo "grep cluster_ip ${config_file}";
        grep cluster_ip ${config_file};
    else
        echo "not found : ${config_file}";
    fi

	if ! [ -e /home/public/devutils/bin/swarm ] ; then 
		echo "/home/public/devutils/bin/swarm not found";
		return;
	fi;

    ask_user_default_no "user swarm to list all IPs ?";
    if [[ $? -eq 0 ]] ; then
        return;
    fi;

    print_underline_size "_" 80	 
    echo "/home/public/devutils/bin/swarm -ping -showall ${cluster}";
    print_underline_size "_" 80	 
    /home/public/devutils/bin/swarm -ping -showall ${cluster};

}

dellclusterinfo ()
{
    local cluster=${1};

	if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
		echo "you must be in arwen";
		return;
	fi;

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
    else
        print_underline_size "_" 80	 
        echo "/home/public/devutils/bin/swarm -ping ${cluster}";
        print_underline_size "_" 80	 
        /home/public/devutils/bin/swarm -ping ${cluster};
        print_underline_size "_" 80	 
        echo "/home/public/scripts/xpool_trident/prd/xpool list -f -a -c ${cluster}";
        /home/public/scripts/xpool_trident/prd/xpool list -f -a -c ${cluster};
        return 0;
	fi;

	print_underline_size "_" 80	 
	echo "/home/public/scripts/xpool_trident/prd/xpool list -f"
	print_underline_size "_" 80	 
	/home/public/scripts/xpool_trident/prd/xpool list -f

	return 0;
}

third_party_folder=
dellcdthirdparty ()
{
    if [[ -z ${cyclone_folder} ]] ; then
        echo "cyclone_folder not set. use dellclusterruntimeenvset <cluster>"
        return -1;
    fi;

    if [[ -z ${third_party_folder} ]] ; then
        echo "third_party_folder not set. use dellclusterruntimeenvset <cluster>"
        return -1;
    fi;

    if ! [[ -e ${third_party_folder} ]] ; then
        echo "${third_party_folder} does not exist";
        return -1;
    fi;

    cd $third_party_folder;
    return 0;
}

dell_kernel_objects=
dellcdkernelobjects ()
{
    if [[ -z ${cyclone_folder} ]] ; then
        echo "cyclone_folder not set. use dellclusterruntimeenvset <cluster>"
        return -1;
    fi;

    if [[ -z ${dell_kernel_objects} ]] ; then
        echo "dell_kernel_objects not set. use dellclusterruntimeenvset <cluster>"
        return -1;
    fi;

    if ! [[ -e ${dell_kernel_objects} ]] ; then
        echo "${dell_kernel_objects} does not exist";
        return -1;
    fi;

    cd $dell_kernel_objects;
    return 0;
    

    /devel/cyclone/source/cyc_core/cyc_platform/obj_Release/third_party/PNVMeT/src/PNVMeT
    /devel/cyclone/source/cyc_core/cyc_platform/obj_Release/third_party/PNVMeT/src/PNVMeT
}

dellcyclonekernelshaget ()
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
export pnvmet_folder=;
dellcdpnvmetfolder ()
{
    if [[ -z ${pnvmet_folder} ]] ; then
        echo "pnvmet_folder not set, (use dellcyclonekernelshaupdate)";
        return -1;
    fi;

    cd ${pnvmet_folder};
}

dellcyclonekernelshaupdate ()
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
    
        if [[ 0 -eq $(git s | grep "up to date" | wc -l) ]] ; then
            echo "your branch is out of sync or not tracking upstream. you probably forgot to push upstream";
            ask_user_default_no "continue ?";
            [ $? -eq 0 ] && return -1;
        fi;

        print_underline_size "_" 80;
        sha=$(git log -1 | awk '/commit/{print $2}');
        echo -e "you did not supply commit sha. using HEAD \033[1;35m${sha}\033[0m";
        dellcyclonebuildhistorylog $(pwd) $(git bb) $(git h);
        export pnvmet_folder=$(pwd);
    fi
    
    sed -i "s/\(Set.*PNVMET_GIT_TAG.*\"\).*\(\".*\)/\1${sha}\2/g" $mfile;
    dellcdthirdparty;
    print_underline_size "_" 80;
    git diff -U1;
    cd -;
    
    # depict the kernel that was used.
    # the folder from which it was built the branch name and the index
    # print these when user invokes dellclusterruntimeenvget
}

dellibid2commit ()
{
    local ibid=$1;
    phlibid.pl --ibid ${ibid};
    echo ===============================================================
    # phlibid.pl --ibid ${ibid} | grep --color -i commit
    phlibid --getCommit --ibid ${ibid} | grep "Commit ID\|nt-nvmeof"

}

_dellrebootnode ()
{
    node=${1:-a};
    dellcdclusterscripts;
    if [[ -e run_ipmi_${node}.sh ]] ; then
        ask_user_default_no "reboot node ${node}";
        [[ $? -eq 0 ]] && return;
        echo "./run_ipmi_${node}.sh chassis power cycle";
       ./run_ipmi_${node}.sh chassis power cycle;
    fi;
}

alias dellrebootnode-a="_dellrebootnode a";
alias dellrebootnode-b="_dellrebootnode b";

gitcommitdell ()
{
    local jira_ticket=${1};
    local module=${2:-nt};
     
    if [[ $# -ne 2 ]] ; then
        echo "usage: $FUNCNAME <jira ticket> <module>"
        return -1;
    fi;
 
    if [ -n "${jira_ticket}" ] ; then 
        sed -i "s/\[MDT-.*\]/\[MDT-${jira_ticket}\]/g" ${yonienv}/git_templates/git_commit_dell_template;
    fi

    if [ -n "${module}" ] ; then 
        sed -i "s/cyc_module/${module}/g" ${yonienv}/git_templates/git_commit_dell_template;
    fi

    git config commit.template ${yonienv}/git_templates/git_commit_dell_template;
    git commit -n;
    git config --unset commit.template;
    pushd ${yonienv} 2>/dev/null;
    git checkout ${yonienv}/git_templates/git_commit_dell_template;
    popd 2>/dev/null;
}

complete -W "67933 rdma" gitcommitdell


delljournalctl-nt-logs-node-a ()
{
    local since="${1}";
    local options="--utc SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_a/var/log/journal";

    if [[ -n "${since}" ]] ; then
        eval journalctl --since=\"${since}\" ${options} | less -N -I
    else
        eval journalctl ${options}  | less -N -I
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
        eval journalctl --since=\"${since}\" ${options} | less -N -I
    else
        eval journalctl ${options} | less -N -I
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

alias delltriage-all-logs-node-a="./cyc_triage.pl -b . -n a -j"
alias delltriage-all-logs-node-b="./cyc_triage.pl -b . -n b -j"
alias delltriage-nt-logs-node-a="./cyc_triage.pl -b . -n a -j SUB_COMPONENT=nt"
alias delltriage-nt-logs-node-b="./cyc_triage.pl -b . -n b -j SUB_COMPONENT=nt"

# howto
# journalctl SUBCOMPONENT=nt
# journalctl -o short-precise --since "2022-07-04 07:56:00"
