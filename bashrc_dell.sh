#!/bin/bash

alias editbashdell='v ${yonienv}/bashrc_dell.sh'
alias ssh2amitvm='echo cycpass; ssh cyc@10.227.212.159'
alias ssh2eladvm='echo cycpass; ssh cyc@10.227.204.131'
alias ssh2iritvm='echo cycpass; ssh cyc@10.227.212.132'
# yonivmipaddress="10.244.196.235"
yonivmipaddress="10.227.212.155"
yonivm2ipaddress="10.227.212.133"
alias ssh2yonivm="sshpass -p cycpass ssh cyc@${yonivmipaddress}"
alias ssh2yonivm2="sshpass -p cycpass ssh cyc@${yonivm2ipaddress}"
export YONI_CLUSTER=;
export CYC_CONFIG=;

dell_clusters_file=${yonienv}/bashrc_dell_clusters.sh;
dell_cluster_list_file=${yonienv}/bashrc_dell_cluster_list_file.sh;
alias delleditclusterlist="v ${dell_clusters_file}";
alias delleditleasedclusters='v ~/.dell_leased_clusters'
# trident_cluster_list=(RT-G0082 RT-D3082 WX-D0902 WX-D0910 WX-G4033 WX-D0909 WX-D0733 WX-G4011 WX-D0896 WX-D1116 WX-D1111 WX-D1126 RT-G0015 RT-G0017 WK-D0675 WK-D0677 WK-D0666 WX-D1140 RT-G0060 RT-G0068 RT-G0069 RT-G0074 RT-G0072 RT-D0196 RT-D0042 RT-D0064 RT-G0037 WX-H7060 WK-D0023 );
trident_cluster_list=( $(cat ${dell_clusters_file}) );
# trident_cluster_list_nodes=$(for c in ${trident_cluster_list[@]} ; do echo $(echo $c|awk '{print tolower($0)}' ) $c $c-A $c-B $c-a $c-b ; done)
# trident_cluster_list_nodes=$(for c in ${trident_cluster_list[@]} ; do echo $(echo $c|awk '{print toupper($0)}' ) $c $c-A $c-B ; done)

# declare -A dell_cluster_list;
# export dell_cluster_list;

yelp "source /home/build/xscripts/xxsh";
[ -f /home/build/xscripts/xxsh ] && . /home/build/xscripts/xxsh 
yelp "finisehd source /home/build/xscripts/xxsh";

yonivm-update-yonienv ()
{
    cd;
    rsync -av --progress -R -e ssh yonienv/ cyc@${yonivmipaddress}:/home/cyc
    cd -
}

_trident_cluster_list_nodes_init ()
{
    trident_cluster_list_nodes=$(for c in ${trident_cluster_list[@]} ; do echo $(echo $c|awk '{print toupper($0)}' ) $c $c-A $c-B ; done) 
    complete -W "$(echo ${trident_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaserelease dellclusterdeploy dellclusterleasewithforce dellclusteryonienvupdate
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

    if [[ -z "${cluster}" ]] ; then
        #yelp "cluster is null";
        return 1;
    #else
        #yelp "cluster=${cluster} is not null";
    fi;

    cluster=$(echo $cluster | awk '{print toupper($0)}');

    trident_cluster_list=( $(cat ${dell_clusters_file}) );
    # if [ ${dell_cluster_list[${cluster}]+_} ] ; then 
    if [[ ${trident_cluster_list[@]} =~ ${cluster} ]] ; then 
    #if [[ $( printf "%s\n" ${trident_cluster_list[@]} | /bin/grep "${cluster}" | wc -l) -gt 0 ]] ; then 
        #echo "${cluster} already in trident_cluster_list";
        #echo ${trident_cluster_list[@]}
        return 1 ; 
    else 
        #echo "${cluster} not in trident_cluster_list";
        return 0; 
    fi;
}

_dellclusterlistaddcluster ()
{
    local cluster=${1};

    if [[ -z "${cluster}" ]] ; then
        # yelp "cluster is null";
        return 1;
    fi;

    cluster=$(echo ${cluster} | awk '{print toupper($0)}')

    _dellclusterlistfindcluster ${cluster};

    if [[ 0 -eq $? ]] ; then
        # dell_cluster_list[${cluster}]=1;
        yelp "Adding ${cluster} to list";
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

	echo "git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git ${pdr_folder_name}";
    ask_user_default_no "continue";
    if [ $? -eq 0 ] ; then return; fi;

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

dellcyclonetagsupdate ()
{
    local sed_cyclone_folder=;
    local dst_folder=;

    if [ -z ${cyclone_folder} ] ; then
        echo "cyclone folder not defined";
        return -1;
    fi;

    if ! [ -d ${cyclone_folder} ] ; then
        echo "${cyclone_folder} does not exist";
        return -1;
    fi;

    sed_cyclone_folder=$(echo ${cyclone_folder} | sed 's/\//\\\//g');
    dellcdcyclonefolder;
    # \cp ${yonienv}/dell-tags/tags.vim .;

    # fix tags file to match cyclone folder path
    # sed -i "s/cyclone-folder/${sed_cyclone_folder}/g" tags.vim;

    # whiptail --checklist "subject" hight width num-of-items
    build_choices=($(whiptail --checklist "cyclone tags" 13 30 7\
                   nt-nvmeof-frontend "" on \
                   cyc_core "" on  \
                   xios "" off  \
                   pm "" off  \
                   scsi "" off  \
                   third_party "" off \
                   cyc_crypto "" off 3>&1 1>&2 2>&3));


    echo > tags.vim;

    ######################################################################################
    if [[ ${build_choices[@]} =~ cyc_core ]] ; then
        dst_folder=source/cyc_core;
        #echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        \cp ${yonienv}/dell-tags/tagme-cyc_core.sh ${dst_folder}/tagme.sh;

        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;

        #\cp tags.vim ${dst_folder};
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ cyc_core && ${build_choices[@]} =~ xios ]] ; then
        dst_folder=source/cyc_core;
        #echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        #\cp ${yonienv}/dell-tags/tagme-cyc_core.sh ${dst_folder}/tagme.sh;
        echo 'includeTagdir+=(cyc_platform/src/xios/)' >> ${dst_folder}/tagme.sh
        echo 'includeTagdir+=(cyc_platform/src/include/)' >> ${dst_folder}/tagme.sh
        #\cp tags.vim ${dst_folder};
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ cyc_core && ${build_choices[@]} =~ pm ]] ; then
        dst_folder=source/cyc_core;
        #echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        #\cp ${yonienv}/dell-tags/tagme-cyc_core.sh ${dst_folder}/tagme.sh;
        echo 'includeTagdir+=(cyc_platform/src/pm/)' >> ${dst_folder}/tagme.sh
        #\cp tags.vim ${dst_folder};
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ cyc_core && ${build_choices[@]} =~ scsi ]] ; then
        dst_folder=source/cyc_core;
        #echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        #\cp ${yonienv}/dell-tags/tagme-cyc_core.sh ${dst_folder}/tagme.sh;
        echo 'includeTagdir+=(cyc_platform/src/st/)' >> ${dst_folder}/tagme.sh
        #\cp tags.vim ${dst_folder};
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ cyc_core ]] ; then
        dst_folder=source/cyc_core;
        echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        cat  ${yonienv}/bin/tagme.sh >> ${dst_folder}/tagme.sh ;

        cd ${dst_folder}; tttt; cd -;
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ nt-nvmeof-frontend ]] ; then
        dst_folder=source/nt-nvmeof-frontend;
        echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        \cp ${yonienv}/dell-tags/tagme-nt.sh ${dst_folder}/tagme.sh;
        #\cp tags.vim ${dst_folder};

        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;

        cd ${dst_folder}; tttt; cd -;
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ third_party ]] ; then
        dst_folder=source/third_party;
        echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        # copy tags from ~/tasks/tags/ to 
        \cp ${yonienv}/dell-tags/tagme-third-party.sh ${dst_folder}/tagme.sh;

        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;

        #\cp tags.vim ${dst_folder};

        cd ${dst_folder}; tttt; cd -;
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ cyc_crypto ]] ; then
        dst_folder=source/cyc_crypto;
        echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        # copy tags from ~/tasks/tags/ to 
        \cp ${yonienv}/dell-tags/tagme-nt.sh ${dst_folder}/tagme.sh;
        #\cp tags.vim ${dst_folder};

        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;

        cd ${dst_folder}; tttt; cd -;
    fi;

    \cp tags.vim source/cyc_core/tags.vim;
    \cp tags.vim source/nt-nvmeof-frontend/tags.vim;
    \cp tags.vim source/third_party/tags.vim;
    \cp tags.vim source/cyc_crypto/tags.vim;

    return 0;

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

alias dellpdr-reset='_dellpdr_reset'
_dellpdr_reset ()
{ 
    echo "git fetch"; git fetch;
    echo "git reset HEAD"; git reset HEAD;
    echo "git c ."; git c .;
}

alias dellpdr-gitsmup='_dellpdr_gitsmup'
_dellpdr_gitsmup ()
{
    local cyc_core=0;
    local nt_nvmeof_frontend=0;
    local linux=0;
    local third_party=0;
    local -a build_choices=();

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
    build_choices=($(whiptail --checklist "sync submodules" 11 30 6\
                   nt "" on \
                   cyc_core "" on  \
                   third_party "" off  \
                   linux "" off 3>&1 1>&2 2>&3));

    if [[ ${build_choices[@]} =~ cyc_core ]] ; then
        cyc_core=1;
    fi;
    if [[ ${build_choices[@]} =~ nt ]] ; then
        nt_nvmeof_frontend=1;
    fi;
    if [[ ${build_choices[@]} =~ third_party ]] ; then
        third_party=1;
    fi;
    if [[ ${build_choices[@]} =~ linux ]] ; then
        linux=1;
    fi;

    #--------------------------------------
    #            do it
    #--------------------------------------
    if (( ${cyc_core} == 1           )) ; then echo -e "${BLUE}-->update cyc_core${NC}";           git smupdate source/cyc_core           ; fi;
    if (( ${nt_nvmeof_frontend} == 1 )) ; then echo -e "${BLUE}-->update nt-nvmeof-frontend${NC}"; git smupdate source/nt-nvmeof-frontend ; fi;
    if (( ${linux} == 1              )) ; then echo -e "${BLUE}-->update linux${NC}";              git smupdate source/linux              ; fi;
    if (( ${third_party} == 1        )) ; then echo -e "${BLUE}-->update third_party${NC}";        git smupdate source/third_party        ; fi;

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


    if (( ${cyc_core} == 1           )) ; then echo -e "${BLUE}-->updated cyc_core${NC}"; fi;
    if (( ${nt_nvmeof_frontend} == 1 )) ; then echo -e "${BLUE}-->updated nt-nvmeof-frontend${NC}"; fi;
    if (( ${linux} == 1              )) ; then echo -e "${BLUE}-->updated linux${NC}"; fi;
    if (( ${third_party} == 1        )) ; then echo -e "${BLUE}-->updated third_party${NC}"; fi;
}
 
