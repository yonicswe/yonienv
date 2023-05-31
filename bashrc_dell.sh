#!/bin/bash

alias editbashdell='v ${yonienv}/bashrc_dell.sh'
alias ssh2amitvm='echo cycpass; ssh cyc@10.207.202.38'
alias ssh2eladvm='echo cycpass; ssh cyc@10.227.204.131'
# yonivmipaddress="10.244.196.235"
yonivmipaddress="10.227.212.155"
alias ssh2yonivm="sshpass -p cycpass ssh cyc@${yonivmipaddress}"
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


yonivm-update-yonienv ()
{
    cd;
    rsync -av --progress -R -e ssh yonienv/ cyc@${yonivmipaddress}:/home/cyc
    cd -
}

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

_dellclusterlistaddcluster ()
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
    local pdr_folder_name=${1:-cyclone};

	git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git ${pdr_folder_name};
	cd ${pdr_folder_name};
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

dellpdr-reset ()
{ 
    echo "git fetch"; git fetch;
    echo "git reset HEAD"; git reset HEAD;
    echo "git c ."; git c .;
}

dellpdr-gitsmup ()
{
    local cyc_core=0;
    local nt_nvmeof_frontend=0;
    local linux=0;
    local third_party=0;

    ask_user_default_no "are you in a pdr ? ";
    if [ $? -eq 0 ] ; then
        echo "bailing out";
        return;
    fi;

    ask_user_default_no "reset the pdr before we start ? ";
    [ $? -eq 1 ] && dellpdr-reset;

    #--------------------------------------
    #            ask user
    #--------------------------------------
    ask_user_default_yes "update source/cyc_core ?";
    [ $? -eq 1 ] && cyc_core=1;

    ask_user_default_yes "update source/nt-nvmeof-frontend ?";
    [ $? -eq 1 ] && nt_nvmeof_frontend=1;

    ask_user_default_yes "update source/linux ?";
    [ $? -eq 1 ] && linux=1;

    ask_user_default_yes "update source/third_party ?";
    [ $? -eq 1 ] && third_party=1;

    #--------------------------------------
    #            do it
    #--------------------------------------
    if (( ${cyc_core} == 1           )) ; then echo "-->update cyc_core";           git smupdate source/cyc_core           ; fi;
    if (( ${nt_nvmeof_frontend} == 1 )) ; then echo "-->update nt-nvmeof-frontend"; git smupdate source/nt-nvmeof-frontend ; fi;
    if (( ${linux} == 1              )) ; then echo "-->update linux";              git smupdate source/linux              ; fi;
    if (( ${third_party} == 1        )) ; then echo "-->update third_party";        git smupdate source/third_party        ; fi;

    #--------------------------------------
    #            verify
    #--------------------------------------
    echo "git status";
    git s;
    # if (( ${cyc_core} == 1           )) ; then git sm status source/cyc_core           ; fi;
    # if (( ${nt_nvmeof_frontend} == 1 )) ; then git sm status source/nt-nvmeof-frontend ; fi;
    # if (( ${linux} == 1              )) ; then git sm status source/linux              ; fi;
    # if (( ${third_party} == 1        )) ; then git sm status source/third_party        ; fi;


    # git sm update source/bedrock
    # git sm update source/cdre
    # git sm update source/centos
    # git sm update source/controlpath_ui
    # git sm update source/cyc_coreos
    # git sm update source/cyc_crypto
    # git sm update source/cyc_dp_protobuf
    # git sm update source/cyc_install_tools
    # git sm update source/cyclone-controlpath
    # git sm update source/cyclone-features
    # git sm update source/cyclone-image
    # git sm update source/cyc_net_protobuf
    # git sm update source/devops-scripts
    # git sm update source/docker-images
    # git sm update source/event-generator
    # git sm update source/feature-framework
    # git sm update source/indus
    # git sm update source/integration-testing
    # git sm update source/ntrdma
    # git sm update source/pycyc-test-framework-docker
    # git sm update source/rpm_infra
    # git sm update source/sdnas-int-tests
    # git sm update source/serviceability-tools
    # git sm update source/stack
    # git sm update source/trident-glider
    # git sm update source/trident-sdnas
    # git sm update source/xblock
}