alias dellpdr-git-sync-submodules='_dellpdr_git_sync_submodules'
_dellpdr_git_sync_submodules ()
{
    local cyc_core=0;
    local nt_nvmeof_frontend=0;
    local linux=0;
    local third_party=0;
    local pdr_branch=;
    local checkout_cmd=cb;
    local ans=;

    ask_user_default_no "are you in a pdr ? ";
    if [ $? -eq 0 ] ; then
        echo "bailing out";
        return;
    fi;

    ask_user_default_no "reset the pdr before we start ? ";
    [ $? -eq 1 ] && dellpdr-reset;

    pdr_branch=$(git bb);
    #--------------------------------------
    #            ask user
    #--------------------------------------
    build_choices=($(whiptail --checklist "sync submodules" 11 30 6\
                   nt "" on \
                   cyc_core "" on  \
                   third_party "" off  \
                   linux "" off 3>&1 1>&2 2>&3));

    if [[ ${build_choices[@]} =~ cyc_core ]] ; then
        cyc_core=1;
    fi;

    if [[ ${build_choices[@]} =~ nt ]] ; then
        nt_nvmeof_frontend=1;
    fi;

    if [[ ${build_choices[@]} =~ third_party ]] ; then
        third_party=1;
    fi;

    if [[ ${build_choices[@]} =~ linux ]] ; then
        linux=1;
    fi;

    #ask_user_default_yes "update source/cyc_core ?";
    #[ $? -eq 1 ] && cyc_core=1;

    #ask_user_default_yes "update source/nt-nvmeof-frontend ?";
    #[ $? -eq 1 ] && nt_nvmeof_frontend=1;

    #ask_user_default_no "update source/third_party ?";
    #[ $? -eq 1 ] && third_party=1;

    #ask_user_default_no "update source/linux ?";
    #[ $? -eq 1 ] && linux=1;

    read -p "[c]heckout or create new [b]ranch ? [C|b]" ans;
    if [[  ${ans} == c ]] ; then
        checkout_cmd=c;
    fi;

    ask_user_default_no "are you sure ?";
    [ $? -eq 0 ] && return;
    #--------------------------------------
    #            do it
    #--------------------------------------
    if (( ${cyc_core} == 1 )) ; then 
        echo -e "${BLUE}---->update cyc_core${NC}";           
        echo -e "${YELLOW}cd source/cyc_core${NC}";
        cd source/cyc_core;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        git ${checkout_cmd} ${pdr_branch};
        cd - 1>/dev/null;
    fi;
    if (( ${nt_nvmeof_frontend} == 1 )) ; then
        echo -e "${BLUE}---->update nt-nvmeof-frontend${NC}";
        echo -e "${YELLOW}cd source/nt-nvmeof-frontend${NC}";
        cd source/nt-nvmeof-frontend;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        git ${checkout_cmd} ${pdr_branch};
        cd - 1>/dev/null;
    fi;
    if (( ${linux} == 1 )) ; then
        echo -e "${BLUE}---->update linux${NC}";              
        echo -e "${YELLOW}cd source/linux${NC}";
        cd source/linux;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        git ${checkout_cmd} ${pdr_branch};
        cd - 1>/dev/null;
    fi;
    if (( ${third_party} == 1 )) ; then
        echo -e "${BLUE}---->update third_party${NC}";
        echo -e "${YELLOW}cd source/third_party${NC}";
        cd source/third_party;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        git ${checkout_cmd} ${pdr_branch};
        cd - 1>/dev/null;
    fi;
}
 
alias dellpdr-show-branches='_dellpdr_show_branches'
_dellpdr_show_branches ()
{
    cd source/cyc_core;
    echo -e "${BLUE}$(pwd)${NC}";
    echo -e "\t${GREEN}$(git bb)${NC} -> ${RED}$(git t 2>/dev/null)${NC}";
    cd - 1>/dev/null;

    cd source/nt-nvmeof-frontend;
    echo -e "${BLUE}$(pwd)${NC}";
    echo -e "\t${GREEN}$(git bb)${NC} -> ${RED}$(git t 2>/dev/null)${NC}";
    cd - 1>/dev/null;
     
    cd source/third_party;
    echo -e "${BLUE}$(pwd)${NC}";
    echo -e "\t${GREEN}$(git bb)${NC} -> ${RED}$(git t 2>/dev/null)${NC}";
    cd - 1>/dev/null;

    cd source/linux;
    echo -e "${BLUE}$(pwd)${NC}";
    echo -e "\t${GREEN}$(git bb)${NC} -> ${RED}$(git t 2>/dev/null)${NC}";
    cd - 1>/dev/null;

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

    if (( 0 !=  $(hostname -i | grep ${yonivm2ipaddress}  | wc -l ) )) ; then
        return 0;
    fi;

    # cannot build on other manchines.
    return -1;
}

dellcyclonebuild ()
{
    local build_third_party_cmd=;
    local repeat_last_choice=0;
    local build_choices=;
    local build_cmd=;
    local prune_cmd=;
    local flavor=RETAIL;
    local start_time=;
    local end_time=;
    local build_time=;
    local r;

    _dellcyclonebuild_validate_build_machine
    if [[ $? -ne 0 ]] ; then
        echo "you must do this from arwen or dev-vm. bailing out!!!";
        return -1
    fi;
    
    if [ -z "${cyclone_folder}" ]  ; then
        echo "cyclone_folder not set! use dellclusterruntimeenvset";
        return -1;
    fi;

	dellcdcyclonefolder;
	[[ $? -ne 0 ]] && return -1;
	
    dellclusterruntimeenvget
    ask_user_default_yes "continue ?"
    [[ $? -eq 0 ]] && return -1;

    # dellcyclonebuildhistorylog;
     
    if [ -e ${cyclone_folder}/.build_choices_bkp ] ; then
        source ${cyclone_folder}/.build_choices_bkp;

        echo "====== last command choices =============";
        echo -e "${BLUE}prune_cmd${NC}=${prune_cmd}";
        echo -e "${BLUE}build_cmd${NC}=${build_cmd}";
        echo -e "${BLUE}build_third_party_cmd${NC}=${build_third_party_cmd}";

        ask_user_default_no "repeat your last choices ? ";
        if [ $? -eq 1 ] ; then
            repeat_last_choice=1;
        fi;
    fi;

    # whiptail --checklist "cyclone build" hight width num-of-items
    if [ ${repeat_last_choice} -eq 0 ] ; then
        prune_cmd=;
        build_cmd=;
        build_third_party_cmd=;

        build_choices=($(whiptail --checklist "cyclone build" 11 30 6\
                       prune "" off \
                       debug "" off  \
                       verbose "" off  \
                       disable-cache "" off \
                       cyc_core "" on \
                       third-party "" off 3>&1 1>&2 2>&3));

        if [[ ${build_choices[@]} =~ debug ]] ; then
            flavor=DEBUG;
        fi;

        if [[ ${build_choices[@]} =~ cyc_core ]] ; then
            build_cmd="nice -20 make cyc_core force=yes flavor=${flavor}";

            if [[ ${build_choices[@]} =~ cache ]] ; then
                build_cmd+=" acache=no mcache=no dcache=no";
            fi;

            if [[ ${build_choices[@]} =~ verbose ]] ; then
                build_cmd+=" verbose=3";
            fi;

            if [[ ${build_choices[@]} =~ prune ]] ; then
                prune_cmd="nice -20 make prune flavor=${flavor}";
            fi;
        fi;

        if [[ ${build_choices[@]} =~ third-party ]] ; then
            build_third_party_cmd="make third_party force=yes flavor=${flavor}";

            if [[ ${build_choices[@]} =~ prune ]] ; then
                prune_cmd="nice -20 make prune flavor=${flavor}";
            fi;
        fi;
	fi;

    echo -e "prune_cmd=\"${prune_cmd}\"" > ${cyclone_folder}/.build_choices_bkp;
    echo -e "build_cmd=\"${build_cmd}\"" >> ${cyclone_folder}/.build_choices_bkp;
    echo -e "build_third_party_cmd=\"${build_third_party_cmd}\"" >> ${cyclone_folder}/.build_choices_bkp
    echo "build_date=$(now)" >> ${cyclone_folder}/.build_choices_bkp;
    echo "build_branch=$(git bb)" >> ${cyclone_folder}/.build_choices_bkp;
    echo "build_pdr=${cyclone_folder}" >> ${cyclone_folder}/.build_choices_bkp;
    echo "build_pdr_git_index=$(git hh)" >> ${cyclone_folder}/.build_choices_bkp;

    #if ! [[ ${build_choices[@]} =~ cyc_core ]] ; then
        #build_cmd=;
    #fi;

    if  [ -n "${build_cmd}" ] ; then
        if [[ ${repeat_last_choice} == 0 ]] ; then
            echo -e "\n========== start build ($(pwd)) ===================\n";
            echo -e "${BLUE}prune_cmd${NC}=${prune_cmd}";
            echo -e "${BLUE}build_cmd${NC}=${build_cmd}";
            echo -e "${BLUE}build_third_party_cmd${NC}=${build_third_party_cmd}";
            echo -e "\n========================================================";
            ask_user_default_yes "continue ?";
            [ $? -eq 0 ] && return 0;
        fi;

        if [[ -n "${prune_cmd}" ]] ; then
            _dellcyclonebackupuserchoices backup;
            eval ${prune_cmd};
            _dellcyclonebackupuserchoices restore;
        fi;

        start_time=$SECONDS;
        # build_cmd="time ${build_cmd}";
        eval ${build_cmd} | tee dellcyclonebuild.log;
        # $(set -x; ls -ltr source/cyc_core/cyc_platform/obj_Release/main/xtremapp);
        end_time=$SECONDS;
        build_time=$(( ${end_time} - ${start_time} ))
        echo "build took $(date -u -d @"$build_time" +'%-Mm %-Ss')";

        echo;
        p;
        fd -I -t f ".*xtremapp$";
        fd -IH -t f -e ko nvmet-power source/third_party/;
        # source/cyc_core/cyc_platform/obj_Release/main/xtremapp
        # source/cyc_core/cyc_platform/obj_Release/package/top_bsc/cyc_bsc/bin/xtremapp
    fi;

    if [ -n "${build_third_party_cmd}" ] ; then
        echo "===================================================";
        echo -e "${BLUE}prune_cmd${NC}=${prune_cmd}";
        echo -e "${BLUE}build_cmd${NC}=${build_cmd}";
        echo -e "${BLUE}build_third_party_cmd${NC}=${build_third_party_cmd}";

        r=1;
        if [[  ${repeat_last_choice} == 0 ]] ; then
            ask_user_default_no "build third_party ? ";
            r=$?;
        fi;

        if [ $r -eq 1 ] ; then
            if [[ -n "${prune_cmd}" && -z "${build_cmd}" ]] ; then
                _dellcyclonebackupuserchoices backup;
                eval ${prune_cmd};
                _dellcyclonebackupuserchoices restore;
            fi;
            eval ${build_third_party_cmd};
        fi;
    fi;

    echo -e "build_time=\"$(date -u -d @"$build_time" +'%-Mm %-Ss')\"" >> ${cyclone_folder}/.build_choices_bkp;
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
        ask_user_default_no "re-generate ${list_file}";
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

    if [ -e ~/docs/dell-cluster-list-${user}.txt ] ; then
        ask_user_default_no "open last user cluster leased list ? ";
        if [ $? -eq 1 ] ; then
            less ~/docs/dell-cluster-list-${user}.txt;
            return;
        fi;
    fi;

    /home/public/scripts/xpool_trident/prd/xpool list -u ${user} | tee ~/docs/dell-cluster-list-${user}.txt;
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
alias dellclusterlist-platformio-fe=' _dellclusterlist ~/docs/dell-cluster-list-platformmanager.txt PlatformIO-FE'
alias dellclusterlist-xblock='        _dellclusterlist ~/docs/dell-cluster-list-xblock.txt          Xblock-NDU'
alias dellclusterlist-shared='        _dellclusterlist ~/docs/dell-cluster-list-shared.txt          Core-Dev-Shared'
alias dellclusterlist-shared-nvmeofc='_dellclusterlist ~/docs/dell-cluster-list-shared-nvmeofc.txt  Core-Dev-Shared NVMeOF-FC'
alias dellclusterlist-shared-indus='  _dellclusterlist ~/docs/dell-cluster-list-shared-indus.txt    Core-Dev-Shared-Indus'
alias dellclusterlist-qa-app-lab='    _dellclusterlist ~/docs/dell-cluster-list-qa-app-lab.txt      QA-AppLab'
alias dellclusterlist-trident-roce='  _dellclusterlist ~/docs/dell-cluster-list-trident-roce.txt    Trident-kernel-IL NVMeOF-RoCE'
alias dellclusterlist-trident-indus=' _dellclusterlist ~/docs/dell-cluster-list-trident-indus.txt   Trident-kernel-IL indus'

# PlatformIO-FE:adamh
xpool_users=(y_cohen grupie amite eldadz levyi2 adamh joseph_karner);
complete -W "$(echo ${xpool_users[@]})" dellclusterlist-user dellclusterlease-update-user;

dellclusterleaserelease ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster="$(printf "%s\n" $(cat ~/.dell_leased_clusters) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        if [[ -z "${cluster}" ]] ; then
            cluster=$(_dellclusterget);
        fi;
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    cluster=$(echo ${cluster} | awk '{print toupper($0)}');

    echo "/home/public/scripts/xpool_trident/prd/xpool release ${cluster}";
    ask_user_default_no "are you sure ? ";
    [[ $? -eq 0 ]] && return;

    if [[ $(grep ${cluster} ~/.dell_leased_clusters | wc -l) -gt 0 ]] ; then
        sed -i "/${cluster}/d" ~/.dell_leased_clusters;
    fi;

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

    cluster=$(echo ${cluster} | awk '{print toupper($0)}');

    echo "/home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster}";
    /home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster};
    echo "/home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster}";
    echo ${cluster} >> ~/.dell_leased_clusters
}