dellcyclonegitdeinit ()
{
    git sm deinit -f source/bedrock
    git sm deinit -f source/cdre
    git sm deinit -f source/centos
    git sm deinit -f source/controlpath_ui
    # git sm deinit -f source/cyc_core
    git sm deinit -f source/cyc_coreos
    git sm deinit -f source/cyc_crypto
    git sm deinit -f source/cyc_dp_protobuf
    git sm deinit -f source/cyc_install_tools
    git sm deinit -f source/cyclone-controlpath
    git sm deinit -f source/cyclone-features
    git sm deinit -f source/cyclone-image
    git sm deinit -f source/cyc_net_protobuf
    git sm deinit -f source/devops-scripts
    git sm deinit -f source/docker-images
    git sm deinit -f source/event-generator
    git sm deinit -f source/feature-framework
    git sm deinit -f source/indus
    git sm deinit -f source/integration-testing
    # git sm deinit -f source/linux
    # git sm deinit -f source/nt-nvmeof-frontend
    git sm deinit -f source/ntrdma
    git sm deinit -f source/pycyc-test-framework-docker
    git sm deinit -f source/rpm_infra
    git sm deinit -f source/sdnas-int-tests
    git sm deinit -f source/serviceability-tools
    git sm deinit -f source/stack
    # git sm deinit -f source/third_party
    git sm deinit -f source/trident-glider
    git sm deinit -f source/trident-sdnas
    git sm deinit -f source/xblock
}

_dellcyclonebuild_validate_build_machine ()
{
    # ok to build in arwen machine
    if (( 0 !=  $(hostname|grep arwen|wc -l) )) ; then
        return 0;
    fi;

    # ok to build in dev-vm
    if (( 0 !=  $(hostname -i | grep ${yonivmipaddress}  | wc -l ) )) ; then
        return 0;
    fi;

    # cannot build on other manchines.
    return -1;
}

dellcyclonebuild ()
{
    local build_cmd='make cyc_core force=yes'

    _dellcyclonebuild_validate_build_machine
    if [[ $? -ne 0 ]] ; then
        echo "you must do this from arwen or dev-vm. bailing out!!!";
        return -1
    fi;
    
	dellcdcyclonefolder;
	[[ $? -ne 0 ]] && return -1;
	
    dellclusterruntimeenvget
    ask_user_default_yes "continue ?"
    [[ $? -eq 0 ]] && return -1;

    # dellcyclonebuildhistorylog;

    ask_user_default_no "flavor DEBUG ? ";
    if [[ $? -eq 0 ]] ; then
        build_cmd+=" flavor=RETAIL";
    else
        build_cmd+=" flavor=DEBUG";
    fi;

    ask_user_default_yes "use cached repos ? ";
    if [ $? -eq 0 ] ; then
        build_cmd+=" acache=no mcache=no dcache=no";
    fi;

    ask_user_default_no "verbose=3 ? ";
    if [ $? -eq 1 ] ; then
        build_cmd+=" verbose=3";
    fi;

	ask_user_default_no "prune before build ?"
	if [[ $? -eq 1 ]] ; then
	    build_cmd="make prune && ${build_cmd}";
	fi;

	echo -e "\n========== start build ($(pwd)) ===================\n";
	echo "${build_cmd}";
	echo "========================================================";
    ask_user_default_yes "continue ?";
    [ $? -eq 0 ] && return 0;

    build_cmd="time ${build_cmd}";
    eval ${build_cmd} | tee dellcyclonebuild.log
	echo -e "\n${build_cmd}\n";
    $(set -x; ls -ltr source/cyc_core/cyc_platform/obj_Release/main/xtremapp);
}

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

    ask_user_default_yes "open with vim ${list_file} ?";
    [ $? -eq 0 ] && return;
    (set -x ; mv /tmp/cluster-list-file.txt ${list_file});
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