dellclusterlease-update-user ()
{
    local cluster=${1};
    local user=${1:-labmaintenance};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo "/home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster}";
    ask_user_default_yes "continue ?";
    [ $? -eq 0 ] && return;

    /home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster};
}

alias dellclusterleasewithforce='/home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen '
alias dellclusterlease='_dellclusterlease 3d';
alias dellclusterleaseshared='_dellclusterlease 72h'

dellclusterglobalruntimeenvbkpfile=~/.dellclusterruntimeenvbkpfile
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
        echo -e "${RED} CYC_CONFIG not set ${NC}";
        return -1;
    fi;

    if ! [ -e ${CYC_CONFIG} ] ; then
        echo -e "${RED} ${CYC_CONFIG} does not exist ${NC}";
        echo -e "${YELLOW} use dellclustergeneratecfg ${YONI_CLUSTER} in yonivm ${NC}";
        return -1;
    fi;

    return 0;
}

dellclusterruntimeenvget ()  
{ 
    local last_used_cluster=;
    
#   if [[ -z ${YONI_CLUSTER} ]] ; then
#       if [[ -e ${dellclusterruntimeenvbkpfile} ]] ; then
#           last_used_cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ${dellclusterruntimeenvbkpfile});
#       fi;
#       
#       echo -e "\033[1;31mYONI_CLUSTER not set\033[0m";
#       if [[ -n ${last_used_cluster} ]] ; then
#           echo -e "last used cluster : \033[1;32m${last_used_cluster}\033[0m";
#       fi;
#   fi;
     
    _dellclusterruntimeenvvalidate ;

	print_underline_size "_" 80	 
    echo -e "\033[1;31mYONI_CLUSTER\033[0m\t\t\033[1;32m$YONI_CLUSTER\033[0m"
    echo -e "\033[1;31mcyclone_folder\033[0m\t\t${cyclone_folder}";
    #echo -e "\033[1;31mCYC_CONFIG\033[0m\t\t${CYC_CONFIG}"
    #echo -e "\033[1;31mcyc_helpers_folder\033[0m\t${cyc_helpers_folder}";
    #echo -e "\033[1;31mthird_party_folder\033[0m\t${third_party_folder}";
    if ! [ -z ${pnvmet_folder} ] ; then
        echo -e "\033[1;31mpnvmet_folder\033[0m\t\t${pnvmet_folder}";
    fi;
	print_underline_size "_" 80	 
    echo;
}
alias gd='dellclusterruntimeenvget'

_dellclusteruserchoicesget ()
{
    if [ -n "${cyclone_folder}" ] ; then
        echo -e "${GREEN}============= ${cyclone_folder} =======================${NC}"
        if [ -e ${cyclone_folder}/.install_choices_bkp ] ; then
            cat ${cyclone_folder}/.install_choices_bkp;
            echo -e "${GREEN}============= ${cyclone_folder} =======================${NC}";
        fi
        if [ -e ${cyclone_folder}/.build_choices_bkp ] ; then
            cat ${cyclone_folder}/.build_choices_bkp;
            echo -e "${GREEN}============= ${cyclone_folder} =======================${NC}";
        fi;
        if [ -e ${cyclone_folder}/.dellclusterruntimeenvbkpfile ] ; then
            cat ${cyclone_folder}/.dellclusterruntimeenvbkpfile | grep "YONI_CLUSTER\|YONI_PDR\|pnvmet_folder" | sed 's/export//g';
        fi;
    fi;

    if [ -e ${dellclusterglobalruntimeenvbkpfile} ] ; then
        echo -e "${PURPLE}============ global backup file ${dellclusterglobalruntimeenvbkpfile} ============${NC}";
        cat ${dellclusterglobalruntimeenvbkpfile} | grep "YONI_CLUSTER\|YONI_PDR\|pnvmet_folder" | sed 's/export//g';
    fi;

}
#alias gdd='_dellclusteruserchoicesget'
gdd ()
{
    if [[ -z ${cyclone_folder} ]] ; then
        _dellclusteruserchoicesget;
        return;
    fi;

    if [[ ${1} == "ls" ]] ; then
        ls -tr ${cyclone_folder}/.install_build_choices_bkp.*|xargs cat | grep "_date\|_time";
        return;
    fi;

    _dellclusteruserchoicesget | tee ${cyclone_folder}/.install_build_choices_bkp.$(date +"%d_%m_%y");
}

dellenvrebash ()
{
    local cluster=;
    local pdr_folder=;
    local bkp_file=;

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

    if [[ "cyclone" == "$(basename $(git remote get-url origin 2>/dev/null) .git)" ]] ; then
        if [[ -e ./.dellclusterruntimeenvbkpfile ]] ; then
            bkp_file=./.dellclusterruntimeenvbkpfile;
        fi;
    fi;

    if [ -z "${bkp_file}" ] ; then
        if  [[ -e ${dellclusterglobalruntimeenvbkpfile} ]] ; then
            bkp_file=${dellclusterglobalruntimeenvbkpfile};
        fi;
    fi;

    echo "bkp_file=${bkp_file}";

    if [ -n "${bkp_file}" ] ; then
        pdr_folder=$(awk -F '='  '/YONI_PDR/{print $2}' ${bkp_file});
        if [[ -z ${pdr_folder} ]] ; then
            echo -e "${RED}last used pdr folder not saved${NC}";
            echo -e "${RED}you should do this from a cyclone pdr repo${NC}";
            return -1;
        fi;

        cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ${bkp_file});
        if [[ -z ${cluster} ]] ; then
            echo -e "${RED}last used cluster not saved${NC}";
            #return -1;
        fi;

        pnvmet_folder=$(awk -F '='  '/pnvmet_folder/{print $2}' ${bkp_file});
        if [[ -n "${pnvmet_folder}" ]] ; then
            export pnvmet_folder=${pnvmet_folder};
        fi;
    else
        echo -e "${RED}no backup files were found. bailing out${NC}";
        return -1;
    fi;
     
    if [ -n "${cluster}" ] ; then
        ask_user_default_yes "$FUNCNAME use ${cluster} again ?";
        if [ $? -eq 0 ] ; then
            cluster=;
        fi;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster="$(printf "%s\n" ${trident_cluster_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
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
        if [[ $( file .git | grep directory | wc -l ) -gt 0 ]] ; then
            return 0;
        fi;

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
alias dddcore='[ -n "${cyclone_folder}" ] && c ${cyclone_folder}/source/cyc_core || echo "!!!cyclone_folder empty!!!"'
alias dddnt='[ -n "${cyclone_folder}" ] && c ${cyclone_folder}/source/nt-nvmeof-frontend || echo "!!!cyclone_folder empty!!!"'
alias dddthird-party='[ -n "${cyclone_folder}" ] && c ${cyclone_folder}/source/third_party || echo "!!!cyclone_folder empty!!!"'
alias dddthird-party-objects='dellcdthirdpartyobjects'
alias dddbroadcomsources='dellcdbroadcomsources'
alias dddbroadcommakefiles='dellcdbroadcommakefiles'
alias dddpnvmet='[ -n "${pnvmet_folder}" ] && c ${pnvmet_folder} || echo "!!!pnvmet_folder empty!!!"'
dellcdcyclonescripts ()
{
    if [ -z ${cyclone_folder} ] ; then
        echo "runtime env is not set";
        return -1;
    fi;
    cd ${cyclone_folder}/source/cyc_core/cyc_platform/src/package/cyc_host/cyc_bsc/scripts
    return 0;
}

export _dellclusterruntimeenvset=0
dellclusterruntimeenvset ()
{
    local cluster=${1};
    local cluster_config_file=;
    local global_needs_update=0;

    if [[ "cyclone" != "$(basename $(git remote get-url origin 2>/dev/null) .git)" ]] ; then
        echo -e "${RED}you should do this from a cyclone pdr repo${NC}";
        return -1;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    cluster=$(echo ${cluster} | awk '{print toupper($0)}');
    cyc_configs_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_configs);
    cluster_config_file=${cyc_configs_folder}/cyc-cfg.txt.${cluster}-BM;
    CYC_CONFIG=${cluster_config_file};

    export CYC_CONFIG=${cluster_config_file};
    cyclone_folder=$(pwd -P);
    export YONI_CLUSTER=${cluster};
    _dellclusterruntimeenvvalidate;
    if [[ $? -ne 0 ]] ; then
        ask_user_default_no "set it anyways ? ";
        if [ $? -eq 0 ] ; then
            echo "!!! failed to set runtimeenv !!!";
            export CYC_CONFIG=;
            cyclone_folder=;
            export YONI_CLUSTER=;
            return 1;
        fi;
    fi;


    if ! [ -e source/third_party/cyc_platform/src/third_party/PNVMeT ] ; then
        echo -e "${RED}\n!! warning !! : no such folder : source/third_party/cyc_platform/src/third_party/PNVMeT\n${NC}";
    else
        third_party_folder=$(readlink -f source/third_party/cyc_platform/src/third_party/PNVMeT);
    fi;

    cyc_helpers_folder=$(readlink -f source/cyc_core/cyc_platform/src/package/cyc_helpers);
    dell_kernel_objects=$(readlink -f source/cyc_core/cyc_platform/obj_Release/third_party/PNVMeT/src/PNVMeT)

    #echo "export CYC_CONFIG=${cluster_config_file}";
    #ask_user_default_yes "Correct ? "
    #[ $? -eq 0 ] && return;

    echo "export CYC_CONFIG=${CYC_CONFIG}"    >  ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
    echo "export YONI_CLUSTER=${cluster}"     >> ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
    echo "export YONI_PDR=${cyclone_folder}"  >> ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
    echo "export pnvmet_folder=${pnvmet_folder}"  >> ${cyclone_folder}/.dellclusterruntimeenvbkpfile;

    if [[ -e ${dellclusterglobalruntimeenvbkpfile} ]] ; then
        if [[ $(diff ${cyclone_folder}/.dellclusterruntimeenvbkpfile ${dellclusterglobalruntimeenvbkpfile} | wc -l) -gt 0 ]] ; then
            global_needs_update=1;
        fi;
    else
        global_needs_update=1;
    fi;

    if [[ ${global_needs_update}  -eq 1 ]] ; then
        ask_user_default_no "update setting with global backup file"
        if [ $? -eq 1 ] ; then
            /bin/cp ${cyclone_folder}/.dellclusterruntimeenvbkpfile ${dellclusterglobalruntimeenvbkpfile}
        fi;
    fi;

    _dellclusterlistaddcluster ${YONI_CLUSTER};
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

    echo -en "${RED}you must do this from dev-vm. are you ? ${NC}";
    ask_user_default_yes;
    if [[ $? -eq 0 ]] ; then
        return -1;
    fi;

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
    local cluster=${1};
    local extend=${2:-14d};

    if [ "${cluster}" == "ask" ] ; then
        cluster=;
    fi;

    # offer to extend a leased cluster
    if [ -z ${cluster} ] ; then
        cluster="$(printf "%s\n" $(cat ~/.dell_leased_clusters) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        # if [ -z "${cluster}" ] ; then
        if [ $? -eq 1 ] ; then
            echo "usage : ${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo -n "extend ${cluster} ";
    read -p "extend 14 days ? : " extend;
    if [ -z ${extend} ] ; then
        extend=14d;
    else
        extend="${extend}d";
    fi;

    echo -e "\t\t-> /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend}"
    /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend};

}

alias dellclusterleaseextendshared='dellclusterleaseextend ask 72h';

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

#ssh2core-a ()
#{
    #local core_ip=;

    #_dellclusterruntimeenvvalidate;
    #if [[ $? -ne 0 ]] ; then
        #return -1;
    #fi;
    #core_ip=$(grep local_ip_a $CYC_CONFIG | sed 's/"//g' | sed 's/.*=//g');

    #sshpass -p cycpass ssh core@${core_ip};
#}

# ######################################################################
# ssh2core-a, ssh2core-b,ssh2bsc_a,ssh2bsc-b all depend on CYC_CONFIG 
# a better approach is to use sshswarm
#ssh2bsc-a ()
#{
    #_dellclusterruntimeenvvalidate;
    #if [[ $? -ne 0 ]] ; then
        #return -1;
    #fi;
    #dellcdclusterscripts;
    #./ssh_cyc_a.sh;
    #cd -;
#}

#ssh2bsc-b ()
#{
    #_dellclusterruntimeenvvalidate;
    #if [[ $? -ne 0 ]] ; then
        #return -1;
    #fi;
    #dellcdclusterscripts;
    #./ssh_cyc_b.sh;
    #cd -;
#}

#_ssh2core-node ()
#{
    #local core_ip=;
    #local node=$1

    #_dellclusterruntimeenvvalidate;
    #if [[ $? -ne 0 ]] ; then
        #return -1;
    #fi;
    #core_ip=$(grep local_ip_${node} $CYC_CONFIG | sed 's/"//g' | sed 's/.*=//g');
    #sshpass -p cycpass ssh core@${core_ip};
#}

#alias ssh2core-a='_ssh2core-node a';
#alias ssh2core-b='_ssh2core-node b';
# ######################################################################

_add_cluster_to_list ()
{
    local cluster=${1};

    cluster=$(echo ${cluster} | awk '{print toupper($0)}');

    if ! [[ ${trident_cluster_list[@]} =~ ${cluster} ]] ; then
        ask_user_default_no "add ${cluster} to list";
        if [ $? -eq 0 ] ; then return ; fi;
        echo ${cluster} >> ${dell_clusters_file};
        trident_cluster_list+=" ${cluster}";
        echo -e "${RED}added ${cluster} to saved clusters${NC}";
    fi;

}

ssh2core-a ()
{
    local cluster=${1};

    if [[ -z "${cluster}" && -n "${YONI_CLUSTER}" ]] ; then 
        ask_user_default_yes "you did not specify <cluster> use ? YONI_CLUSTER :${YONI_CLUSTER}";
        if [[ $? -eq 1 ]] ; then
            cluster=${YONI_CLUSTER};
        fi;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    _add_cluster_to_list ${cluster};

    echo ${cluster} > ~/.dellssh2cluster.bkp
    cluster=${cluster}-spa;
    echo "swarmssh ${cluster}";
    swarmssh ${cluster};
}

ssh2core-b ()
{
    local cluster=${1};

    if [[ -z "${cluster}" && -n "${YONI_CLUSTER}" ]] ; then 
        ask_user_default_yes "you did not specify <cluster> use ? YONI_CLUSTER :${YONI_CLUSTER}";
        if [[ $? -eq 1 ]] ; then
            cluster=${YONI_CLUSTER};
        fi;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    _add_cluster_to_list ${cluster};

    echo ${cluster} > ~/.dellssh2cluster.bkp
    cluster=${cluster}-spb;
    echo "swarmssh ${cluster}";
    swarmssh ${cluster};
}

ssh2bsc-a ()
{
    local cluster=${1};

    if [[ -z "${cluster}" && -n "${YONI_CLUSTER}" ]] ; then 
        ask_user_default_yes "you did not specify <cluster> use ? YONI_CLUSTER :${YONI_CLUSTER}";
        if [[ $? -eq 1 ]] ; then
            cluster=${YONI_CLUSTER};
        fi;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    _add_cluster_to_list ${cluster};

    echo ${cluster} > ~/.dellssh2cluster.bkp
    cluster=${cluster}-spa;
    echo "swarmssh --docker bsc ${cluster}";
    swarmssh --docker bsc ${cluster};
}

ssh2bsc-b ()
{
    local cluster=${1};

    if [[ -z "${cluster}" && -n "${YONI_CLUSTER}" ]] ; then 
        ask_user_default_yes "you did not specify <cluster> use ? YONI_CLUSTER :${YONI_CLUSTER}";
        if [[ $? -eq 1 ]] ; then
            cluster=${YONI_CLUSTER};
        fi;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    _add_cluster_to_list ${cluster};

    echo ${cluster} > ~/.dellssh2cluster.bkp
    cluster=${cluster}-spb;
    echo "swarmssh --docker bsc ${cluster}";
    swarmssh --docker bsc ${cluster};
}

ssh2core ()
{
    local cluster=${1};
    local node=BOTH;

    if [[ -z "${cluster}" && -n "${YONI_CLUSTER}" ]] ; then 
        ask_user_default_yes "you did not specify <cluster> use ? YONI_CLUSTER :${YONI_CLUSTER}";
        if [[ $? -eq 1 ]] ; then
            cluster=${YONI_CLUSTER};
        fi;
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    cluster=$(echo ${cluster} | awk '{print toupper($0)}' )
    _add_cluster_to_list ${cluster};

    echo ${cluster} > ~/.dellssh2cluster.bkp

    read -p "[a|b|default BOTH] : " node;
    if [ "${node}" = 'a' ] ; then
        cluster=${cluster}-a;
    elif [ "${node}" = 'b' ] ; then
        cluster=${cluster}-b;
    fi;

    echo -e "\t${BLUE}xxssh ${cluster}${NC}";
    xxssh ${cluster};
}
 