dellclusterleaserelease ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo "/home/public/scripts/xpool_trident/prd/xpool release ${cluster}";
    ask_user_default_no "are you sure ? ";
    [[ $? -eq 0 ]] && return;

    /home/public/scripts/xpool_trident/prd/xpool release ${cluster};
}

_dellclusterlease ()
{
    local lease_time=${1:-7d};
    local cluster=${2};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo "/home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster}";
    /home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster};
    echo "/home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster}";
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
        return -1;
    fi;

    if ! [ -e ${CYC_CONFIG} ] ; then
        echo -e "\033[1;31m ${CYC_CONFIG} does not exist\033[0m";
        echo -e "use dellclustergeneratecfg ${YONI_CLUSTER} in yonivm";
        return -1;
    fi;

    return 0;
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
alias gd='dellclusterruntimeenvget'

dellenvrebash ()
{
    local cluster=;
    local pdr_folder=;

    # make sure were on a cyclone pdr folder
    # if [[ "cyclone" != "$(basename $(git remote get-url origin 2>/dev/null) .git)" ]] ; then
        # echo -e "${RED}you should do this from a cyclone pdr repo${NC}";
        # return -1;
    # fi;

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

    pdr_folder=$(awk -F '='  '/YONI_PDR/{print $2}' ${dellclusterruntimeenvbkpfile});
    if [[ -z ${pdr_folder} ]] ; then
        echo -e "${RED}last used pdr folder not saved${NC}";
        echo -e "${RED}you should do this from a cyclone pdr repo${NC}";
        return -1;
    fi;

    cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ${dellclusterruntimeenvbkpfile});
    if [[ -z ${cluster} ]] ; then
        echo -e "${RED}last used cluster not saved${NC}";
        return -1;
    fi;

    cd ${pdr_folder};
    dellclusterruntimeenvset ${cluster};

}
alias rd='dellenvrebash'

cyclone_folder=;
dellcdcyclonefolder ()
{
    local faults=0;

    if [[ -z ${cyclone_folder} ]] ; then
        # echo "cyclone_folder is not set"
        ((faults++));
    fi;

    if ! [[ -e ${cyclone_folder} ]] ; then
        # echo "cyclone_folder does not exist";
        ((faults++));
    fi;
     
    if [[ ${faults} -gt 0 ]] ; then
        if [[ $(file .git | grep "ASCII text" | wc -l) -gt 0 ]] ; then 
            # echo "going up from submodule to pdr";
            gitsmtop;
            return 0;
        fi;
        return -1;
    fi;

    cd ${cyclone_folder};
    return 0;
}
alias ddd='dellcdcyclonefolder'
export _dellclusterruntimeenvset=0
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
        return 1;
    fi;

    cluster=$(echo ${cluster} | awk '{print toupper($0)}');

    cyclone_folder=$(pwd -P);
    cyc_configs_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_configs);
    cyc_helpers_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_helpers);
    cluster_config_file=${cyc_configs_folder}/cyc-cfg.txt.${cluster}-BM;
    if ! [ -e source/third_party/cyc_platform/src/third_party/PNVMeT ] ; then
        echo -e "\n!! warning !! : no such folder : source/third_party/cyc_platform/src/third_party/PNVMeT\n";
    else
        third_party_folder=$(readlink -f source/third_party/cyc_platform/src/third_party/PNVMeT);
    fi;

    dell_kernel_objects=$(readlink -f source/cyc_core/cyc_platform/obj_Release/third_party/PNVMeT/src/PNVMeT)

    echo "export CYC_CONFIG=${cluster_config_file}";
    ask_user_default_yes "Correct ? "
    [ $? -eq 0 ] && return;
    
    export CYC_CONFIG=${cluster_config_file};
    export YONI_CLUSTER=${cluster};

    _dellclusterruntimeenvvalidate;
    if [[ $? -ne 0 ]] ; then
        ask_user_default_no "set it anyways ? ";
        if [ $? -eq 0 ] ; then
            echo "!!! failed to set runtimeenv !!!";
            return 1;
        fi;
    fi;

    echo "export CYC_CONFIG=${CYC_CONFIG}" > ${dellclusterruntimeenvbkpfile};
    echo "export YONI_CLUSTER=${cluster}"  >> ${dellclusterruntimeenvbkpfile};
    echo "export YONI_PDR=${cyclone_folder}"  >> ${dellclusterruntimeenvbkpfile};

    # _dellclusterlistaddcluster ${YONI_CLUSTER};
    dellclusterruntimeenvget;
    _dellclusterruntimeenvset=1;
}

complete -W "$(echo ${trident_cluster_list_nodes[@]})" dellclustergeneratecfg
dellclustergeneratecfg ()
{
    local cluster=${1};

    # if [ 0 -eq $(git remote -v | grep "cyclone\/cyc_core.git" | wc -l) ] ; then
        # echo "you must be in a cyc_core repo https://y_cohen@eos2git.cec.lab.emc.com/cyclone/cyc_core.git";
        # return -1;
    # fi;

    if [[ ${_dellclusterruntimeenvset} -eq 0 ]] ; then
        echo -e "${RED}runtimeenv is not set${NC}}"
        return -1;
    fi;

    # runtime is set, lets use it.
    ddd;

    if ! [ -d source/cyc_core ] ; then 
        echo -e "${RED}missing source/cyc_core folder${NC}";
        return -1;
    fi;

    cd source/cyc_core;
 
    if ! [[ -e cyc_platform/src/package/cyc_helpers/swarm-to-cfg-centos8.sh ]] ; then
        echo "missing cyc_platform/src/package/cyc_helpers/swarm-to-cfg-centos8.sh";
        return -1;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    cluster=$(echo ${cluster} | awk '{print toupper($0)}' )

    pushd cyc_platform/src/package/cyc_helpers > /dev/null;

    p;
    echo "./swarm-to-cfg-centos8.sh ${cluster}";
    ask_user_default_yes "continue ?"
    if [[ $? -eq 0 ]] ; then return ; fi;
    ./swarm-to-cfg-centos8.sh ${cluster};
     
    dellcdclusterconfigs;
    find -name "*${cluster}*" -exec readlink -f {} \;
    # ls *${cluster}* | while read c ; do readlink -f $c ; done;

    popd > /dev/null;

    return 0;
}


dellclusterleaseextend () 
{
    local extend=${1:-14d};
    local cluster=${2};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo -e "\t\t-> /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend}"
    /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend};

}

alias dellclusterleaseextendshared='dellclusterleaseextend 72h';

# complete -W "$(echo ${trident_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaserelease dellclusterdeploy dellclusterleasewithforce
# complete -W "$(echo ${trident_cluster_list_nodes[@]})" xxssh xxbsc dellclusterguiipget dellclusterinfo dellclusterlease dellclusterleaseextend 

# complete -W "$(echo ${!dell_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaserelease dellclusterdeploy dellclusterleasewithforce xxssh xxbsc dellclusterguiipget dellclusterinfo dellclusterlease dellclusterleaseextend 

ssh2arwen ()
{
    local arwen=${1:-arwen3};
    /bin/ssh -t ${arwen} "cd $(pwd) ; exec \$SHELL -l";
    # /bin/ssh -t arwen3 "cd $(pwd) ; bash --login";
}