ssh2coreleased ()
{
    local cluster=${1};
    local node=BOTH;

    if [ -z "${cluster}" ] ; then 
        cluster="$(printf "%s\n" $(cat ~/.dell_leased_clusters) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    echo ${cluster} > ~/.dellssh2cluster.bkp

    read -p "[a|b|default BOTH] : " node;
    if [ "${node}" = 'a' ] ; then
        cluster=${cluster}-a;
    elif [ "${node}" = 'b' ] ; then
        cluster=${cluster}-b;
    fi;

    echo -e "\t${BLUE}xxssh ${cluster}${NC}";
    xxssh ${cluster};
}

ssh2bscleased ()
{
    local cluster=${1};
    local node=BOTH;

    if [ -z "${cluster}" ] ; then 
        cluster="$(printf "%s\n" $(cat ~/.dell_leased_clusters) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    echo ${cluster} > ~/.dellssh2cluster.bkp

    read -p "[a|b|default BOTH] : " node;
    if [ "${node}" = 'a' ] ; then
        cluster=${cluster}-a;
    elif [ "${node}" = 'b' ] ; then
        cluster=${cluster}-b;
    fi;

    echo -e "\t${BLUE}xxbsc ${cluster}${NC}";
    xxbsc ${cluster};
}

if [[ -e ~/.dell_leased_clusters ]] ; then
    complete -W "$(cat ~/.dell_leased_clusters)" ssh2coreleased ssh2bscleased
fi;

delleditleasedclusters='v ~/.dell_leased_clusters'

ssh2bsc ()
{
    local cluster=${1};
    local node=BOTH;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    _add_cluster_to_list ${cluster};

    echo ${cluster} > ~/.dellssh2cluster.bkp

    read -p "[a|b|default BOTH] : " node;
    if [ "${node}" = 'a' ] ; then
        cluster=${cluster}-a;
    elif [ "${node}" = 'b' ] ; then
        cluster=${cluster}-b;
    fi;

    echo -e "\t${BLUE}xxbsc ${cluster}${NC}";
    xxbsc ${cluster};
}

_getlastusedcluster ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        if [ -e ~/.dellssh2cluster.bkp ] ; then 
            cluster=$(cat ~/.dellssh2cluster.bkp);
        fi;
        if [ -n "${cluster}" ] ; then 
            ask_user_default_yes "use ${cluster} again ?";
            if [ $? -eq 0 ] ; then cluster=; fi;
        fi;

        if [ -z "${cluster}" ] ; then 
            cluster="$(printf "%s\n" ${trident_cluster_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        fi;
    fi;

    if [ -z "${cluster}" ] ; then
       return -1; 
    fi;

    echo ${cluster};
    return 0;
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
alias dddscripts='dellcdclusterscripts'

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
    local flavor=retail;
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

    ask_user_default_no "flavor is debug ?"
    if [ $? -eq 1 ] ; then
        flavor=debug;
    fi;

    ask_user_default_no "would you like a feature flag ? ";
    if [ $? -eq 0 ] ; then
        autoinstall_cmd=$(echo -e "${autoinstall_cmd} -swarm ${cluster} -type san -flavor ${flavor} -ibid ${ibid} ");
    else
        # read -p "enter feature : " feature_flag;
        feature_flag=$(dellcyclonefeatureflaglist);
        if [[ $? -ne 0 ]] ; then
            echo "CYC_CONFIG not set. use dellclusterruntimeenvset <cluster>";
            return;
        fi;
        autoinstall_cmd=$(echo -e "${autoinstall_cmd} -swarm ${cluster} -type san -flavor ${flavor} -ibid ${ibid} -feature ${feature_flag}");
    fi;
    
    echo ${autoinstall_cmd};

    ask_user_default_no "continue ?";
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
    local last_used_cluster=;
    local cluster=;

    if [ -n "${YONI_CLUSTER}" ] ; then
        ask_user_default_yes "you did not specify <cluster> use ? YONI_CLUSTER :${YONI_CLUSTER}";
        if [[ $? -eq 1 ]] ; then
            echo ${YONI_CLUSTER};
            return 0;
        fi;
    fi;

    if [ -e ./.dellclusterruntimeenvbkpfile ] ; then
        last_used_cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ./.dellclusterruntimeenvbkpfile);
    elif [ -e ${dellclusterglobalruntimeenvbkpfile} ] ; then
        last_used_cluster=$(awk -F '='  '/YONI_CLUSTER/{print $2}' ${dellclusterglobalruntimeenvbkpfile});
    fi;

    if [[ "${last_used_cluster}" != "${YONI_CLUSTER}" ]] ; then
        if  [ -n "${last_used_cluster}" ] ; then
            ask_user_default_yes "use ${last_used_cluster} again ?";
            if [[ $? -eq 1 ]] ; then
                echo ${last_used_cluster};
                return 0;
            fi;
        fi;
    fi;

    cluster="$(printf "%s\n" ${trident_cluster_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
    # cluster="$(printf "%s\n" ${!dell_cluster_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
#   if [ -z "${cluster}" ] ; then
#       echo "usage : dellclusterruntimeenvset <cluster name>";
#       return 1;
#   fi;

    echo ${cluster};
    return 0;
}

_dellcyclonebackupuserchoices ()
{
    local backup_restore=${1:-backup};
    if [ -z "${cyclone_folder}" ] ; then
        echo "cyclone_folder not set ! cant backup user choices. use dellclusterruntimeenvset";
        return -1;
    fi;

    if [[ "${backup_restore}" == "backup" ]] ; then
        if [ -e ${cyclone_folder}/.install_choices_bkp ] ; then
            \cp -f ${cyclone_folder}/.install_choices_bkp ~/.install_choices_bkp;
        fi
        if [ -e ${cyclone_folder}/.build_choices_bkp ] ; then
            \cp -f ${cyclone_folder}/.build_choices_bkp ~/.build_choices_bkp;
        fi;
        if [ -e ${cyclone_folder}/.dellclusterruntimeenvbkpfile ] ; then
            \cp -f ${cyclone_folder}/.dellclusterruntimeenvbkpfile ~/.dellclusterruntimeenvbkpfile;
        fi;

    elif [[ "${backup_restore}" == "restore" ]] ; then
        if [ -e ~/.install_choices_bkp ] ; then
            \cp -f  ~/.install_choices_bkp ${cyclone_folder}/.install_choices_bkp;
        fi
        if [ -e ~/.build_choices_bkp ] ; then
            \cp -f  ~/.build_choices_bkp ${cyclone_folder}/.build_choices_bkp;
        fi;
        if [ -e ~/.dellclusterruntimeenvbkpfile ] ; then
            \cp -f  ~/.dellclusterruntimeenvbkpfile ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
        fi;
    else
        echo "unknown command backup_restore=${backup_restore}";
        return -1;
    fi;
}