alias ssh2arwen1='ssh2arwen arwen1'
alias ssh2arwen2='ssh2arwen arwen2'
alias ssh2arwen3='ssh2arwen arwen3'
alias ssh2arwen4='ssh2arwen arwen4'
alias ssh2arwen5='ssh2arwen arwen5'
alias ssh2arwen6='ssh2arwen arwen6'
alias ssh2arwen7='ssh2arwen arwen7'

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
# 1. with ibid
#    /home/public/devutils/bin/autoInstall.pl -swarm WX-G4067 -type san -ibid 1916979 -flavor retail -dare -syncFirmware -provisionSRS -fetchSRS -skipFwCheck --verbose
# 2. with feature flag and ibid
#    /home/public/devutils/bin/autoInstall.pl -swarm WK-D0677 -type san -ibid 1994402 -flavor retail -dare -syncFirmware -provisionSRS -fetchSRS -skipFwCheck --verbose -feature REFLAG_TRIF1721
dellclusterinstallibid-with-xpool ()
{
    local ibid=${1};
    local cluster=${2};
    local xpool_cmd=/home/public/scripts/xpool_trident/prd/xpool
   
    if [[ -z ${ibid} ]] ; then
        _usage_dellclusterinstallibid;
        return -1;
    fi;
   
    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    ask_user_default_no "would you like to also deploy ${cluster} ?";
    if [ $? -eq 1 ] ; then
        ask_user_default_no "are you sure ? (it could take a while) ";
        if [ $? -eq 1 ] ; then
            echo "about to (deploy + reinit_array + create_cluster) ${cluster}, with ibid ${ibid}";
            xpool_cmd=$(echo -e "${xpool_cmd} install ${cluster} --flavor RETAIL -u y_cohen --deploy --deploy_type san -t 1 --deployflags=\"-setupMgmtPostFailure -syncFirmware -mode block \" --ibid ${ibid}");
        fi;
    else
        echo "about to (reinit_array + create_cluster) ${cluster}, with ibid ${ibid}";
        xpool_cmd=$(echo -e "${xpool_cmd} install ${cluster} --flavor RETAIL -u y_cohen -t 2 --ibid ${ibid}");
    fi;
    
    echo ${xpool_cmd};

    ask_user_default_yes "continue ?";
    if [ $? -eq 0 ] ; then
        echo "Bye..";
        return -1;
    fi;

    eval ${xpool_cmd};
    
    return 0;
}

_usage_dellclusterinstallibid_with_autoinstall ()
{
    echo "dellclusterinstallibid-with-autoinstall <ibid> <cluster> [feature-flag]";
}

dellclusterinstallibid-with-autoinstall ()
{
    local ibid=${1};
    local cluster=${2};
    local feature_flag=;
    local autoinstall_cmd=/home/public/devutils/bin/autoInstall.pl
   
    if [[ -z ${ibid} ]] ; then
        echo "missing ibid !!"
        _usage_dellclusterinstallibid_with_autoinstall;
        return -1;
    fi;
   
    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    ask_user_default_no "would you like a feature flag ? ";
    if [ $? -eq 0 ] ; then
        autoinstall_cmd=$(echo -e "${autoinstall_cmd} -swarm ${cluster} -type san -flavor retail -ibid ${ibid} ");
    else
        read -p "enter feature : " feature_flag;
        autoinstall_cmd=$(echo -e "${autoinstall_cmd} -swarm ${cluster} -type san -flavor retail -ibid ${ibid} -feature ${feature_flag}");
    fi;
    
    echo ${autoinstall_cmd};

    ask_user_default_yes "continue ?";
    if [ $? -eq 0 ] ; then
        echo "Bye..";
        return -1;
    fi;

    eval ${autoinstall_cmd};
    
    return 0;
}

dellclusterinstallfeatureflag ()
{
    local feature=${1};
    if [ -z ${feature} ] ; then
        feature=$(dellcyclonefeatureflaglist);
    fi;

    # echo -e "./reinit_array.sh -F Retail factory sys_mode=block feature=\"REFLAG_TRIF1721\"";
    echo -e "./reinit_array.sh -F Retail factory sys_mode=block feature=\"${feature}\"";
}

dellcyclonefeatureflaglist ()
{
    local feature_list_file=configs/feature_flags_default.json
    local -a feature_flags=;
    local feature;

    if [[ -z ${CYC_CONFIG} ]] ; then
        echo "CYC_CONFIG not set. use dellclusterruntimeenvset <cluster>";
        return -1;
    fi;

    ddd; 

    # less ${feature_list_file};
    feature_flags=( $(awk '/name.*REFLAG_/{print $2}' ${feature_list_file}  | sed 's/\"//g' | sed 's/,//g') );
    feature="$(printf "%s\n" ${feature_flags[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
    echo ${feature};
}

_dellclusterget ()
{
    local cluster=${1};

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

    # help user get a cluster
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

    echo ${cluster};
    return 0;
}

dellclusterinstall ()
{
    local cluster=${1};
    local asked_user=0;
    local ret=1;
    local deploy_cmd=;
    local reinit_cmd=;
    local create_cluster_cmd=;
    local deploy_choice=0;
    local reinit_choice=0;
    local create_cluster_choice=0;
    local feature=;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    _dellclusterruntimeenvvalidate;
    if [[ $? -ne 0 ]] ; then
        return -1;
    fi;
    
    echo -e "\nAbout to install cluster ${cluster}\n";
    dellclusterruntimeenvget;
    ask_user_default_yes "Continue ? ";
    [ $? -eq 0 ] && return; 
    
    dellcdclusterscripts;

    deploy_cmd="./deploy  --deploytype san ${cluster}";
    reinit_cmd="./reinit_array.sh -F Retail factory sys_mode=block";
    create_cluster_cmd="./create_cluster.py -sys ${cluster}-BM -stdout -y -post";

    #
    # ask user to define commands and offer to do it all without stopping.
    #
    # echo -e "\n${deploy_cmd}";
    ask_user_default_yes "Skip  deploy ? "
    if [[ $? -eq 0 ]] ; then
        deploy_choice=1;
    else
        deploy_cmd="";
    fi;

    # echo -e "\n\n${reinit_cmd}\n\n";
    ask_user_default_no "Skip reinit ? "
    if [[ $? -eq 0 ]] ; then
        reinit_choice=1;

        ask_user_default_no "would you like to enable a feature flag ? ";
        if [ $? -eq 1 ] ; then
            feature=$(dellcyclonefeatureflaglist);
            reinit_cmd+=" feature=\"${feature}\"";
            echo -e "\n\n${reinit_cmd}\n\n";
        fi;
    else
        reinit_cmd="";
    fi;

    # echo -e "\n\n${create_cluster_cmd}\n\n";
    ask_user_default_no "Skip create_cluster ? "
    if [[ $? -eq 0 ]] ; then
        create_cluster_choice=1;
    else
        create_cluster_cmd="";
    fi;

    echo "$FUNCNAME +1186";
    # print the entire triplet commands and let the user decide to decide how to proceed.
    one_sweep_cmd=""
    if [ -n "${deploy_cmd}" ] ; then
        one_sweep_cmd+="${deploy_cmd}";
    fi;

    if [ -n "${reinit_cmd}" ] ; then
        [ -n "${one_sweep_cmd}" ] && one_sweep_cmd+=" && ";
        one_sweep_cmd+="${reinit_cmd}";
    fi;

    if [ -n "${create_cluster_cmd}" ] ; then
        [ -n "${one_sweep_cmd}" ] && one_sweep_cmd+=" && ";
        one_sweep_cmd+="${create_cluster_cmd}";
    fi;

    if [ -z "${deploy_cmd}" ] && [ -z "${reinit_cmd}" ] && [ -z "${create_cluster_cmd}" ] ; then
        echo "nothing to do. bailing out!";
        return 0;
    fi;

    ask_user_default_no "do it with one-liner ? ";
    if [ $? -eq 1 ] ; then
        echo ${one_sweep_cmd};
        return 0 ;
    fi;

    echo "==> $(pwd)";

    #############################################
    #            deploy
    #############################################
    if [[ ${deploy_choice} -eq 1 ]] ; then
        echo -e "${BLUE}$ {deploy_cmd} ${NC}";
        eval ${deploy_cmd};
        if [[ $? -ne 0 ]] ; then 
            while (( 1 == $(ask_user_default_yes "retry deploy ? " ; echo $?) )) ; do
                echo -e "${BLUE}$ {deploy_cmd} ${NC}";
                eval ${deploy_cmd};
                ret=$?
                if [ ${ret} -ne 0 ] ; then
                    echo -e "${RED}\t\tdeploy failed ! ! !${NC}";
                    continue;
                else
                    break;
                fi;
            done;

            if [[ ${ret} -ne 0 ]] ; then
                echo "";
                echo -e "${RED}\t\tdeploy failed ! ! !${NC}";
                return -1;
            fi;
        fi;
        echo -e "${GREEN}\t\tdeploy succeeded${NC}";
    fi;

    #############################################
    #            reinit
    #############################################
    if [[ ${reinit_choice} -eq 1 ]] ; then
        echo -e "${BLUE}$ {reinit_cmd} ${NC}";
        eval ${reinit_cmd};
        ret=$?;
        if [[ ${ret} -ne 0 ]] ; then 
            echo -e"${RED}$ \t\t reinit failed ! ! ! ${NC}";
            while (( 1 == $(ask_user_default_yes "retry reinit ? " ; echo $?) )) ; do
                echo -e "${BLUE}$ {reinit_cmd} ${NC}";
                eval ${reinit_cmd};
                ret=$?
                if [ ${ret} -ne 0 ] ; then
                    echo -e"${RED}$ \t\t reinit failed ! ! ! ${NC}";
                    continue;
                else
                    break;
                fi;
            done;

            if [[ ${ret} -ne 0 ]] ; then 
                echo -e"${RED}$ \t\t reinit failed ! ! ! ${NC}";
                return -1;
            fi;
        fi;

        echo -e"${GREEN}$ \t\t reinit succeeded ! ! ! ${NC}";
    fi;


    #############################################
    #            create_cluster
    #############################################
    [ ${create_cluster_choice} -eq 0 ] && return 0;

    echo -e "${BLUE}$ {create_cluster_cmd} ${NC}";
    eval ${create_cluster_cmd};
    if [[ $? -ne 0 ]] ; then 
        echo -e "${RED}\t\tcreate_cluster failed ! ! !${NC}";
        while (( 1 == $(ask_user_default_yes "retry create_cluster.sh ? " ; echo $?) )) ; do

            echo -e "${BLUE}$ {create_cluster_cmd} ${NC}";
            eval ${create_cluster_cmd};

            if [[ $? -ne 0 ]] ; then
                echo -e "${RED}\t\tcreate_cluster failed ! ! !${NC}";
                continue;
            else
                echo -e "${GREEN}\t\tGreat success${NC}";
                break;
            fi;

        done;
    else
        echo -e "${GREEN}\t\tGreat success${NC}";
    fi;
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
    [[ $? -eq 0 ]] && return -1;

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
    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

	# if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
		# echo "you must be in arwen";
		# return;
	# fi;

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

lg_list_file=~/yonienv/bashrc_dell_lg_list_file
lg_list=( $(cat ${lg_list_file} ));
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
        cluster=$(_dellclusterget);
    fi

    echo "${FUNCNAME} : cluster : ${cluster}";
     
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

    ask_user_default_no "use swarm to list all IPs ?";
    if [[ $? -eq 0 ]] ; then
        return;
    fi;

    print_underline_size "_" 80	 
    echo "/home/public/devutils/bin/swarm -ping -showall ${cluster}";
    print_underline_size "_" 80	 
    /home/public/devutils/bin/swarm -ping -showall ${cluster};

}
 