dellclusterinstall ()
{
    local cluster=${1};
    local asked_user=0;
    local ret=1;
    local deploy_cmd=;
    local reinit_cmd=;
    local create_cluster_cmd=;
    local feature=;
    local cmd_start_time=;
    local deploy_time=0;
    local reinit_time=0;
    local create_cluster_time=0;
    local create_cluster_failed=0;
    local install_choices=;
    local create_cluster_choice=;
    local reinit_choices=;
    local add_feature=;
    local repeat_last_choice=0;

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
    
    cluster=$(echo ${cluster} | awk '{print toupper($0)}');

    echo -e "\nAbout to install cluster ${cluster}\n";
    dellclusterruntimeenvget;
    ask_user_default_yes "Continue ? ";
    [ $? -eq 0 ] && return; 
    

    if [ -e ${cyclone_folder}/.install_choices_bkp ] ; then
        source ${cyclone_folder}/.install_choices_bkp;
        echo "your last install choices were";
        echo "====================================";
        echo -e "${YELLOW} ${deploy_cmd} ${NC}";
        echo -e "${YELLOW} ${reinit_cmd} ${NC}";
        echo -e "${YELLOW} ${create_cluster_cmd} ${NC}\n";

        ask_user_default_no "do it again ?";
        if [ $? -eq 1 ] ; then
            repeat_last_choice=1;
        fi;
    fi;

    if [[ ${repeat_last_choice} == 0 ]] ; then
        install_choices=($(whiptail --checklist "cluster install options" 15 40 5\
                       deploy "install os on cluster" on \
                       reinit "copy files to cluster" on  \
                       cc "create cluster" on 3>&1 1>&2 2>&3));

        if [[ ${install_choices[@]} =~ deploy ]] ; then
            deploy_cmd="./deploy  --deploytype san ${cluster}";
        else
            deploy_cmd=;
        fi;

        if [[ ${install_choices[@]} =~ reinit ]] ; then
            reinit_cmd="./reinit_array.sh factory";

            reinit_choices=($(whiptail --checklist "reinit options" 15 50 5\
                           block "uncheck for unified" on \
                           release "uncheck for debug" on \
                           feature_flag "add feature flag" off  3>&1 1>&2 2>&3));

            if [[ ${reinit_choices} =~ release ]] ; then
                reinit_cmd+=" -F Retail";
            else
                reinit_cmd+=" -F Debug";
            fi;

            if [[ ${reinit_choices} =~ block ]] ; then
                reinit_cmd+=" sys_mode=block";
            else
                reinit_cmd+=" sys_mode=unified";
            fi;

            if [[ ${reinit_choices[@]} =~ feature_flag ]] ; then
                feature=$(dellcyclonefeatureflaglist);
                reinit_cmd+=" feature=\"${feature}\"";
            fi;
        else
            reinit_cmd=;
        fi;

        if [[ ${install_choices[@]} =~ cc ]] ; then

            create_cluster_choice=($(whiptail --radiolist "create cluster script" 15 60 2\
                           cc8 "use create_cluster_centos8.sh" off  \
                           ccpy "use create_cluster.py" on 3>&1 1>&2 2>&3));

            if [[ ${create_cluster_choice[@]} =~ ccpy ]] ; then
                create_cluster_cmd="./create_cluster.py -sys ${cluster}-BM -admin -stdout -y -post";
            else
                create_cluster_cmd="./create_cluster_centos8.sh -sys ${cluster}-BM -admin -stdout -y -post";
            fi;

        else
            create_cluster_cmd=;
        fi;
    fi;

    if [ -z "${deploy_cmd}" ] && [ -z "${reinit_cmd}" ] && [ -z "${create_cluster_cmd}" ] ; then
        echo "nothing to do. bailing out!";
        return 0;
    fi;

    if [[ "${YONI_CLUSTER}" != "${cluster}" ]] ; then
        echo -e "${RED}cannot install ${clutster} while CYC_CONFIG points to ${YONI_CLUSTER}${NC}";
        return -1;
    fi;

    if [ ${repeat_last_choice} -eq 0 ] ; then
        echo -e "${YELLOW} ${deploy_cmd} ${NC}";
        echo -e "${YELLOW} ${reinit_cmd} ${NC}";
        echo -e "${YELLOW} ${create_cluster_cmd} ${NC}";
        ask_user_default_yes "continue";
        if [ $? -eq 0 ] ; then
            return 0;
        fi;
    fi;

    ddd;
    echo "install_date=\"$(now)\"" > ${cyclone_folder}/.install_choices_bkp;
    echo "deploy_cmd=\"${deploy_cmd}\"" >> ${cyclone_folder}/.install_choices_bkp;
    echo "reinit_cmd=\"${reinit_cmd}\"" >> ${cyclone_folder}/.install_choices_bkp;
    echo "create_cluster_cmd=\"${create_cluster_cmd}\"" >> ${cyclone_folder}/.install_choices_bkp;
    echo "install_branch=$(git bb)" >> ${cyclone_folder}/.install_choices_bkp;
    echo "install_pdr=${cyclone_folder}" >> ${cyclone_folder}/.install_choices_bkp;
    echo "install_pdr_git_index=$(git hh)" >> ${cyclone_folder}/.install_choices_bkp;

    dellcdclusterscripts;

    echo "==> $(pwd)";

    #############################################
    #            deploy
    #############################################
    if [[ -n "${deploy_cmd}" ]] ; then
        echo "============================================================================================================";
        echo -e "${BLUE}\t\t\t${deploy_cmd} ${NC}";
        echo "============================================================================================================";
        cmd_start_time=${SECONDS};
        eval ${deploy_cmd};
        if [[ $? -ne 0 ]] ; then 
            while (( 1 == $(ask_user_default_yes "retry deploy ? " ; echo $?) )) ; do
                echo -e "\n${BLUE}\t\t\t${deploy_cmd} ${NC}\n";
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
        deploy_time=$(( (${SECONDS} - ${cmd_start_time}) ));
        deploy_time="$(date -u -d @"${deploy_time}" +'%-Mm %-Ss')";
        echo -e "deploy_time=\"${deploy_time}\"" >> ${cyclone_folder}/.install_choices_bkp;
        echo -e "\n${GREEN}\t\t\t deploy succeeded ( after ${deploy_time} )${NC}";
    fi;

    #############################################
    #            reinit
    #############################################
    if [[ -n "${reinit_cmd}" ]] ; then
        echo "============================================================================================================";
        echo -e "${BLUE}\t\t\t${reinit_cmd} ${NC}";
        echo "============================================================================================================";
        cmd_start_time=${SECONDS};
        eval ${reinit_cmd};
        ret=$?;
        if [[ ${ret} -ne 0 ]] ; then 
            echo -e "${RED}\t\t\t reinit failed ! ! ! ${NC}";
            while (( 1 == $(ask_user_default_yes "retry reinit ? " ; echo $?) )) ; do
                echo -e "\n${BLUE}\t\t\t${reinit_cmd} ${NC}\n";
                eval ${reinit_cmd};
                ret=$?
                if [ ${ret} -ne 0 ] ; then
                    echo -e "${RED}\t\t reinit failed ! ! ! ${NC}";
                    continue;
                else
                    break;
                fi;
            done;

            if [[ ${ret} -ne 0 ]] ; then 
                echo -e "${RED}\t\t reinit failed ! ! ! ${NC}";
                return -1;
            fi;
        fi;

        reinit_time=$(( (${SECONDS} - ${cmd_start_time}) ));
        reinit_time="$(date -u -d @"${reinit_time}" +'%-Mm %-Ss')";
        echo -e "reinit_time=\"${reinit_time}\"" >> ${cyclone_folder}/.install_choices_bkp;
        echo -e "\n${GREEN}\t\t\t reinit succeeded ( after ${reinit_time} )${NC}\n";
    fi;


    #############################################
    #            create_cluster
    #############################################
    if [[ -n "${create_cluster_cmd}" ]] ; then
        echo "============================================================================================================";
        echo -e "${BLUE}\t\t\t${create_cluster_cmd} ${NC}";
        echo "============================================================================================================";
        cmd_start_time=${SECONDS};
        eval ${create_cluster_cmd};
        if [[ $? -ne 0 ]] ; then 
            create_cluster_failed=1;
            echo -e "${RED}\t\tcreate_cluster failed ! ! !${NC}";
            while (( 1 == $(ask_user_default_yes "retry with create_cluster_centos8.sh ? " ; echo $?) )) ; do
                create_cluster_cmd="./create_cluster_centos8.sh -sys ${cluster}-BM -admin -stdout -y -post";

                echo -e "\n${BLUE}\t\t\t${create_cluster_cmd} ${NC}\n";
                eval ${create_cluster_cmd};

                if [[ $? -ne 0 ]] ; then
                    echo -e "\n${RED}\t\tcreate_cluster failed ! ! !${NC}";
                    continue;
                else
                    create_cluster_failed=0;
                    break;
                fi;

            done;
        else
            create_cluster_time=$(( (${SECONDS} - ${cmd_start_time}) ));
            create_cluster_time="$(date -u -d @"${create_cluster_time}" +'%-Mm %-Ss')";
            echo -e "create_cluster_time=\"${create_cluster_time}\"" >> ${cyclone_folder}/.install_choices_bkp;
            echo -e "\n${GREEN}\t\t\tcreate_cluster succeeded ( after ${create_cluster_time} )${NC}";
        fi;

        if [ 1 -eq ${create_cluster_failed} ] ; then
            return -1;
        fi;
    fi;

    echo -e "\t${CYAN}deploy         : ${deploy_time} ${NC}";
    echo -e "\t${CYAN}reinit         : ${reinit_time} ${NC}";
    echo -e "\t${CYAN}create_cluster : ${create_cluster_time} ${NC}";
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

    # for cyc_core changes add "sym"
	# time ./fast_code_loader.sh sym -r 10 -o -w ${cyc_core_folder};
    #
	time ./fast_code_loader.sh 10 -o -w ${cyc_core_folder};
	
    echo "about to copy nt-nvmeof-frontend to node-b";
	echo "./fast_code_loader.sh 11 -o -w ${cyc_core_folder}";
	ask_user_default_yes "continue ?"
	if [ $? -eq 0 ] ; then
        dellcdcyclonefolder;
        return 0;
    fi;

    # for cyc_core changes add "sym"
	# time ./fast_code_loader.sh sym -r 11 -o -w ${cyc_core_folder};
    #

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

# dellclusteryonienvupdate ()
# {
#     local cluster=${1};
# 
#     if [ -z "${cluster}" ] ; then 
#         cluster=$(_dellclusterget);
#         if [ -z ${cluster} ] ; then
#             echo "${FUNCNAME} <cluster>"; 
#             return -1;
#         fi;
#     fi;
# 
#     # if [[ $(hostname|grep arwen|wc -l) == 0 ]] ; then
#         # echo "you must be in arwen";
#         # return;
#     # fi;
# 
#     _dellclusterruntimeenvvalidate;
#     if [[ $? -ne 0 ]] ; then
#         return -1;
#     fi;
# 
#     ask_user_default_yes "update ${cluster} ?";
#     [ $? -eq 0 ] && return -1;
# 
#     dellcdclusterscripts;
# 
#     sed -i "1s/YONI_CLUSTER=.*/YONI_CLUSTER=${cluster}/" ~/yonienv/scripts/yonidell.sh;
# 
#     echo "copy yonidell.sh -> core-a@${cluster}";
#     ./scp_core_to_a.sh ~/yonienv/scripts/yonidell.sh
#     echo "copy vimrcyoni.sh -> core-a@${cluster}";
#     ./scp_core_to_a.sh ~/yonienv/scripts/vimrcyoni.vim
#     echo "copy yonidell.sh -> core-b@${cluster}";
#     ./scp_core_to_b.sh ~/yonienv/scripts/yonidell.sh
#     echo "copy vimrcyoni.vim -> core-b@${cluster}";
#     ./scp_core_to_b.sh ~/yonienv/scripts/vimrcyoni.vim
# 
#     echo "copy yonidell.sh -> bsc-a@${cluster}";
#     ./scp_cyc_to_a.sh ~/yonienv/scripts/yonidell.sh;
#     # ./run_core_a.sh 'docker cp yonidell.sh   cyc_bsc_docker:/home/cyc/';
#     echo "copy vimrcyoni.vim -> bsc-a@${cluster}";
#     ./scp_cyc_to_a.sh ~/yonienv/scripts/vimrcyoni.vim;
#     # ./run_core_a.sh 'docker cp vimrcyoni.vim cyc_bsc_docker:/home/cyc/';
#     echo "copy yonidell.sh -> bsc-b@${cluster}";
#     ./scp_cyc_to_b.sh ~/yonienv/scripts/yonidell.sh;
#     # ./run_core_b.sh 'docker cp yonidell.sh   cyc_bsc_docker:/home/cyc/';
#     echo "copy vimrcyoni.vim -> bsc-b@${cluster}";
#     ./scp_cyc_to_b.sh ~/yonienv/scripts/vimrcyoni.vim;
#     # ./run_core_b.sh 'docker cp vimrcyoni.vim cyc_bsc_docker:/home/cyc/';
# 
#     sed -i "1s/YONI_CLUSTER=.*/YONI_CLUSTER=/" ~/yonienv/scripts/yonidell.sh;
#     cd -
# }

scp2core ()
{
    local cluster=${1};
    local node=${2};
    local file=${3};

    if [ -z "${3}" ] ; then
        file=${yonienv}/scripts/*yoni*
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    if [[ -z "${node}" ]] ; then
        read -p "[a|b|default BOTH] : " node;
        if [ "${node}" = 'a' ] ; then
            node=-a;
        elif [ "${node}" = 'b' ] ; then
            node=-b;
        fi;
    fi;

    if [ ${node} == BOTH ] ; then
        node=;
    fi;

    echo -e "\t${BLUE}xxscp ${cluster}${node} ${file} :/home/core/${NC}";
    xxscp ${cluster}${node} ${file} :/home/core/
}

scp2bsc ()
{
    local cluster=${1};
    local node=${2};
    local file=${3};

    if [ -z "${3}" ] ; then
        file=${yonienv}/scripts/*yoni*
    fi;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    if [[ -z "${node}" ]] ; then
        read -p "[a|b|default BOTH] : " node;
        if [ "${node}" = 'a' ] ; then
            node=-a;
        elif [ "${node}" = 'b' ] ; then
            node=-b;
        fi;
    fi;
     
    if [ ${node} == BOTH ] ; then
        node=;
    fi;

    echo -e "\t${BLUE}xxbsc_scp ${cluster}${node} ${file} :/home/cyc/${NC}";
    xxbsc_scp ${cluster}${node} ${file} :/home/cyc/
}

dellclusteryonienvupdate ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    scp2core ${cluster} BOTH;
    scp2bsc ${cluster} BOTH;
}

_dellclusterrestartbsc ()
{
    local node=${1};
    local cluster=${2};

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

	ask_user_default_no "restart ${cluster} node ${node} ?";
	[ $? -eq 0 ] && return -1;

	dellcdclusterscripts;
    if [ ${node} == 'a' ] ; then
        echo "./do_bsc_down_a.sh";
        ./do_bsc_down_a.sh;
        echo "./do_bsc_up_a.sh";
        ./do_bsc_up_a.sh;
    else
        echo "./do_bsc_down_b.sh";
        ./do_bsc_down_b.sh;
        echo "./do_bsc_up_b.sh";
        ./do_bsc_up_b.sh;
    fi;
}

alias dellclusterrestartbscnode-a="_dellclusterrestartbsc a";
alias dellclusterrestartbscnode-b="_dellclusterrestartbsc b";

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

delllastusedlgbkpfile=~/.delllastusedlgbkpfile;
ssh2lg ()
{
    local lg_name=${1};
    local use_backup=0;

    if [[ -z ${lg_name} ]]; then 
        if [ -e ${delllastusedlgbkpfile} ] ; then
            lg_name=$(cat ${delllastusedlgbkpfile});
            ask_user_default_yes "use ${lg_name} again ";
            if [ $? -eq 0 ] ; then
                lg_name=;
            else
                use_backup=1;
            fi;
        fi;
    fi;

    if [[ -z ${lg_name} ]]; then 
        lg_name="$(printf "%s\n" ${lg_list[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    fi;

    if [[ -z ${lg_name} ]]; then 
        echo "missing LG_NAME param" 
        return -1;
    fi;

    if [[ ${use_backup} == 0 ]] ; then
        ask_user_default_yes "ssh2lg ${lg_name} ? ";
        if [[ $? -eq 0 ]] ; then return 0 ; fi;
    fi;

    if ! [[ ${lg_list[@]} =~ ${lg_name} ]] ; then
        echo ${lg_name} >> ${lg_list_file};
        lg_list+=" ${lg_name}";
        echo -e "${RED}added ${lg_name} to saved lgs${NC}";
    fi;

    echo ${lg_name} > ${delllastusedlgbkpfile};

    echo "ssh root@${lg_name}";
    sshpass -p Password123! ssh -o 'PubkeyAuthentication no' -o LogLevel=ERROR -F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  root@${lg_name};
}

dellcyclonegrepconfig ()
{
    local p=${1:-pdu};

    _dellclusterruntimeenvvalidate;
    [ $? -ne 0 ] && return;

    grep -i $p ${CYC_CONFIG};
}

alias delleditclusterconfig='v ${CYC_CONFIG}'
alias delleditlglist="v ${lg_list_file}";
lg_list_file=~/yonienv/bashrc_dell_lg_list_file
lg_list=( $(cat ${lg_list_file} ));
complete -W "$(echo ${lg_list[@]})" ssh2lg;

dellclusteraddtolist ()
{ 
    local cluster=${1};

    if [[ -z "${cluster}" ]] ; then
        return -1;
    fi;

     _add_cluster_to_list ${cluster};
}

dellclusterping ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    _dellclusterlistaddcluster ${cluster};

    echo "swarm ${cluster} -ping --showallips";
    swarm  ${cluster} -ping --showallips;
}

dellclusteripget ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo "swarm --showipinfo ${cluster}";
    swarm --showipinfo ${cluster};
}

dellclusterlgipget ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    # echo -e "xxlabjungle cluster \"name:${cluster}\" |  jq -r '.objects[0].lgs[0]'";
    # xxlabjungle cluster "name:${cluster}" |  jq -r '.objects[0].lgs[0]';

    # num_of_lgs=$(xxlabjungle cluster "name:${cluster}" |  jq ".objects[0].lgs | length"
    # echo -e "xxlabjungle cluster \"name:${cluster}\" |  jq | grep -A 3 lgs";
    # xxlabjungle cluster "name:${cluster}" |  jq | grep -A 3 lgs;
    xxlabjungle cluster "name:${cluster}" | jq -r '.objects[].lgs[]';
}

ssh2lgofcluster ()
{
    local cluster=${1};
    local lg;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    lg_arr=( $(dellclusterlgipget ${cluster}) );

    echo "lg_arr: ${lg_arr[@]}";

    if [[ ${#lg_arr[@]} -gt 1 ]] ; then
        echo "${lg_arr[@]}";
        return;
    fi;

    lg=${lg_arr[0]};

    ssh2lg ${lg};
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
 
dellclustereditcycconfig ()
{
    _dellclusterruntimeenvvalidate
    if [[ $? -ne 0 ]] ; then
        return -1;
    fi;

    v ${CYC_CONFIG};
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

dellcdqlasources ()
{
    if [ -d ${cyclone_folder} ] ; then
        cd ${cyclone_folder}/source/third_party/cyc_platform/src/third_party/QLA/qla2xxx/src/;
        return 0;
    fi;
 
    return -1;
}

dellcdbroadcommakefiles ()
{
    if [ -z ${cyclone_folder} ] ; then
        echo -e "${RED}cyclone_folder empty! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    if ! [ -d ${cyclone_folder} ] ; then
        echo -e "${RED}${cyclone_folder} does not exist! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    if ! [ -d ${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS ] ; then
        echo -e "${RED}missing broadcom folder. try the feature branch feature/pl-trif-2474-brcm-fc-64gb${NC}";
        return -1;
    fi;

    cd ${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS;
    return 0;

}

delldeletebroadcomsources ()
{
    local platform_debug=source/third_party/cyc_platform/obj_Debug;
    local platform_release=source/third_party/cyc_platform/obj_Release;
    local broadcom_src=third_party/BRCM_OCS/;
    local broadcom=;

    if [ -z ${cyclone_folder} ] ; then
        echo -e "${RED}cyclone_folder empty! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    if ! [ -d ${cyclone_folder} ] ; then
        echo -e "${RED}${cyclone_folder} does not exist! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    broadcom=${cyclone_folder}
    if [ -e ${broadcom}/${platform_debug} ] ; then
        broadcom=${broadcom}/${platform_debug};
    elif [ -e ${broadcom}/${platform_release} ] ; then
        broadcom=${broadcom}/${platform_release};
    else
        echo "missing : "
        echo "${cyclone_folder}/${platform_debug}";
        echo "${cyclone_folder}/${platform_release}";
        echo "you should : make third_party force=yes flavor=<DEBUG|RELEASE>";
        return -1;
    fi;

    broadcom=${broadcom}/${broadcom_src};

    if [ -d ${broadcom} ] ; then
        ask_user_default_no "delete ${broadcom}";
        if [ $? -eq 1 ] ; then
            rm -rf ${broadcom};
        fi;
    else
        echo "missing folder ${broadcom}";
        echo -e "${RED}missing broadcom folder. try the feature branch feature//pl-trif-2474-brcm-fc-64gb${NC}";
        return -1;
    fi;
}

dellcdthirdpartyobjects ()
{
    local platform_debug=source/third_party/cyc_platform/obj_Debug;
    local platform_release=source/third_party/cyc_platform/obj_Release;
    local thirdpartyobjects=;

    if [ -z ${cyclone_folder} ] ; then
        echo -e "${RED}cyclone_folder empty! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    if ! [ -d ${cyclone_folder} ] ; then
        echo -e "${RED}${cyclone_folder} does not exist! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    thirdpartyobjects=${cyclone_folder}
    if [ -e ${thirdpartyobjects}/${platform_debug} ] ; then
        thirdpartyobjects=${thirdpartyobjects}/${platform_debug};
    elif [ -e ${thirdpartyobjects}/${platform_release} ] ; then
        thirdpartyobjects=${thirdpartyobjects}/${platform_release};
    else
        echo "missing : "
        echo "${cyclone_folder}/${platform_debug}";
        echo "${cyclone_folder}/${platform_release}";
        echo "you should : make third_party force=yes flavor=<DEBUG|RELEASE>";
        return -1;
    fi;
    
    thirdpartyobjects=${thirdpartyobjects}/third_party;

    if [ -d ${thirdpartyobjects} ] ; then
        cd ${thirdpartyobjects};
    else
        echo "missing folder ${thirdpartyobjects}";
        return -1;
    fi;
    return 0;
}

dellcdbroadcomsources ()
{
    local platform_debug=source/third_party/cyc_platform/obj_Debug;
    local platform_release=source/third_party/cyc_platform/obj_Release;
    local broadcom_src=third_party/BRCM_OCS/src/BRCM_OCS;
    local broadcom=;

    if [ -z ${cyclone_folder} ] ; then
        echo -e "${RED}cyclone_folder empty! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    if ! [ -d ${cyclone_folder} ] ; then
        echo -e "${RED}${cyclone_folder} does not exist! use dellclusterruntimeenvset${NC}"; 
        return -1;
    fi;

    broadcom=${cyclone_folder}
    if [ -e ${broadcom}/${platform_debug} ] ; then
        broadcom=${broadcom}/${platform_debug};
    elif [ -e ${broadcom}/${platform_release} ] ; then
        broadcom=${broadcom}/${platform_release};
    else
        echo "missing : "
        echo "${cyclone_folder}/${platform_debug}";
        echo "${cyclone_folder}/${platform_release}";
        echo "you should : make third_party force=yes flavor=<DEBUG|RELEASE>";
        return -1;
    fi;

    broadcom=${broadcom}/${broadcom_src};

    if [ -d ${broadcom} ] ; then
        cd ${broadcom};
    else
        echo "missing folder ${broadcom}";
        echo -e "${RED}missing broadcom folder. try the feature branch feature//pl-trif-2474-brcm-fc-64gb${NC}";
        return -1;
    fi;

    echo "makefiles and patches in";
    echo "==============================";
    echo "${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS";
    return 0;
}

dellcdkernelmodules ()
{
    if [ -d ${cyclone_folder} ] ; then
        if [ -d ${cyclone_folder}/source/cyc_core/cyc_platform/obj_Release ] ; then
            cd ${cyclone_folder}/source/cyc_core/cyc_platform/obj_Release/package/final/top_host/cyc_host/cyc_common/modules
        elif [ -d ${cyclone_folder}/source/cyc_core/cyc_platform/obj_Debug ] ; then
            cd ${cyclone_folder}/source/cyc_core/cyc_platform/obj_Debug/package/final/top_host/cyc_host/cyc_common/modules
        else
            echo -e "${RED}modules are not built yet${NC}";
            return -1;
        fi;
        return 0;
    fi; 

    echo -e "${RED}cyclone_folder not defined!!${NC}";
    return -1;
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
    if [[ -z "${pnvmet_folder}" ]] ; then
        echo "pnvmet_folder not set, (use dellcyclonekernelshaupdate)";
        return -1;
    fi;

    cd ${pnvmet_folder};
}

complete -W "$(find -maxdepth 1 -type f -name "*mdt-*")" dellcdmdt;
dellcdmdt ()
{
    local mdt_file=${1};
    if [ -z "${mdt_file}" ] ; then
        complete -W "$(find -maxdepth 1 -type f -name "*mdt-*")" dellcdmdt;
        find  -maxdepth 1 -type f -name "*mdt-*";
        return;
    fi;
    cd $(cat ${mdt_file} | grep jiraproduction);
}

dellcyclonekernelshaupdate ()
{
    local sha=${1};
    local mfile=${third_party_folder}/CMakeLists.txt
    
    # make sure dest file/folder exist.
    if [[ -z "${third_party_folder}" ]] ; then
        echo "runtime env not set"
        return -1;
    fi;
    
    if ! [[ -f ${mfile} ]] ; then
        echo "${mfile} not found";
        return -1;
    fi;

    # if user did not supply sha, we can still use HEAD
    if [[ -z "${sha}" ]] ; then
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
        # sha=$(git log -1 | awk '/commit/{print $2}');
        sha=$(cat .git/refs/heads/$(git bb));
        echo -e "you did not supply commit sha. using HEAD \033[1;35m${sha}\033[0m";
        #dellcyclonebuildhistorylog $(pwd) $(git bb) $(git h);
        export pnvmet_folder=$(pwd);
        if [[ -n "${cyclone_folder}/.dellclusterruntimeenvbkpfile" ]] ; then
            if [ $(grep pnvmet_folder ${cyclone_folder}/.dellclusterruntimeenvbkpfile | wc -l ) -gt 0 ] ; then
                p=$(echo $pnvmet_folder |sed 's/\//\\\//g');
                sed -i "s/pnvmet_folder=.*/pnvmet_folder=${p}/g" ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
            else
                echo "export pnvmet_folder=${pnvmet_folder}" >> ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
            fi;

            #echo "updated pnvmet_folder in ${cyclone_folder}/.dellclusterruntimeenvbkpfile";

            #ask_user_default_yes "also update global runtime env file ?"
            #if [ $? -eq 1 ] ; then
                if [ $(grep pnvmet_folder ${dellclusterglobalruntimeenvbkpfile} | wc -l ) -gt 0 ] ; then
                    p=$(echo $pnvmet_folder |sed 's/\//\\\//g');
                    sed -i "s/pnvmet_folder=.*/pnvmet_folder=${p}/g" ${dellclusterglobalruntimeenvbkpfile};
                else
                    echo "export pnvmet_folder=${pnvmet_folder}" >> ${dellclusterglobalruntimeenvbkpfile};
                fi;
            #fi;
        fi;
    fi
    
    echo -e "update ${RED}${mfile}${NC} with ${GREEN}${sha}${NC}";
    ask_user_default_yes "continue ";
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
    local jira_ticket=${1:-31903};
    local module=${2:-nt};
     
    if [[ $# -ne 2 ]] ; then
        echo "usage: $FUNCNAME <jira ticket> <module>"
    fi;
 
    if [ -n "${jira_ticket}" ] ; then 
        sed -i "s/\[TRIES-.*\]/\[TRIES-${jira_ticket}\]/g" ${yonienv}/git_templates/git_commit_dell_template;
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

alias delljournalctl-all-logs-node-a='_delljournalctl a all'
alias delljournalctl-all-logs-node-b='_delljournalctl b all'
alias delljournalctl-kernel-logs-node-a='_delljournalctl a kernel'
alias delljournalctl-kernel-logs-node-b='_delljournalctl b kernel'
alias delljournalctl-nt-logs-node-a='_delljournalctl a nt'
alias delljournalctl-nt-logs-node-b='_delljournalctl b nt'
#delljournalctl-nt-logs-node-a ()
#{
    #local since="${1}";
    #local options="--utc SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_a/var/log/journal";

    #if [[ -n "${since}" ]] ; then
        #eval journalctl --since=\"${since}\" ${options} | less -N -I
    #else
        #eval journalctl ${options}  | less -N -I
    #fi;
#}

#delljournalctl-nt-logs-node-b ()
#{
    #local since="${1}";
    #local options="--utc SUB_COMPONENT=nt --no-pager -o short-precise -a -D node_b/var/log/journal";

    #if [[ -n "${since}" ]] ; then
        #eval journalctl --since=\"${since}\" ${options} | less -N -I
    #else
        #eval journalctl ${options} | less -N -I
    #fi;
#}

#delljournalctl-all-logs-node-a ()
#{
    #local since="${1}";
    #local options="--utc --no-pager -o short-precise -a -D node_a/var/log/journal";

    #if [[ -n "${since}" ]] ; then
        #eval journalctl --since=\"${since}\" ${options} | less -N -I
    #else
        #eval journalctl ${options} | less -N -I
    #fi;
#}

#delljournalctl-all-logs-node-b ()
#{
    #local since="${1}";
    #local options="--utc --no-pager -o short-precise -a -D node_b/var/log/journal";

    #if [[ -n "${since}" ]] ; then
        #eval journalctl --since=\"${since}\" ${options} | less -N -I
    #else
        #eval journalctl ${options} | less -N -I
    #fi;
#}

dell-mount-home-qa ()
{
    mount 10.55.160.100:/home/qa /home/qa;
}

dell-mount-jiraproduction ()
{
    sudo mount cecaunity01-nas.corp.emc.com:/jiraproduction /disks/jiraproduction;
    sudo mount cecaunity01-nas.corp.emc.com:/jiraproduction2 /disks/jiraproduction2
}

dell-mount-public-devutils ()
{
    sudo mkdir /home/public
    sudo mount -o nolock file.xiodrm.lab.emc.com:/home/public /home/public
}
 
if ! [ -d /disks/jiraproduction ]  || ! [ -d /disks/jiraproduction2 ] ; then
    echo "/disks/jiraproduction not mounted";
    echo "use dell_mount_jiraproduction";
fi


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

alias delltriage-grep-panic-a='delltriage-all-logs-node-a | grep --color "PANIC\|log_backtrace_backend\|panic-\|signal_handler"'
alias delltriage-grep-panic-b='delltriage-all-logs-node-b | grep --color "PANIC\|log_backtrace_backend\|panic-\|signal_handler"'

alias delltriage-grep-connect-a='delltriage-nt-logs-node-a | grep --color "nvme.*alloc"'
alias delltriage-grep-connect-b='delltriage-nt-logs-node-b | grep --color "nvme.*alloc"'

alias delltriage-grep-connect-queue-a='delltriage-all-logs-node-a | grep --color "process_connec.*sq_id\|install.*queu\|fc_.*alloc.*queue\|fc_.*create_association\|nvme.*allocate\|discover.*allocate"'
alias delltriage-grep-connect-queue-b='delltriage-all-logs-node-b | grep --color "process_connec.*sq_id\|install.*queu\|fc_.*alloc.*queue\|fc_.*create_association\|nvme.*allocate\|discover.*allocate"'

alias delltriage-grep-disconnect-queue-a='delltriage-all-logs-node-a | grep --color "pnvmet_disconnect|nvmet_fc_fcp_disconnec\|nvmet_tcp_disconnect\|io_ctrl.*disconnect"'
alias delltriage-grep-disconnect-queue-b='delltriage-all-logs-node-b | grep --color "pnvmet_disconnect|nvmet_fc_fcp_disconnec\|nvmet_tcp_disconnect\|io_ctrl.*disconnect"'

alias delltriage-grep-add-port-a='delltriage-nt-logs-node-a | grep --color "add_ports.*is_local true"'
alias delltriage-grep-add-port-b='delltriage-nt-logs-node-b | grep --color "add_ports.*is_local true"'

alias delltriage-grep-nt-start-a='delltriage-nt-logs-node-a | grep --color "nt_start"'
alias delltriage-grep-nt-start-b='delltriage-nt-logs-node-b | grep --color "nt_start"'

alias delltriage-grep-set-active-a='delltriage-nt-logs-node-a | grep --color "nt_disc_set_active\|nt_disc_set_inactive"'
alias delltriage-grep-set-active-b='delltriage-nt-logs-node-b | grep --color "nt_disc_set_active\|nt_disc_set_inactive"'

alias delltriage-grep-pnvmet-start-a='delltriage-kernel-log-node-a | grep --color "nvmet_power.*driver.*start"'
alias delltriage-grep-pnvmet-start-b='delltriage-kernel-log-node-b | grep --color "nvmet_power.*driver.*start"'

alias delltriage-grep-cluster-name-a='delltriage-all-logs-node-a | grep -i --color "cyc_config.*creating cluster"'
alias delltriage-grep-cluster-name-b='delltriage-all-logs-node-b | grep -i --color "cyc_config.*creating cluster"'

alias delltriage-servicemode-logs-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -t servicemode"
alias delltriage-servicemode-logs-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -t servicemode"

alias delltriage-grep-nt-kernel-a='delltriage-all-logs-node-a |grep "\[nt\]\|kernel"|less -I'
alias delltriage-grep-nt-kernel-b='delltriage-all-logs-node-b |grep "\[nt\]\|kernel"|less -I'

# howto
# journalctl SUBCOMPONENT=nt
# journalctl -o short-precise --since "2022-07-04 07:56:00"

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