dellclusterconfigupdate ()
{
    local cluster_config_source_folder=~/docs/cluster_config_files;

    dellcdclusterconfigs;
    echo "about to copy cluster config files to $(p)";
    ask_user_default_yes "continue ?";
    if [ $? -eq 0 ] ; then
        c - ;
        return;
    fi;

    /bin/cp -v ${cluster_config_source_folder}/* .
    c - ;
}

dellclusterinfo ()
{
    local cluster=${1};

    # if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
    # echo "you must be in arwen";
    # return;
    # fi;

    if ! [ -e /home/public/devutils/bin/swarm ] ; then 
        echo "/home/public/devutils/bin/swarm not found";
        return;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    print_underline_size "_" 80	 
    echo "/home/public/devutils/bin/swarm -ping ${cluster}";
    print_underline_size "_" 80	 
    /home/public/devutils/bin/swarm -ping ${cluster};
    print_underline_size "_" 80	 
    echo "/home/public/scripts/xpool_trident/prd/xpool list -f -a -c ${cluster}";
    /home/public/scripts/xpool_trident/prd/xpool list -f -a -c ${cluster};
    return 0;

    # if [[ -z ${cluster} ]] ; then 
        # if [ -z ${YONI_CLUSTER} ] ; then
            # echo "run dellclusterenvsetup <cluster name> or dellclusterinfo <cluster name>";
            # return;
        # else
            # cluster=${YONI_CLUSTER};
        # fi;
    # else
        # print_underline_size "_" 80	 
        # echo "/home/public/devutils/bin/swarm -ping ${cluster}";
        # print_underline_size "_" 80	 
        # /home/public/devutils/bin/swarm -ping ${cluster};
        # print_underline_size "_" 80	 
        # echo "/home/public/scripts/xpool_trident/prd/xpool list -f -a -c ${cluster}";
        # /home/public/scripts/xpool_trident/prd/xpool list -f -a -c ${cluster};
        # return 0;
	# fi;

	# print_underline_size "_" 80	 
	# echo "/home/public/scripts/xpool_trident/prd/xpool list -f"
	# print_underline_size "_" 80	 
	# /home/public/scripts/xpool_trident/prd/xpool list -f

	# return 0;
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

dellcyclonebackup ()
{
    local src_folder=${1};
    local dst_folder=;

    if [ -z ${src_folder} ] ; then
        echo "${FUNCNAME} <cyclone folder>"
        return -1;
    fi;

    dst_folder=${src_folder};

    echo "rsync -av --progress ${src_folder} cyc@${yonivmipaddress}:/home/cyc/${dst_folder}";
    ask_user_default_yes "continue ?";
    [ $? -eq 0 ] && return 0;
          rsync -av --progress ${src_folder} cyc@${yonivmipaddress}:/home/cyc/${dst_folder};
    return 0;
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

dell_mount_jiraproduction ()
{
    sudo mount cecaunity01-nas.corp.emc.com:/jiraproduction /disks/jiraproduction;
    sudo mount cecaunity01-nas.corp.emc.com:/jiraproduction2 /disks/jiraproduction2
}
 
if ! [ -d /disks/jiraproduction ]  || ! [ -d /disks/jiraproduction2 ] ; then
    echo "/disks/jiraproduction not mounted";
    echo "use dell_mount_jiraproduction";
fi

alias delltriage-all-logs-node-a="./cyc_triage.pl -b . -n a -j"
alias delltriage-all-logs-node-b="./cyc_triage.pl -b . -n b -j"
alias delltriage-nt-logs-node-a="./cyc_triage.pl -b . -n a -j SUB_COMPONENT=nt"
alias delltriage-nt-logs-node-b="./cyc_triage.pl -b . -n b -j SUB_COMPONENT=nt"

# howto
# journalctl SUBCOMPONENT=nt
# journalctl -o short-precise --since "2022-07-04 07:56:00"
