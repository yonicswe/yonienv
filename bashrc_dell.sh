#!/bin/bash

alias editbashdell='v ${yonienv}/bashrc_dell.sh'


declare -A user_to_devvm;
user_to_devvm["yonic"]="10.227.209.251"
user_to_devvm["yonic2"]="10.227.227.201"
user_to_devvm["chuck"]="10.244.232.75"
user_to_devvm["elad"]="drmcyc-s-drmcyc-grupie.cec.delllabs.net"
user_to_devvm["jean"]="10.244.234.33"
user_to_devvm["yoni-hop"]="10.244.229.90"
user_to_devvm["jim"]="10.227.210.128"
#complete -W "amit elad irit dord yoni1 yoni2" ssh2devvm ssh2devvmsetup
complete -W "$(echo ${!user_to_devvm[@]})" ssh2devvm ssh2devvmsetup

# yonivmipaddress="10.244.196.235"
#yonivmipaddress="10.227.212.155"
#yonivm2ipaddress="10.227.212.133"
#alias ssh2yonivm="sshpass -p cycpass ssh cyc@${yonivmipaddress}"
#alias ssh2yonivm2="sshpass -p cycpass ssh cyc@${yonivm2ipaddress}"

_ssh_set_passwordless_cyc_for_devvm ()
{
    local user=${1};
    local devvm_ip_address=;

    if [ -z "${user}" ] ; then
        echo "error: missing user";
        return -1;
    fi;

    devvm_ip_address=${user_to_devvm["${user}"]};
    if [[ -z "${devvm_ip_address}" ]] ; then
        echo "unkonwn user: ${user}";
        return -1;
    fi;

    echo "ssh-copy-id -i ~/.ssh/id_rsa.pub cyc@${devvm_ip_address}";
    ssh-copy-id -i ~/.ssh/id_rsa.pub cyc@${devvm_ip_address};
    return 0;
}

_ssh_2_dev_vm_for_user ()
{
    local user=${1};
    local devvm_ip_address=;

    if [ -z "${user}" ] ; then
        user="$(printf "%s\n" $(echo ${!user_to_devvm[@]}) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        if [ -z "${user}" ] ; then
            echo "error: missing user";
            return -1;
        fi;
    fi;

    devvm_ip_address=${user_to_devvm["${user}"]};
    if [[ -z "${devvm_ip_address}" ]] ; then
        echo "unkonwn user: ${user}";
        return -1;
    fi;

    echo -e "${PURPLE}ssh to ${user}${NC}";
    echo "sshpass -p cycpass ssh cyc@${devvm_ip_address}";
    sshpass -p cycpass ssh cyc@${devvm_ip_address};
    return 0;
}

alias ssh2devvmsetup='_ssh_set_passwordless_cyc_for_devvm'
alias ssh2devvm='_ssh_2_dev_vm_for_user'

_ssh_2_jnode ()
{
    sshpass -p cycpass ssh cyc@$1;
}
complete -W "jnode-fw1 jnode-fw10 jnode-fw36 jnode-fw40 jnode-fw43 jnode-fw56 jnode-fw57 jnode-fw39" ssh2jnode
alias ssh2jnode='_ssh_2_jnode'

export YONI_CLUSTER=;
export CYC_CONFIG=;

dell_clusters_file=${yonienv}/bashrc_dell_clusters.sh;
dell_cluster_list_file=${yonienv}/bashrc_dell_cluster_list_file.sh;
alias delleditclusterlist="v ${dell_clusters_file}";
export dell_leased_clusters=~/.dell_leased_clusters
alias delleditleasedclusters="v ${dell_leased_clusters}"
alias dellleasedclusters="cat ${dell_leased_clusters}"
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
    complete -W "$(echo ${trident_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaseRelease dellclusterdeploy dellclusterleasewithforce dellclusteryonienvupdate
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

dellpnvmetclone ()
{
    local start_time=$SECONDS
    git clone --branch pnvmet/main --single-branch git@eos2git.cec.lab.emc.com:cyclone/linux.git pnvmet
    local clone_rc=$?
    local elapsed=$((SECONDS - start_time))
    echo "git clone took ${elapsed} seconds"
    if [ $clone_rc -ne 0 ]; then
        echo "git clone failed"
        return $clone_rc
    fi
    cd pnvmet || return
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    ask_user_default_no "fetch now ? it might take a while"
    if [ $? -eq 0 ]; then
        return
    fi
    git fetch origin --prune
}

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

dellcyclonecheckcout ()
{
    local pdr_folder_name=${1:-cyclone};
    local branch=${2:-pub/int-pl};
    local update_all=0;

	echo "git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git ${pdr_folder_name}";
    ask_user_default_no "continue with ${pdr_folder_name}";
    if [ $? -eq 0 ] ; then return; fi;

    ask_user_default_yes "checkout ${branch} ?";
    if [ $? -eq 0 ] ; then
        read  -p "which branch to checkout ? : " branch;
    fi;

    ask_user_default_no "update all submodules ? ";
    if [ $? -eq 1 ] ; then
        update_all=1;
    fi;

    echo "about to do the following : ";
    echo "===============================";
    echo "git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git ${pdr_folder_name}";
    echo "cd ${pdr_folder_name}";
    echo "git checkout -b ${branch} origin/${branch}";

    if [ ${update_all} -eq 1 ] ; then
            echo "git smupdateinitallsubmodules";
    else
       #echo "git submodule update --init source/cyc_core";
       echo "git submodule update --init source/nt-nvmeof-frontend";
    fi;

    ask_user_default_no "continue ?"
    if [ $? -eq 0 ] ; then return; fi;

	git clone git@eos2git.cec.lab.emc.com:cyclone/cyclone.git ${pdr_folder_name};
	cd ${pdr_folder_name};
    git checkout -b ${branch} origin/${branch};

    if [ ${update_all} -eq 1 ] ; then
        ask_user_default_no "about to update all submodules which will take a while. continue ?";
        if [ $? -eq 1 ] ; then
            git smupdateinitallsubmodules;
        else
            update_all=0;
        fi;
    fi;

    if [ ${update_all} -eq 0 ] ; then
        #git submodule update --init source/cyc_core
        git submodule update --init source/nt-nvmeof-frontend
    fi;

}

dellpnvmettagsupdate ()
{
    if [ -z ${cyclone_folder} ] ; then
        echo "cyclone folder not defined";
        return -1;
    fi;

    if ! [ -d ${cyclone_folder} ] ; then
        echo "${cyclone_folder} does not exist";
        return -1;
    fi;

    if [[ -e ${pnvmet_folder} ]] ; then
        cd ${pnvmet_folder};
    else
        echo -e "${RED}missing pnvmet_folder (do rd)${NC}";
        return -1;
    fi;

    if [[ -e tags.vim && $(grep cs tags.vim | wc -l) -gt 0 ]] ; then
        ask_user_default_yes "retag ?"
        if [ $? -eq 1 ] ; then
            cat tags.vim |grep cs|awk '{print $3}' | while read s ; do c $(dirname $s)  ; ttt ; c -  ; done
            return;
        fi;
    fi;

    build_choices=($(whiptail --checklist "pnvmet tags" 13 30 6\
                   linux "" off\
                   cyc_core "" off  \
                   third_party "" off \
                   broadcom "" off \
                   qlogic "" off \
                   nt-nvmeof-frontend "" off 3>&1 1>&2 2>&3));


    echo "set noexpandtab" > tags.vim;
    echo "cs a cscope.out" >> tags.vim;
    echo "set tags=tags" >> tags.vim;
 
    if [[ ${build_choices[@]} =~ nt-nvmeof-frontend ]] ; then
        dst_folder=source/nt-nvmeof-frontend;
        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;
    fi;
    if [[ ${build_choices[@]} =~ cyc_core ]] ; then
        dst_folder=source/cyc_core;
        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;
    fi;
    if [[ ${build_choices[@]} =~ third_party ]] ; then
        dst_folder=source/third_party;
        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;
    fi;
    if [[ ${build_choices[@]} =~ linux ]] ; then
        # dst_folder=/home/y_cohen/devel/linux/centos8/t/linux-4.18.0-80.1.2.el8_0;
        dst_folder=/home/y_cohen/devel/cyclones/cyclone.full/source/linux;
        echo "cs a ${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${dst_folder}/tags" >> tags.vim;
    fi;
    if [[ ${build_choices[@]} =~ broadcom ]] ; then
        
        #if ! [ -d ${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS ] ; then
            #echo -e "${RED}missing broadcom folder : ${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS${NC}";
            #echo -e "${RED}using : /home/y_cohen/devel/cyclones/cyclone.broadcom/source/third_party/cyc_platform/src/third_party/BRCM_OCS${NC}";
            #dst_folder=/home/y_cohen/devel/cyclones/cyclone.broadcom/source/third_party/cyc_platform/src/third_party/BRCM_OCS;
        #else
            #dst_folder=${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS;
        #fi;
        dst_folder=$(_dellgetbroadcomsourcespath);

        c ${dst_folder};
        #echo "tagging broadcom in $(pwd)"
        tagme;
        #ls
        tttt;
        c - ;

        echo "cs a ${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${dst_folder}/tags" >> tags.vim;
    fi;
    if [[ ${build_choices[@]} =~ qlogic ]] ; then
        #echo -e "${RED}missing qla folder${NC}";
        echo -e "${RED}qlogic is built when setting third-party in dellcyclonetagsupdate${NC}";
        dst_folder=source/third_party;
        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags+=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;
    fi;

    tttt;
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

    if [[ -e tags.vim && $(grep cs tags.vim | wc -l) -gt 0 ]] ; then
        ask_user_default_yes "retag ?"
        if [ $? -eq 1 ] ; then
            cat tags.vim |grep cs|awk '{print $3}' | while read s ; do c $(dirname $s)  ; ttt ; c -  ; done
            return;
        fi;
    fi;

    # whiptail --checklist "subject" hight width num-of-items
    build_choices=($(whiptail --checklist "cyclone tags" 15 30 9\
                   nt-nvmeof-frontend "" on \
                   cyc_core "" on  \
                   xios "" off  \
                   pm "" off  \
                   dp "" off  \
                   scsi "" off  \
                   third_party "" off \
                   cyc_crypto "" off 3>&1 1>&2 2>&3));


    echo > tags.vim;

    ######################################################################################
    if [[ ${build_choices[@]} =~ nt-nvmeof-frontend ]] ; then
        dst_folder=source/nt-nvmeof-frontend;
        echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        \cp ${yonienv}/dell-tags/tagme-nt.sh ${dst_folder}/tagme.sh;
        #\cp tags.vim ${dst_folder};

        echo "cs a ${cyclone_folder}/${dst_folder}/cscope.out" >> tags.vim;
        echo "set tags=${cyclone_folder}/${dst_folder}/tags" >> tags.vim;

        cd ${dst_folder}; tttt; cd -;
    else
        echo -e "${RED}you must specify NT${NC}";
        return -1;
    fi;
    ######################################################################################
    if [[ ${build_choices[@]} =~ cyc_core ]] ; then
        dst_folder=source/cyc_core;
        #echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        \cp ${yonienv}/dell-tags/tagme-cyc_core.sh ${dst_folder}/tagme.sh;
        echo 'includeTagdir+=(cyc_platform/src/include/)' >> ${dst_folder}/tagme.sh

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
    if [[ ${build_choices[@]} =~ cyc_core && ${build_choices[@]} =~ dp ]] ; then
        dst_folder=source/cyc_core;
        #echo -e "${BLUE}Tagging ${dst_folder}${NC}";
        #\cp ${yonienv}/dell-tags/tagme-cyc_core.sh ${dst_folder}/tagme.sh;
        echo 'includeTagdir+=(cyc_app/cyclone/datapath_api/)' >> ${dst_folder}/tagme.sh
        echo 'includeTagdir+=(cyc_app/cyclone/include/)' >> ${dst_folder}/tagme.sh
        echo 'includeTagdir+=(cyc_app/cyclone/system/)' >> ${dst_folder}/tagme.sh
        echo 'includeTagdir+=(cyc_app/cyclone/LayeredService/)' >> ${dst_folder}/tagme.sh
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
    submodules=(cyc_core nt-nvmeof-frontend third_party);
    local s;
    local ss;

    for ss in ${submodules[@]} ; do
        s=source/${ss};
        echo "------$s reset modified content------";
        cd $s ; git c -f . ;
        cd - ;
        echo "------$s reset new commits-----------";
        git smupdate $s;
    done;
}

alias dellpdr-gitsmup='_dellpdr_gitsmup'
_dellpdr_gitsmup ()
{
    local cyc_core=0;
    local nt_nvmeof_frontend=0;
    local linux=0;
    local third_party=0;
    local -a build_choices=();
    local pdr_branch=;
    local -a pdr_submodules=();

    ask_user_default_no "are you in a pdr ? ";
    if [ $? -eq 0 ] ; then
        echo "bailing out";
        return;
    fi;

    pdr_branch=$(git bb);
    pdr_submodules=( $(git lnameonly -1 | grep source | sed 's/.*source/source/g') );
    
    echo "${pdr_branch}";
    for s in ${pdr_submodules[@]} ; do
        echo "   +-- ${s}";
    done;

    #ask_user_default_no "reset the pdr before we start ? ";
    #[ $? -eq 1 ] && dellpdr-reset;

    ask_user_default_yes "update the listed submodules ?";
    if [ $? -eq 1 ] ; then
        for s in ${pdr_submodules[@]} ; do
            echo "git smupdate ${s}";
            git smupdate ${s};
        done;
        return 0;
    fi;

    #--------------------------------------
    #            ask user
    #--------------------------------------
    build_choices=($(whiptail --checklist "sync submodules" 11 30 6\
                   nt "" on \
                   cyc_core "" on  \
                   third_party "" off  \
                   linux "" off 3>&1 1>&2 2>&3));
    if [ $? -eq 1 ] ; then
        echo "cancelled !!";
        return 0;
    fi;

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
    local sync_all=false;
    local ans=;

    echo "---------------------------------------------------";
    echo "sync submodules branch according to pdr branch";
    echo "by either creating a new branch with the same name";
    echo "as the pdr or checking out an existing one with the same"
    echo "name as the pdr branch"
    echo "---------------------------------------------------";

    ask_user_default_no "are you in a pdr ? ";
    if [ $? -eq 0 ] ; then
        echo "bailing out";
        return;
    fi;


    pdr_branch=$(git bb);
    pdr_submodules=( $(git lnameonly -1 | grep source | sed 's/.*source/source/g') );
    
    #--------------------------------------
    #  ask user to update only
    #  submodule that this pdr include
    #--------------------------------------
    echo "${pdr_branch}";
    for s in ${pdr_submodules[@]} ; do
        echo "   +-- ${s}";
    done;

    ask_user_default_yes "checkout ${pdr_branch} in the listed submodules ?";
    if [ $? -eq 1 ] ; then
        for m in ${pdr_submodules[@]} ; do
            cd ${m};
            echo -e "${YELLOW}git checkout ${pdr_branch}${NC}";
            if [[ $(git b | grep ${pdr_branch} | wc -l) -gt 0 ]] ; then
                echo -e "${REDBLINK}branch '${pdr_branch}' already exist${NC}";
                echo -e "${RED}you might need to git pull it${NC}";
            fi;
            git checkout ${pdr_branch};
            cd - 1>/dev/null;
        done;
        return 0;
    fi;

    ask_user_default_no "sync all submodules ?";
    if [ $? -eq 1 ] ; then
        sync_all=true;
    fi;

    #--------------------------------------
    #            ask user
    #--------------------------------------
    if [ ${sync_all} == false ] ; then 
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
    fi;

    read -p "[c]heckout or create new [B]ranch ? [c|B]" ans;
    if [[  ${ans} == c ]] ; then
        checkout_cmd=c;
    else
        ask_user_default_no "align submodules to match pdr before we start ? ";
        [ $? -eq 1 ] && dellpdr-reset;
    fi;

    ask_user_default_no "are you sure ?";
    [ $? -eq 0 ] && return;
    #--------------------------------------
    #            do it
    #--------------------------------------
    if [ ${sync_all} == true ] ; then
        for m in source/* ; do

            echo -e "${BLUE}---->update ${m}${NC}";           
            echo -e "${YELLOW}cd ${m}${NC}";
            cd ${m};
            echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
            if [[ $(git b | grep ${pdr_branch} | wc -l) -gt 0 ]] ; then
                echo -e "${REDBLINK}branch '${pdr_branch}' already exist${NC}";
            fi;
            git ${checkout_cmd} ${pdr_branch};
            cd - 1>/dev/null;

        done;
        return;
    fi;

    if (( ${cyc_core} == 1 )) ; then 
        echo -e "${BLUE}---->update cyc_core${NC}";           
        echo -e "${YELLOW}cd source/cyc_core${NC}";
        cd source/cyc_core;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        if [[ $(git b | grep ${pdr_branch} | wc -l) -gt 0 ]] ; then
            echo -e "${REDBLINK}branch '${pdr_branch}' already exist${NC}";
        fi;
        git ${checkout_cmd} ${pdr_branch};
        cd - 1>/dev/null;
    fi;
    if (( ${nt_nvmeof_frontend} == 1 )) ; then
        echo -e "${BLUE}---->update nt-nvmeof-frontend${NC}";
        echo -e "${YELLOW}cd source/nt-nvmeof-frontend${NC}";
        cd source/nt-nvmeof-frontend;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        if [[ $(git b | grep ${pdr_branch} | wc -l) -gt 0 ]] ; then
            echo -e "${REDBLINK}branch '${pdr_branch}' already exist${NC}";
        fi;
        git ${checkout_cmd} ${pdr_branch};
        cd - 1>/dev/null;
    fi;
    if (( ${linux} == 1 )) ; then
        echo -e "${BLUE}---->update linux${NC}";              
        echo -e "${YELLOW}cd source/linux${NC}";
        cd source/linux;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        if [[ $(git b | grep ${pdr_branch} | wc -l) -gt 0 ]] ; then
            echo -e "${REDBLINK}branch '${pdr_branch}' already exist${NC}";
        fi;
        git ${checkout_cmd} ${pdr_branch};
        cd - 1>/dev/null;
    fi;
    if (( ${third_party} == 1 )) ; then
        echo -e "${BLUE}---->update third_party${NC}";
        echo -e "${YELLOW}cd source/third_party${NC}";
        cd source/third_party;
        echo -e "${YELLOW}git ${checkout_cmd} ${pdr_branch}${NC}";
        if [[ $(git b | grep ${pdr_branch} | wc -l) -gt 0 ]] ; then
            echo -e "${REDBLINK}branch '${pdr_branch}' already exist${NC}";
        fi;
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
    if (( 0 !=  $(hostname -i | grep ${user_to_devvm["yoni1"]}  | wc -l ) )) ; then
        return 0;
    fi;

    if (( 0 !=  $(hostname -i | grep ${user_to_devvm["yoni2"]}  | wc -l ) )) ; then
        return 0;
    fi;

    # cannot build on other manchines.
    return -1;
}

dellcyclonebuildoutputlist ()
{

    echo "xtremapp"
    fd -l -I -t f ".*xtremapp$" source/cyc_core;
    echo;
    echo "pnvmet";
    fd -l -IH -t f -e ko nvmet-power source/third_party/;
}

dellcyclonebuildthirdparty ()
{
    local build_third_party_cmd=;
    local flavor=RETAIL;

    if [ -z "${cyclone_folder}" ]  ; then
        echo "cyclone_folder not set! use dellclusterruntimeenvset";
        return -1;
    fi;

    dellcdcyclonefolder;
    [[ $? -ne 0 ]] && return -1;

    dellclusterruntimeenvget
    ask_user_default_yes "continue ?"
    [[ $? -eq 0 ]] && return -1;

    if [ -e ${cyclone_folder}/.build_choices_bkp ] ; then
        source ${cyclone_folder}/.build_choices_bkp;

        if [ -n "${build_third_party_cmd}" ] ; then
            echo "====== last command choices =============";
            echo -e "${BLUE}build_third_party_cmd${NC}=${build_third_party_cmd}";
            ask_user_default_no "repeat your last choices ? ";
            if [ $? -eq 1 ] ; then
                repeat_last_choice=1;
                eval ${build_third_party_cmd};
                return;
            fi;
        fi;
    fi;

    ask_user_default_yes "yes to build RETAIL, no for debug";
    if [[ $? -eq 0 ]] ; then
        flavor=DEBUG;
    fi;

    build_third_party_cmd="make third_party force=yes flavor=${flavor}";                                                                                                                                                              

    echo ${build_third_party_cmd};                                                                                                                                                                                                    
    ask_user_default_yes "continue";                                                                                                                                                                                                  
    [[ $? -eq 0 ]] && return -1;   

    eval ${build_third_party_cmd};
}

dellcyclone-get-build-status ()
{
    fd -l -I -t f ".*xtremapp$";
    fd -l -IH -t f -e ko nvmet-power source/third_party/;
}

dellcyclonebuild ()
{
    local build_third_party_cmd=;
    local build_cyclone_image_cmd=;
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
        echo -e "${BLUE}build_cyclone_image_cmd${NC}=${build_cyclone_image_cmd}";

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
        build_cyclone_image_cmd=;

        build_choices=($(whiptail --checklist "cyclone build" 12 30 7\
                       prune "" off \
                       debug "" off  \
                       verbose "" off  \
                       disable-cache "" off \
                       cyc_core "" on \
                       cyclone-image "" off \
                       third-party "" off 3>&1 1>&2 2>&3));

        if [[ ${build_choices[@]} =~ debug ]] ; then
            flavor=DEBUG;
        fi;

        if [[ ${build_choices[@]} =~ cyc_core ]] ; then
            build_cmd="nice -20 make cyc_core force=yes flavor=${flavor}";

            if [[ ${build_choices[@]} =~ cache ]] ; then
                build_cmd+=" acache=no mcache=no dcache=no auto_checkout=yes";
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

        if [[ ${build_choices[@]} =~ cyclone-image ]] ; then
            build_cyclone_image_cmd="make cyclone-image flavor=${flavor}";

            if [[ ${build_choices[@]} =~ prune ]] ; then
                prune_cmd="nice -20 make prune flavor=${flavor}";
            fi;
        fi;
	fi;

    echo -e "prune_cmd=\"${prune_cmd}\"" > ${cyclone_folder}/.build_choices_bkp;
    echo -e "build_cmd=\"${build_cmd}\"" >> ${cyclone_folder}/.build_choices_bkp;
    echo -e "build_third_party_cmd=\"${build_third_party_cmd}\"" >> ${cyclone_folder}/.build_choices_bkp
    echo -e "build_cyclone_image_cmd=\"${build_cyclone_image_cmd}\"" >> ${cyclone_folder}/.build_choices_bkp
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
            echo -e "${BLUE}build_cyclone_image_cmd${NC}=${build_cyclone_image_cmd}";
            echo -e "\n========================================================";
            ask_user_default_yes "continue ?";
            [ $? -eq 0 ] && return 0;
        fi;

        if [[ -n "${prune_cmd}" ]] ; then
            _dellcyclonebackupuserchoices backup;
            echo -e "${PURPLE}=========================${NC}";
            echo -e "${PURPLE}eval ${prune_cmd}${NC}";
            echo -e "${PURPLE}=========================${NC}";
            eval ${prune_cmd};
            _dellcyclonebackupuserchoices restore;
        fi;

        start_time=$SECONDS;
        # build_cmd="time ${build_cmd}";
        echo -e "${PURPLE}=========================${NC}";
        echo -e "${PURPLE}eval ${build_cmd}${NC}";
        echo -e "${PURPLE}=========================${NC}";
        eval ${build_cmd} | tee dellcyclonebuild.log;
        # $(set -x; ls -ltr source/cyc_core/cyc_platform/obj_Release/main/xtremapp);
        end_time=$SECONDS;
        build_time=$(( ${end_time} - ${start_time} ))
        echo "build took $(date -u -d @"$build_time" +'%-Mm %-Ss')";

        echo;
        p;
        dellcyclone-get-build-status;
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
                echo -e "${PURPLE}=========================${NC}";
                echo -e "${PURPLE}eval ${prune_cmd}${NC}";
                echo -e "${PURPLE}=========================${NC}";
                eval ${prune_cmd};
                _dellcyclonebackupuserchoices restore;
            fi;
            echo -e "${PURPLE}=========================${NC}";
            echo -e "${PURPLE}eval ${build_third_party_cmd}${NC}";
            echo -e "${PURPLE}=========================${NC}";
            eval ${build_third_party_cmd};
        fi;
    fi;

    if [ -n "${build_cyclone_image_cmd}" ] ; then
        echo "===================================================";
        echo -e "${BLUE}prune_cmd${NC}=${prune_cmd}";
        echo -e "${BLUE}build_cmd${NC}=${build_cmd}";
        echo -e "${BLUE}build_third_party_cmd${NC}=${build_third_party_cmd}";
        echo -e "${BLUE}build_cyclone_image_cmd${NC}=${build_cyclone_image_cmd}";

        r=1;
        if [[  ${repeat_last_choice} == 0 ]] ; then
            ask_user_default_no "build cyclone image ? ";
            r=$?;
        fi;

        if [ $r -eq 1 ] ; then
            if [[ -n "${prune_cmd}" && -z "${build_cmd}" ]] ; then
                _dellcyclonebackupuserchoices backup;
                echo -e "${PURPLE}=========================${NC}";
                echo -e "${PURPLE}eval ${prune_cmd}${NC}";
                echo -e "${PURPLE}=========================${NC}";
                eval ${prune_cmd};
                _dellcyclonebackupuserchoices restore;
            fi;
            echo -e "${PURPLE}=========================${NC}";
            echo -e "${PURPLE}eval ${build_cyclone_image_cmd}${NC}";
            echo -e "${PURPLE}=========================${NC}";
            eval ${build_cyclone_image_cmd};
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

if [[ -e /home/public/scripts/xpool_trident/prd/xpool ]] ; then
    xpool_app='/home/public/scripts/xpool_trident/prd/xpool';
elif [[ -e /net/c4shares.sspg.lab.emc.com/c4shares/auto/devutils/bin/xpool ]] ; then 
    xpool_app='/net/c4shares.sspg.lab.emc.com/c4shares/auto/devutils/bin/xpool';
else
    xpool_app=;
fi;

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

    #echo "/home/public/scripts/xpool_trident/prd/xpool list ${dell_group} ${dell_group_label}";
    # /home/public/scripts/xpool_trident/prd/xpool list ${dell_group} ${dell_group_label} --sort lessee | tee ${list_file}; 
    if [ -z "${xpool_app}" ] ; then
        echo "cannot find xpool tool";
        return -1;
    fi;

    echo "${xpool_app} list ${dell_group} ${dell_group_label} | tee ${list_file}"
    ${xpool_app} list ${dell_group} ${dell_group_label} | tee /tmp/cluster-list-file.txt

    ask_user_default_yes "open with vim ${list_file} ?";
    [ $? -eq 0 ] && return;
    (set -x ; mv /tmp/cluster-list-file.txt ${list_file});
    v ${list_file};
}

_dellclusterlistuser ()
{
    local user=${1:-y_cohen};

    [ -z ${user} ] && return;

    if [ -e ~/docs/dell-cluster-list-${user}.txt ] ; then
        ask_user_default_no "open ~/docs/dell-cluster-list-${user}.txt ? ";
        if [ $? -eq 1 ] ; then
            less ~/docs/dell-cluster-list-${user}.txt;
            cat ~/docs/dell-cluster-list-${user}.txt;
            return;
        fi;
    fi;

    if [ -z "${xpool_app}" ] ; then
        echo "cannot find xpool tool";
        return -1;
    fi;

    echo "${xpool_app} list -u ${user} ";
    ${xpool_app} list -u ${user} | tee ~/docs/dell-cluster-list-${user}.txt;

    if [[ "${user}" == "y_cohen" ]] ; then
        cat ~/docs/dell-cluster-list-y_cohen.txt |sed '1,7{/.*/d}' | sed -n '/^[0123456789]/p' | awk '{print $2}' > ${dell_leased_clusters};
    fi;
}

# alias dellclusterlistall='/home/public/scripts/xpool_trident/prd/xpool list -a -f'
dellclusterlist-all ()
{
    ask_user_default_no "are you sure ? it might take a while..."
    [ $? -eq 0 ] && return;

    if [ -z "${xpool_appl}" ] ; then
        echo "cannot find xpool tool";
        return -1;
    fi;

    ${xpool_app} list -a -x -f;
}

#alias dellclusterlist-yoni='          _dellclusterlist ~/docs/dell-cluster-list-yoni.txt'
alias dellclusterlist-yoni='          _dellclusterlistuser y_cohen'
alias dellclusterlist-user='          _dellclusterlistuser'
alias dellclusterlist-trident='       _dellclusterlist ~/docs/dell-cluster-list-trident.txt         Trident-kernel-IL'
alias dellclusterlist-pm-il='         _dellclusterlist ~/docs/dell-cluster-list-pm.txt              PM-IL'
alias dellclusterlist-platformio-fe=' _dellclusterlist ~/docs/dell-cluster-list-fe.txt              PlatformIO-FE'
alias dellclusterlist-platform-fe-nvme-stability=' _dellclusterlist ~/docs/dell-cluster-list-fe-nvme-stabiliy.txt              Platform-FE-NVME-Stability'
alias dellclusterlist-oboe='dellclusterlist-platformio-fe'
alias dellclusterlist-oboe-fe='        _dellclusterlist ~/docs/dell-cluster-list-oboe-fe            PlatformIO-FE OBOE'
alias dellclusterlist-platformio-be=' _dellclusterlist ~/docs/dell-cluster-list-be.txt              PlatformIO-BE'
alias dellclusterlist-xblock='        _dellclusterlist ~/docs/dell-cluster-list-xblock.txt          Xblock-NDU'
alias dellclusterlist-shared='        _dellclusterlist ~/docs/dell-cluster-list-shared.txt          Core-Dev-Shared'
alias dellclusterlist-shared-nvmeofc='_dellclusterlist ~/docs/dell-cluster-list-shared-nvmeofc.txt  Core-Dev-Shared NVMeOF-FC'
alias dellclusterlist-shared-indus='  _dellclusterlist ~/docs/dell-cluster-list-shared-indus.txt    Core-Dev-Shared-Indus'
alias dellclusterlist-qa-app-lab='    _dellclusterlist ~/docs/dell-cluster-list-qa-app-lab.txt      QA-AppLab'
alias dellclusterlist-trident-roce='  _dellclusterlist ~/docs/dell-cluster-list-trident-roce.txt    Trident-kernel-IL NVMeOF-RoCE'
alias dellclusterlist-trident-indus=' _dellclusterlist ~/docs/dell-cluster-list-trident-indus.txt   Trident-kernel-IL indus'
alias dellclusterlist-trident-advanced-tech=' _dellclusterlist ~/docs/dell-cluster-list-trident-advanced-tech.txt   Trident-Advanced-Tech'
alias dellclusterlist-qa-performance='_dellclusterlist ~/docs/dell-cluster-list-qa-performance.txt   QA-Performance'

# PlatformIO-FE:adamh
xpool_users=(y_cohen grupie amite eldadz levyi2 dor_deri adamh joseph_karner labmaintenance);
complete -W "$(echo ${xpool_users[@]})" dellclusterlist-user dellclusterleaseUpdateUser dellclusterleaseReRelease dellcdvduser; 

dellclusterleaseRelease ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster="$(printf "%s\n" $(cat ${dell_leased_clusters}) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
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

    if [[ $(grep ${cluster} ${dell_leased_clusters} | wc -l) -gt 0 ]] ; then
        sed -i "/${cluster}/d" ${dell_leased_clusters};
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
    _add_cluster_to_list ${cluster};

    echo "/home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster}";
    /home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster};
    echo "/home/public/scripts/xpool_trident/prd/xpool lease ${lease_time} -c ${cluster}";
    echo ${cluster} >> ${dell_leased_clusters};
}

dellclusterleaseUpdateUser ()
{
    local user=${1:-y_cohen};
    local cluster=${2};

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

dellclusterleasehistory ()
{

    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    else
        cluster=$(echo ${cluster} | awk '{print toupper($0)}');
    fi;

    echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool history -c ${cluster}${NC}";
    /home/public/scripts/xpool_trident/prd/xpool history -c ${cluster};
    return 0;
}

dellclusterleaseinfo ()
{

    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo -e "${BLUE}xxlabjungle cluster \"name:${cluster}\" | jq -r \".objects[].lease\"${NC}";
    2>/dev/null xxlabjungle cluster "name:${cluster}" | jq -r ".objects[].lease";
}

#dellclusterowner ()
#{
    #local cluster=${1};

    #if [ -z "${cluster}" ] ; then 
        #cluster=$(_dellclusterget);
        #if [ -z ${cluster} ] ; then
            #echo "${FUNCNAME} <cluster>"; 
            #return -1;
        #fi;
    #fi;

    #echo -e "${BLUE}xxlabjungle cluster \"name:${cluster}\" | jq -r \".objects[].lease.user.username\"${NC}";
    #2>/dev/null xxlabjungle cluster "name:${cluster}" | jq -r ".objects[].lease.user.username, .objects[].lease.expires_on";
#}

_cluster_owner ()
{
    local cluster=${1};

    2>/dev/null /home/build/xscripts/xxutil.py labjungle  cluster "name:${cluster}" | jq -r ".objects[].lease.user.username"|sed 's/\ //g';
}

dellclusterleaseReRelease ()
{
    local user=${1:-y_cohen};
    local cluster=${2}
    local new_owner=;
    local cluster_owner=;
    local retries=1;

    if [ -z ${cluster} ] ; then
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    # cluster_owner=$(xxlabjungle cluster "name:${cluster}" | jq -r ".objects[].lease.user.username");
    cluster_owner=$(_cluster_owner ${cluster});

    if [[ -z "${cluster_owner}" ]] ; then
        echo -e "${RED}!!error!! could not get cluster owner${NC}";
        return -1;
    fi

    if [[ "${cluster_owner}" == "null" ]] ; then
        echo -e "${YELLOW}${cluster} is free lets just take it${NC}";
        echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster}${NC}";
        /home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster};
    else
        if [[ "${cluster_owner}" != "y_cohen" ]] ; then
            echo -e "${YELLOW}${cluster} owned by ${cluster_owner}. lets change that${NC}";
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster}${NC}";
            /home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster};
        fi;

        echo -e "${YELLOW}release ${cluster} from ${cluster_owner}${NC}";
        echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool release ${cluster}${NC}";
        /home/public/scripts/xpool_trident/prd/xpool release ${cluster};

        new_owner=$(_cluster_owner ${cluster});
        while [[ "${new_owner}" == "y_cohen" ]] ; do
            echo -e "${RED}${cluster} still owned by ${new_owner}. lets wait 2 more seconds${NC}";
            sleep 2;
            new_owner=$(_cluster_owner ${cluster});
            ((retries++));
            if [[ ${retries} > 5 ]] ; then
                echo -e "${RED}failed to release ${cluster}${NC}";
                return;
            fi;
        done;

        if [[ "${new_owner}" == "null" ]] ; then
            echo -e "${YELLOW}${cluster} is free. lets take it${NC}"
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster}${NC}";
            /home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster};
        else
            # hippo sometimes takes released clusters
            echo -e "${YELLOW}${new_owner}: got ${cluster}. lets take it back ;-)${NC}";
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster}${NC}";
            /home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster};

            echo -e "${YELLOW}y_cohen : extend ${cluster} for 3 days${NC}";
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool extend ${cluster} 3d${NC}";
            /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} 3d;
        fi;

    fi;

    if [[ ${user} != "y_cohen" ]] ; then
        echo -e "${YELLOW}update ${cluster} to user to : ${user}${NC}";
        echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster}${NC}";
        /home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster};
    fi;

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
    local bkp_file=$(echo $cyclone_folder |sed 's/\//-/g');
    # TODO - in case user asked 'ls' then make sure that bkp file is up to date before doing the ls
    if [[ ${1} == "ls" ]] ; then
        ls -tr ~/.*install_build_choices_bkp.*|xargs cat | grep "install_pdr\|_date\|_time";
        echo -e "make sure you run 'gdd' before running 'gdd ls' to get up-to-date info"
        return;
    fi;

    if [[ -z ${cyclone_folder} ]] ; then
        _dellclusteruserchoicesget;
        return;
    fi;

    _dellclusteruserchoicesget | tee ~/.${bkp_file}.install_build_choices_bkp.$(date +"%d_%m_%y");

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

    # is this a cyclone folder ?
    if [[ "cyclone" == "$(basename $(git remote get-url origin 2>/dev/null) .git)" ]] ; then
        if [[ -e ./.dellclusterruntimeenvbkpfile ]] ; then
            bkp_file=./.dellclusterruntimeenvbkpfile;
            echo -e "${GREEN}found cyclone backup file : ${bkp_file}"
            cat ${bkp_file} | grep "YONI_CLUSTER\|YONI_PDR" | while read l ; do echo -e "\t${l}" ; done
            echo -e "${NC}"
        else
            echo -e "${RED} no backfile in pdr${NC}"
        fi;
    fi;

    if [ -z "${bkp_file}" ] ; then
        if  [[ -e ${dellclusterglobalruntimeenvbkpfile} ]] ; then
            bkp_file=${dellclusterglobalruntimeenvbkpfile};
            echo -e "${GREEN}found global backup file : ${bkp_file}"
            cat ${bkp_file} | grep "YONI_CLUSTER\|YONI_PDR" | while read l ; do echo -e "\t${l}" ; done
            echo -e "${NC}"
        else
            echo -e "${RED} no backfile${NC}"
        fi;
    fi;

    #echo "bkp_file=${bkp_file}";

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
alias dddqlasources='dellcdqlasources'
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
alias rdd='dellclusterruntimeenvset'
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
    export CYC_FOLDER=${cyclone_folder};
    _dellclusterruntimeenvvalidate;
    if [[ $? -ne 0 ]] ; then
        ask_user_default_no "set it anyways ? ";
        if [ $? -eq 0 ] ; then
            echo "!!! failed to set runtimeenv !!!";
            export CYC_CONFIG=;
            cyclone_folder=;
            export YONI_CLUSTER=;
            export CYC_FOLDER=;
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


dellclusterleaselist ()
{
    /home/public/scripts/xpool_trident/prd/xpool list -json -u y_cohen  |
        sed 's/+--/#/g' | 
        awk 'BEGIN{RS="#"} {if (NR == 4) print $0 }' | 
        awk '{getline ; print $0 } ' | jq  -r ".[].nodes" | sed -e 's/\[//g' -e 's/\]//g' -e 's/\"//g' -e 's/-a//g' -e 's/-b//g' -e 's/,//g' |sort -u | sed 's/ //g' | tee ${dell_leased_clusters};
}

dellclusterleaseextend () 
{
    local cluster=${1};
    local extend=${2:-28d};
    local user_extend_choice=;

    echo -e "${RED}use dellclusterleaselist to refresh leased list${NC}";

    if [ -z "${cluster}" ] ; then 
        echo "cluster : ${cluster}";
        cluster="$(cat ${dell_leased_clusters} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        if [ -z "${cluster}" ] ; then
            cluster=$(_dellclusterget);
            if [ -z "${cluster}" ] ; then
                echo "usage : ${FUNCNAME} <cluster>"; 
                return -1;
            fi;
        fi;
    fi;

    echo "checking group for ${cluster}";
    echo -e "/home/build/xscripts/xxutil.py labjungle cluster \"name:${cluster}\" | jq -r \".objects[].owner.group.name\"";
    group=$(2>/dev/null /home/build/xscripts/xxutil.py labjungle cluster "name:${cluster}" | jq -r ".objects[].owner.group.name" | xargs);
    if [[ "${group}" =~ "Shared" ]] ; then
        extend=72h;
        echo "${cluster} is from ${group}. max extend is : ${extend}";
    fi;

    read -p "extend ${cluster} ${extend} days ? Enter/or choose a different value: " user_extend_choice;
    if [ -z "${user_extend_choice}" ] ; then
        extend="${extend}";
    else
        extend=${user_extend_choice}d;
    fi;

    echo -e "\t\t-> /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend}"
    /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} ${extend};

}

#alias dellclusterleaseextendshared='dellclusterleaseextend ask 72h';

# complete -W "$(echo ${trident_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaseRelease dellclusterdeploy dellclusterleasewithforce
# complete -W "$(echo ${trident_cluster_list_nodes[@]})" xxssh xxbsc dellclusterguiipget dellclusterinfo dellclusterlease dellclusterleaseextend 

# complete -W "$(echo ${!dell_cluster_list[@]})" dellclusterruntimeenvset dellclusterleaseRelease dellclusterdeploy dellclusterleasewithforce xxssh xxbsc dellclusterguiipget dellclusterinfo dellclusterlease dellclusterleaseextend 

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
        cluster="$(printf "%s\n" $(cat ${dell_leased_clusters}) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
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
        cluster="$(printf "%s\n" $(cat ${dell_leased_clusters}) | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
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

if [[ -e ${dell_leased_clusters} ]] ; then
    complete -W "$(cat ${dell_leased_clusters})" ssh2coreleased ssh2bscleased
fi;


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
    local cluster=;

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
    local autoinstall_cmd=;

    if command -v autoInstall.pl >/dev/null 2>&1; then 
        echo "use autointall from path"
        autoinstall_cmd=autoInstall.pl;
    elif [ -e /home/public/devutils/bin/autoInstall.pl ] ; then
        echo "using public"
        autoinstall_cmd=/home/public/devutils/bin/autoInstall.pl;
    elif [ -e /net/c4shares.sspg.lab.emc.com/c4shares/auto/devutils/bin/autoInstall.pl ] ; then
        autoinstall_cmd=/net/c4shares.sspg.lab.emc.com/c4shares/auto/devutils/bin/autoInstall.pl; 
    else
        echo -e "${RED}cannot find autoInstall.pl script${NC}";
        return -1;
    fi;
 
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

_usage_dellclusterinstallimage_with_autoinstall ()
{
    echo "dellclusterinstallimage-with-autoinstall <image file> <cluster> [feature-flag]";
}

dellclusterinstallimage-with-autoinstall ()
{
    local image=${1};
    local cluster=${2};
    local feature_flag=;
    local flavor=retail;
    local autoinstall_cmd=;

    if command -v autoInstall.pl >/dev/null 2>&1; then 
        echo "use autointall from path"
        autoinstall_cmd=autoInstall.pl;
    elif [ -e /home/public/devutils/bin/autoInstall.pl ] ; then
        echo "using public"
        autoinstall_cmd=/home/public/devutils/bin/autoInstall.pl;
    elif [ -e /net/c4shares.sspg.lab.emc.com/c4shares/auto/devutils/bin/autoInstall.pl ] ; then
        autoinstall_cmd=/net/c4shares.sspg.lab.emc.com/c4shares/auto/devutils/bin/autoInstall.pl; 
    else
        echo -e "${RED}cannot find autoInstall.pl script${NC}";
        return -1;
    fi;
 
    if [[ -z ${image} ]] ; then

        if [ -z "${cyclone_folder}" ] ; then
            echo "cyclone_folder not set ! cant backup user choices. use dellclusterruntimeenvset";
            return -1;
        fi;

        image=$(fd --regex 'PowerStoreT-[0-9]+.*' -IH -e tgz.bin);
        if [ -z "${image}" ] ; then
            echo "missing image !!"
            _usage_dellclusterinstallimage_with_autoinstall;
            return -1;
        fi;

        echo "you did not specify image file";
        echo "found : $image";
        ask_user_default_no "use it ?";
        if [ $? -eq 0 ] ; then
           return 0;
        fi;
        image=$(readlink -f ${image});
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
        autoinstall_cmd=$(echo -e "${autoinstall_cmd} -swarm ${cluster} -type san -flavor ${flavor} -image ${image} ");
    else
        # read -p "enter feature : " feature_flag;
        feature_flag=$(dellcyclonefeatureflaglist);
        if [[ $? -ne 0 ]] ; then
            echo "CYC_CONFIG not set. use dellclusterruntimeenvset <cluster>";
            return;
        fi;
        autoinstall_cmd=$(echo -e "${autoinstall_cmd} -swarm ${cluster} -type san -flavor ${flavor} -image ${image} -feature ${feature_flag}");
    fi;

    ask_user_default_no "would you like a persona flag ? ";
    if [ $? -eq 1 ] ; then
        autoinstall_cmd=$(echo -e "${autoinstall_cmd} --persona hydra");
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

_verify_cluster_config ()
{
    local cluster=${1};

    if [[ -z ${cluster} || -z ${CYC_CONFIG} ]] ; then
        echo "error: cluster or CYC_CONFIG not given";
        return;
    fi;

    xxutil.py get_config_from_labjungle ${cluster} > ${cluster}.labjungle.cfg 
    diff     ${cluster}.labjungle.cfg ${CYC_CONFIG} |grep -v "+++\|---" | grep "^-\|^+" | grep -v pdu
}

_dellcluster_stack_down_up ()
{
    local up_or_down=${1}
    local node=${2};
    local cmd=;

    _dellclusterruntimeenvvalidate;
    if [[ $? -ne 0 ]] ; then
        return -1;
    fi;

    dellcdclusterscripts;

    # this section is commented as the scripts 
    # stack_down_hard_only_a and stack_up_only_a and b dont work
#   if [ -z "${node}" ] ; then
#       read -p "node-a or node-b [a|b] (none for both) ? " node;
#   fi;
#
#   if [ "${node}" == "b" ] ; then 
#       node=b;
#   elif [ "${node}" == "a" ] ; then
#       node=a;
#   fi;
#
#   if [ -n "${node}" ] ; then
#      if [ "${up_or_down}" == "down" ] ; then
#          cmd="./stack_down_hard_only_${node}.sh";
#      else
#          cmd="./stack_up_only_${node}.sh";
#      fi;
#   else

    if [ "${up_or_down}" == "down" ] ; then
        cmd="./stack_down_hard.sh";
    else
        cmd="./stack_up.sh";
    fi;

    if ! [ -e ${cmd} ] ; then
        echo "file : ${cmd} not found";
        return -1;
    fi 

    echo "===================================================";
    ls -l ${cmd};
    echo "===================================================";
    eval ${cmd};

    return 0;
}

alias dellcluster-stack-up='_dellcluster_stack_down_up up'
alias dellcluster-stack-down='_dellcluster_stack_down_up down'

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
    local warn_user_oboe_support_only_unified=false;

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

            if [[ ${reinit_choices[@]} =~ release ]] ; then
                reinit_cmd+=" -F Retail";
            else
                reinit_cmd+=" -F Debug";
            fi;
             
            echo "debug : reinit_choices ${reinit_choices[@]}"
            echo "debug : reinit_cmd ${reinit_cmd}"

            if [[ ${reinit_choices} =~ block ]] ; then
                reinit_cmd+=" sys_mode=block";
                if [[ ${cluster} =~ "OO-" ]] || [[ ${cluster} =~ "OD-" ]] ; then
                    warn_user_oboe_support_only_unified=true;
                fi;
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

    if [[ ${warn_user_oboe_support_only_unified} == true ]] ; then
        echo "${cluster} is oboe and does not support block mode";
        ask_user_default_no "continue ";
        if [ $? -eq 0 ] ; then
            return;
        fi;
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

    if [ ${repeat_last_choice} -eq 1 ] ; then
        if [[ "${cluster}" != "${install_cluster}" ]] ; then
            echo -e "${RED}CYC_CONFIG ${cluster} is not ${install_cluster}${NC}";
            ask_user_default_yes "would you like to install ${cluster}"
            if [[ $? -eq 0 ]] ; then
                return -1;
            fi;

            deploy_cmd=$(echo ${deploy_cmd} | sed "s/${install_cluster}/${cluster}/g");
            create_cluster_cmd=$(echo ${create_cluster_cmd} | sed "s/${install_cluster}/${cluster}/g");
            
        fi;
    fi;

    ddd;
    echo "install_date=\"$(now)\"" > ${cyclone_folder}/.install_choices_bkp;
    echo "install_cluster=${cluster}" >> ${cyclone_folder}/.install_choices_bkp;
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
                cmd_start_time=${SECONDS};
                eval ${create_cluster_cmd};

                if [[ $? -ne 0 ]] ; then
                    echo -e "\n${RED}\t\tcreate_cluster failed ! ! !${NC}";
                    continue;
                else
                    create_cluster_failed=0;
                    break;
                fi;

            done;
        fi;

        if [ 1 -eq ${create_cluster_failed} ] ; then
            return -1;
        fi;

        create_cluster_time=$(( (${SECONDS} - ${cmd_start_time}) ));
        create_cluster_time="$(date -u -d @"${create_cluster_time}" +'%-Mm %-Ss')";
        echo -e "create_cluster_time=\"${create_cluster_time}\"" >> ${cyclone_folder}/.install_choices_bkp;
        echo -e "\n${GREEN}\t\t\tcreate_cluster succeeded ( after ${create_cluster_time} )${NC}";
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
	
	dellcdclusterscripts;
	if ! [ -e fast_code_loader.sh ] ; then
		echo "fast_code_loader.sh !!! script not found";
        dellcdcyclonefolder;
		return -1;
	fi

    # for cyc_core changes add "sym"
	# time ./fast_code_loader.sh sym -r 10 -o -w ${cyc_core_folder};

    read -p "[a|b|default BOTH] : " node;
    if [ "${node}" = 'a' ] ; then
        echo -e "${RED}time ./fast_code_loader.sh 10 -o -w ${cyc_core_folder}${NC}";
        time ./fast_code_loader.sh 10 -o -w ${cyc_core_folder};
    elif [ "${node}" = 'b' ] ; then
        echo -e "${RED}time ./fast_code_loader.sh 11 -o -w ${cyc_core_folder}${NC}";
        time ./fast_code_loader.sh 11 -o -w ${cyc_core_folder};
    else
        echo -e "${RED}time ./fast_code_loader.sh 10 -o -w ${cyc_core_folder}${NC}";
        echo -e "${RED}time ./fast_code_loader.sh 11 -o -w ${cyc_core_folder}${NC}";
        time ./fast_code_loader.sh 10 -o -w ${cyc_core_folder};
        time ./fast_code_loader.sh 11 -o -w ${cyc_core_folder};
    fi;

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

dellcluster-restartnode ()
{
    local node=${1};

	if [ -z $CYC_CONFIG ] ; then
		echo "CYC_CONFIG not defined. use dellclusterruntimeenvset";
		return -1;
	fi

	ask_user_default_yes "restart ${YONI_CLUSTER} ?";
	[ $? -eq 0 ] && return -1;

	dellcdclusterscripts;

    if [[ -z "${node}" ]] ; then
        read -p "[a|b|default BOTH] : " node;
        if [ "${node}" = 'a' ] ; then
            node=a;
        elif [ "${node}" = 'b' ] ; then
            node=b;
        fi;
    fi;

    if [[ -z ${node} || "${node}" == 'a' ]] ; then
        echo -e "${GREEN}Reloading drivers on ${YONI_CLUSTER} node-a${NC}";
        ./stack_down_hard_only_a.sh
        ./stack_up_only_a.sh
    fi;

    if [[ -z ${node} || "${node}" == 'b' ]] ; then
        echo -e "${GREEN}Reloading drivers on ${YONI_CLUSTER} node-b${NC}";
        ./stack_down_hard_only_b.sh
        ./stack_up_only_b.sh
    fi;

    return 0;
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
    time ./fast_nvmet_driver_loader.sh ${cyclone_folder};

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

delllgyonienvupdate ()
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

    #echo "sshpass -p Password123! scp -o 'PubkeyAuthentication no' -o LogLevel=ERROR -F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  ~/yonienv/scripts/*yoni* root@${lg_name}:~/"
    sshpass -p Password123! scp -o 'PubkeyAuthentication no' -o LogLevel=ERROR -F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  ~/yonienv/scripts/*yoni* root@${lg_name}:~/;
}

dellclusteryonienvupdate ()
{
    local cluster=${1};

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then 
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    echo ${cluster} > ~/.dellssh2cluster.bkp

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

_add_lg_to_list ()
{
    local lg=${1};

    #lg_list_file=~/yonienv/bashrc_dell_lg_list_file
    #lg_list=( $(cat ${lg_list_file} ));

    if ! [[ ${lg_list[@]} =~ ${lg} ]] ; then
        ask_user_default_no "add ${lg} to list";
        if [ $? -eq 0 ] ; then return ; fi;
        echo ${lg} >> ${lg_list_file};
        lg_list+=" ${lg}";
        echo -e "${RED}added ${lg} to saved LGs${NC}";
    fi;

}

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

    _add_lg_to_list ${lg_name};

    if [[ ${use_backup} == 0 ]] ; then
        ask_user_default_yes "ssh2lg ${lg_name} ? ";
        if [[ $? -eq 0 ]] ; then return 0 ; fi;
    fi;

    #if ! [[ ${lg_list[@]} =~ ${lg_name} ]] ; then
        #echo ${lg_name} >> ${lg_list_file};
        #lg_list+=" ${lg_name}";
        #echo -e "${RED}added ${lg_name} to saved lgs${NC}";
    #fi;

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
    #dri asset od-h5046 --format json |jq -r ".hosts[]"
}

#ssh2lgofcluster ()
#{
    #local cluster=${1};
    #local use_backup=0;
    #local lg;

    #if [ -z "${cluster}" ] ; then 
        #cluster=$(_getlastusedcluster);
        #if [ -z "${cluster}" ] ; then
            #return -1;
        #fi;
    #fi;

    #_add_cluster_to_list ${cluster};

    #echo ${cluster} > ~/.dellssh2cluster.bkp

    #echo "using ${cluster}"
    #lg_arr=( $(dellclusterlgipget ${cluster}) );

    #echo "lg_arr: ${lg_arr[@]}";
    #return;

    #if [[ ${#lg_arr[@]} -gt 1 ]] ; then
        #echo "more than lg : ${lg_arr[@]}";
        #lg="$(printf "%s\n" ${lg_arr[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    #else
        #lg=${lg_arr[0]};
    #fi;

    #if [[ -z "${lg}" ]] ; then
        #echo -e "${RED}must specify lg name${NC}";
        #return -1;
    #fi;
    
    #ssh2lg ${lg};
    #return 0;
#}

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

dellclusterlabjungle ()
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
    echo -e "${GREEN}xxlabjungle cluster \"name:${cluster}\"${NC}";
    ask_user_default_yes "continue";
    if [ $? -eq 0 ] ; then return 0 ; fi;
    xxlabjungle cluster "name:${cluster}" | less;
}

ssh2lgofcluster ()
{
    local cluster=${1};
    local use_backup=0;
    local lg;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_getlastusedcluster);
        if [ -z "${cluster}" ] ; then
            return -1;
        fi;
    fi;

    _add_cluster_to_list ${cluster};

    echo ${cluster} > ~/.dellssh2cluster.bkp

    echo "using ${cluster}"
    lg_arr=( $(dellclusterlgipget ${cluster}) );

    #echo "lg_arr: ${lg_arr[@]}";

    if [[ ${#lg_arr[@]} -gt 1 ]] ; then
        echo "more than lg : ${lg_arr[@]}";
        lg="$(printf "%s\n" ${lg_arr[@]} | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    else
        lg=${lg_arr[0]};
    fi;

    if [[ -z "${lg}" ]] ; then
        echo -e "${RED}must specify lg name${NC}";
        return -1;
    fi;
    
    ssh2lg ${lg};
    return 0;
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
 
_ssh2lg_with_tmux ()
{
    local lg=${1};
    local win_number=${2};
    local session_name=lgs;



    if tmux has-session -t "${session_name}" 2>/dev/null; then
        tmux new-window -t "${session_name}":${win_number} -n "${lg}" "ssh2lg ${lg}"
    fi;
}

_ssh2lg_nopass ()
{
    local lg_ip_addr=${1};

    yelp "lg_ip_addr=${lg_ip_addr}";

    sshpass -p Password123! ssh -o 'PubkeyAuthentication no' -o LogLevel=ERROR -F /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  root@${lg_ip_addr};
}

_ssh2lg_with_tmux ()
{
    local lg=${1};
    local session_name=lgs;

    if tmux has-session -t "${session_name}" 2>/dev/null; then
        tmux new-window -t "${session_name}" -n "${lg}";
        tmux send-keys -t "${session_name}:${lg}" "y" C-m;
        tmux send-keys -t "${session_name}:${lg}" "_ssh2lg_nopass ${lg}" C-m;
    else
        tmux new-session -d -s "${session_name}" -n "${lg}";
        tmux send-keys -t "${session_name}:${lg}" "y" C-m;
        tmux send-keys -t "${session_name}:${lg}" "_ssh2lg_nopass ${lg}" C-m;
    fi;
}

ssh2lgs ()
{
    local cluster=${1}; 
    local lg=;



    if tmux has-session -t "lgs" 2>/dev/null; then
        echo -e "Session \'lgs\' already exists. Attaching..."
        tmux attach -t "lgs" 
        return;
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

    lg_arr=( $(dellclusterlgipget ${cluster}) );
    for lg in ${lg_arr[@]} ; do
        _ssh2lg_with_tmux  ${lg};
    done;

    tmux attach -t "lgs" 
}

dellclustereditcycconfig ()
{
    _dellclusterruntimeenvvalidate
    if [[ $? -ne 0 ]] ; then
        return -1;
    fi;

    v ${CYC_CONFIG};
}

dellclusteredit-cyc_bsc_control ()
{
    if [ -z ${cyclone_folder} ] ; then
        echo "cyclone_folder not defined. run dellclusterruntimeenvset or rdd";
        return -1;
    fi;

    v ${cyclone_folder}/source/cyc_core/cyc_platform/src/package/cyc_host/cyc_bsc/scripts/cyc_bsc_control.sh
    return 0;
}

dellclusteredit-ini-file ()
{
    if [ -z ${cyclone_folder} ] ; then
        echo "cyclone_folder not defined. run dellclusterruntimeenvset or rdd";
        return -1;
    fi;

    v ${cyclone_folder}/source/cyc_core/cyc_platform/src/pm/template.ini
    return 0;
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

dellclusterowner ()
{
    local cluster=${1};
    local current_user=;
    local expires_on=;
    local group=;

    if [ -z "${cluster}" ] ; then 
        cluster=$(_dellclusterget);
        if [ -z ${cluster} ] ; then
            echo "${FUNCNAME} <cluster>"; 
            return -1;
        fi;
    fi;

    _add_cluster_to_list ${cluster};

    2>/dev/null /home/build/xscripts/xxutil.py labjungle cluster "name:${cluster}" > x.tmp
    current_user=$(cat x.tmp | jq -r ".objects[].lease.user.username" | xargs);
    if [ -z "${current_user}" ]  ; then
        echo "${cluster} is free";
        return 0;
    fi;
    current_user_email=$(cat x.tmp | jq -r ".objects[].lease.user.email" | xargs);
    expires_on=$(cat x.tmp | jq -r ".objects[].lease.expires_on" | xargs);
    group=$(cat x.tmp | jq -r ".objects[].owner.group.name" | xargs);
    2>&1 1>/dev/null rm -f x.tmp;
    echo -e "${current_user} (${current_user_email}) owns ${cluster}@${group} till ${expires_on}";
    return 0;
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

    _add_cluster_to_list ${cluster};

    print_underline_size "_" 80	 
    echo "/home/public/devutils/bin/swarm -ping ${cluster} --showallips";
    print_underline_size "_" 80	 
    /home/public/devutils/bin/swarm -ping ${cluster} --showallips;
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

dellbroadcomsdk ()
{
    local ocs_archive=;
    if [ -z "${cyclone_folder}" ] || ! [ -d ${cyclone_folder} ] ; then
        return -1;
    fi;

    ocs_archive=$(\ls ${cyclone_folder}/source/third_party/binaries/key_val/ocs/ocs_sdk_* 2>/dev/null);

    if [ -z "${ocs_archive}" ] ; then
        return -1;
    fi;

    echo "OCS_ARCHIVE ${ocs_archive}";
    export OCS_ARCHIVE=${ocs_archive};
    return 0;
}

dellbroadcomsdkappypatches ()
{
    local output_dir=./ocs_patched;
    local cmakelist_path=${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS/CMakeLists.txt;
    local patch_dir=${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS/patches;

    dellbroadcomsdk;
    if [ $? -ne 0 ] ; then
        echo "sdk not found";
        return -1;
    fi;

    ${yonienv}/scripts/ocs_apply_patches.sh ${output_dir} ${patch_dir} ${cmakelist_path} ${OCS_ARCHIVE}; 
}

dellbroadcombuilddriversourcetree ()                                                                                                                                                                                                  
{                                                                                                                                                                                                                                     
    #dddbroadcommakefiles;                                                                                                                                                                                                             
    if [ $? -ne 0 ] ; then                                                                                                                                                                                                            
        return -1;                                                                                                                                                                                                                    
    fi;                                                                                                                                                                                                                               
    export cyclone_folder=${cyclone_folder}
    ~/yonienv/scripts/ocs_apply_patches.sh $@
}  

dellbroadcomdeletesources ()
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

_dellgetbroadcomsourcespath ()
{
    local platform_debug=source/third_party/cyc_platform/obj_Debug;
    local platform_release=source/third_party/cyc_platform/obj_Release;
    local broadcom_src=third_party/BRCM_OCS/src/BRCM_OCS;
    local broadcom=;

    if [ -z ${cyclone_folder} ] ; then
        echo -e "${RED}cyclone_folder empty! using ~/devel/cyclones/cyclone.broadcom/${NC}"; 
        cyclone_folder=~/devel/cyclones/cyclone.broadcom/;
    fi;

    if ! [ -d ${cyclone_folder} ] ; then
        echo -e "${RED}${cyclone_folder} does not exist! using ~/devel/cyclones/cyclone.broadcom/${NC}"; 
        cyclone_folder=~/devel/cyclones/cyclone.broadcom/;
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
        echo ${broadcom};
        return 0;
    else
        echo "missing folder ${broadcom}";
        echo -e "${RED}missing broadcom folder. try the feature branch feature//pl-trif-2474-brcm-fc-64gb${NC}";
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

dellcyclonelistkernelmodules ()
{
    new_drivers_release_path=${cyclone_folder}/source/cyc_core/cyc_platform/obj_Release/package/final/top_host/cyc_host/cyc_common/modules;
    new_drivers_debug_path=${cyclone_folder}/source/cyc_core/cyc_platform/obj_Debug/package/final/top_host/cyc_host/cyc_common/modules;

    found_release=false;
    found_debug=false;
    if [ -d ${new_drivers_release_path} ] ; then
        echo -e "${BLUE}found drivers in ${new_drivers_release_path}${NC}";
        found_release=true;
    else
        echo "no drivers in ${new_drivers_release_path}"
    fi;

    if [ -d ${new_drivers_debug_path} ] ; then
        echo -e "${BLUE}found drivers in ${new_drivers_debug_path}${NC}";
        found_debug=true;
    else
        echo "no drivers in ${new_drivers_debug_path}"
    fi;
 
    if [[ ${found_release} == true ]] ; then
        find ${new_drivers_release_path} -type f -regex ".*nvme.*ko\|.*qla.*ko\|.*ocs.*ko" | while read m ; do 
            md5sum $m;
        done;
    fi;

    if [[ ${found_debug} == true ]] ; then
        find ${new_drivers_debug_path} -type f -regex ".*nvme.*ko\|.*qla.*ko\|.*ocs.*ko" | while read m ; do 
            md5sum $m;
        done;
    fi;
}

dellcyclonekernelshaget ()
{
    local mfile=${third_party_folder}/CMakeLists.txt
    
    if [[ -z ${third_party_folder} ]] ; then
        echo "runtime env not set"
        return -1;
    fi;
    
    if [[ -f ${mfile} ]] ; then
        echo -e "sed -n \"/Set.*PNVMET_GIT_TAG.*/p\" $mfile";
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

dellcdpnvmetfolderinthirdparty ()
{
    local pnvmet_folder_in_third_party=${cyclone_folder}/source/third_party/cyc_platform/obj_Release/third_party/PNVMeT
    
    if [ ! -d ${pnvmet_folder_in_third_party} ] ; then
        echo -e "${RED}${pnvmet_folder_in_third_party} not found${NC}";
        return -1;
    fi;

    cd ${pnvmet_folder_in_third_party};
    return 0;
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


dellcdvduser ()
{
    local user=${1};
    cd /home/${user};
}

alias dellcdvdamite='dellcdvduser amite'
alias dellcdvdgrupie='dellcdvduser grupie'
alias dellcdvdeldadz='dellcdvduser eldadz'

alias dellcd-qa-tests='cd /home/trqa-dev/tests/connectivity_and_protocols/nvmeof'

dellpnvmetfolderset ()
{
    local p=$(pwd);
    ask_user_default_yes "set pnvmet folder to : ${p}";
    [ $? -eq 0 ] && return;

    export pnvmet_folder=${p};

    if [ -n "${cyclone_folder}" ] && [ -e "${cyclone_folder}/.dellclusterruntimeenvbkpfile" ] ; then
        if [ $(grep pnvmet_folder ${cyclone_folder}/.dellclusterruntimeenvbkpfile | wc -l ) -gt 0 ] ; then
            p=$(echo $pnvmet_folder |sed 's/\//\\\//g');
            sed -i "s/pnvmet_folder=.*/pnvmet_folder=${p}/g" ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
        else
            echo "export pnvmet_folder=${pnvmet_folder}" >> ${cyclone_folder}/.dellclusterruntimeenvbkpfile;
        fi;

        if [ $(grep pnvmet_folder ${dellclusterglobalruntimeenvbkpfile} | wc -l ) -gt 0 ] ; then
            p=$(echo $pnvmet_folder |sed 's/\//\\\//g');
            sed -i "s/pnvmet_folder=.*/pnvmet_folder=${p}/g" ${dellclusterglobalruntimeenvbkpfile};
        else
            echo "export pnvmet_folder=${pnvmet_folder}" >> ${dellclusterglobalruntimeenvbkpfile};
        fi;
    fi;
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

        dellpnvmetfolderset;
    fi
    
    echo -e "update ${RED}${mfile}${NC} with ${GREEN}${sha}${NC}";
    ask_user_default_yes "continue ";
    sed -i "s/\(Set.*PNVMET_GIT_TAG.*\"\).*\(\".*\)/\1${sha}\2/g" $mfile;
    dellcdthirdparty;
    print_underline_size "_" 80;
    git --no-pager diff -U1;
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

dellibidofficial ()
{
    local ibid=${1};
    local cyclone_commit_id=;

    cyclone_commit_id=$(phlibid --getCommit --ibid ${ibid} | grep "Commit ID" | cut -f 2 -d ":");
    echo "cyclone commit id: ${cyclone_commit_id}";
    if [ -z "${cyclone_commit_id}" ] ; then
        echo "bad ibid :  ${ibid}";
        return -1;
    fi;
    2>&1 1>/dev/null pushd ~/devel/cyclones/cyclone.tmp
    2>/dev/null git fetch
    echo ${cyclone_commit_id} > x;
    truncate -s -2 x;
    cyclone_commit_id=$(cat x);
    2>&1 1>/dev/null rm -f x;
    #git log -1 ${cyclone_commit_id}
    echo "git show ${cyclone_commit_id}"
    git show ${cyclone_commit_id}
    2>&1 1>/dev/null popd;
}

dellpnvmetgetshaindexfrombranch ()
{
    local branch=${1};

    #read -p "cd to cyclone.tmp ?" x;
    pushd ~/devel/cyclones/cyclone.tmp 2>&1 1>/dev/null;
    #read -p "git fetch ?" x;

    ask_user_default_no "do git fetch before ?"
    if [ $? -eq 1 ] ; then
        echo -e "${BLUE}$(pwd) : git fetch${NC}";
        git fetch;
    fi;

    if [ -z ${branch} ] ; then
        branch="$(git b -r |sed 's/.*origin\///g'| fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
        if [ -z ${branch} ] ; then
            echo "missing branch : dellpnvmetgetshaindexfrombranch <branch>";
            return -1;
        fi;
    fi;

    #read -p "git checkout ${branch} ?" x;
    echo -e "${BLUE}$(pwd) : git checkout ${branch}${NC}";
    git checkout ${branch};
    #read -p "git sm update third_parth ?" x;
    echo -e "${BLUE}$(pwd) : git sm update source/third_party${NC}";
    git sm update source/third_party
    echo -e "${YELLOW}[${branch}]";
    grep "Set.*PNVMET_GIT_TAG"  source/third_party/cyc_platform/src/third_party/PNVMeT/CMakeLists.txt
    echo -e "${NC}";
    popd 2>&1 1>/dev/null;

}

dellibid2commitpnvmet ()
{
    local ibid=${1};
    local third_party_commitid=;


    pushd ~/devel/third_party 2>&1 1>/dev/null;
    phlibid --getCommit --ibid ${ibid} | grep third_party | cut -f 2 -d ":" > x;
    truncate -s -2 x;
    third_party_commitid=$(cat x);
    rm -f x 2>&1 1>/dev/null;
    git fetch 2>&1 1>/dev/null;
    echo "$(pwd) : git checkout $third_party_commitid";
    (2>/dev/null git checkout $third_party_commitid) 
    grep "Set.*PNVMET_GIT_TAG"  cyc_platform/src/third_party/PNVMeT/CMakeLists.txt
    popd 2>&1 1>/dev/null;
}


dellibid2commit ()
{
    local ibid=$1;
    echo -e "${GREEN}phlibid.pl --ibid ${ibid}${NC}";
    echo -e "${GREEN}---------------------------------------------------------------"${NC}
    phlibid.pl --ibid ${ibid} | head -18;
    echo ===============================================================
    # phlibid.pl --ibid ${ibid} | grep --color -i commit
    echo -e "${GREEN}phlibid --getCommit --ibid ${ibid}${NC}";
    echo -e "${GREEN}---------------------------------------------------------------${NC}"
    phlibid --getCommit --ibid ${ibid} > .dellibid2commitid;
    grep "nt-nvmeof\|third_party\|cyc_core\ \|Commit ID" .dellibid2commitid | sed -e "s/Commit ID/Commit-id/g" -e "s/\ //g" | sed "s/:/\ /g" | column -t ;
    rm -f .dellibid2commitid > /dev/null;

}

dellibidgitcheckout ()
{
    local ibid=${1};
    local pdr_git_index=;
    local cmd=;
    # checkout pdr of git hash pertaining ibid
    pdr_git_index=$(phlibid --getCommit --ibid ${ibid}  |grep "Commit ID" | sed 's/\ //g' | cut -d ':' -f 2);
    if [ -z "${pdr_git_index}" ] ; then
        echo "failed to get git index for ibid ${ibid}";
        return -1;
    fi;

    echo "git checkout -b dev/ycohen/ibid-${ibid} ${pdr_git_index}";
    ask_user_default_yes "continue ?";
    if [ $? -eq 0 ] ; then
        return 0;
    fi;

    echo $pdr_git_index > x 
    truncate -s -2 x
    git checkout -b dev/ycohen/ibid-$ibid $(cat x)
    2>&1 1>/dev/null rm -f x;
    return 0;
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

alias delltriage-mber-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j SUB_COMPONENT=mbe_r"
alias delltriage-mber-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j SUB_COMPONENT=mbe_r"
alias delltriage-mber-logs-node-a-r="nice -20 ./cyc_triage.pl -b . -n a -j SUB_COMPONENT=mbe_r -r"
alias delltriage-mber-logs-node-b-r="nice -20 ./cyc_triage.pl -b . -n b -j SUB_COMPONENT=mbe_r -r"

alias delltriage-kernel-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -t kernel"
alias delltriage-kernel-logs-node-a-r="nice -20 ./cyc_triage.pl -b . -n a -j -- -t kernel -r"
alias delltriage-kernel-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -t kernel"
alias delltriage-kernel-logs-node-b-r="nice -20 ./cyc_triage.pl -b . -n b -j -- -t kernel-r"

alias delltriage-sym-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -t xtremapp"
alias delltriage-sym-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -t xtremapp"

alias delltriage-cycbsc-logs-node-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -t cyc_bsc"
alias delltriage-cycbsc-logs-node-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -t cyc_bsc"

alias delltriage-grep-panic-a='delltriage-all-logs-node-a | grep --color "PANIC\|log_backtrace_backend\|panic-\|signal_handler"'
alias delltriage-grep-panic-b='delltriage-all-logs-node-b | grep --color "PANIC\|log_backtrace_backend\|panic-\|signal_handler"'

alias delltriage-grep-connect-a='delltriage-nt-logs-node-a | grep --color "nvme controller.*alloc"'
alias delltriage-grep-connect-b='delltriage-nt-logs-node-b | grep --color "nvme controller.*alloc"'

alias delltriage-grep-connect-queue-a='delltriage-all-logs-node-a | grep --color "process_connec.*sq_id\|install.*queu\|fc_.*alloc.*queue\|fc_.*create_association\|nvme.*allocate\|discover.*allocate"'
alias delltriage-grep-connect-queue-b='delltriage-all-logs-node-b | grep --color "process_connec.*sq_id\|install.*queu\|fc_.*alloc.*queue\|fc_.*create_association\|nvme.*allocate\|discover.*allocate"'

alias delltriage-grep-disconnect-host-a='delltriage-nt-logs-node-a | grep --color "io_ctrl.*disconnect.*host"'
alias delltriage-grep-disconnect-host-b='delltriage-nt-logs-node-b | grep --color "io_ctrl.*disconnect.*host"'
alias delltriage-grep-disconnect-host-tcp-a='delltriage-nt-logs-node-a | grep --color "io_ctrl.*disconnect.*trtype tcp.*host"'
alias delltriage-grep-disconnect-host-tcp-b='delltriage-nt-logs-node-b | grep --color "io_ctrl.*disconnect.*trtype tcp.*host"'
alias delltriage-grep-disconnect-host-fc-a='delltriage-nt-logs-node-a | grep --color "io_ctrl.*disconnect.*trtype fc.*host"'
alias delltriage-grep-disconnect-host-fc-b='delltriage-nt-logs-node-b | grep --color "io_ctrl.*disconnect.*trtype fc.*host"'

alias delltriage-grep-disconnect-a='delltriage-all-logs-node-a | grep --color "io_ctrl.*disconnect\|tcp_state_change"'
alias delltriage-grep-disconnect-b='delltriage-all-logs-node-b | grep --color "io_ctrl.*disconnect\|tcp_state_change"'

alias delltriage-grep-disconnect-queue-a='delltriage-all-logs-node-a | grep --color "pnvmet_disconnect\|nvmet_fc_fcp_disconnec\|nvmet_tcp_disconnect.*qid\|io_ctrl.*disconnect"'
alias delltriage-grep-disconnect-queue-b='delltriage-all-logs-node-b | grep --color "pnvmet_disconnect\|nvmet_fc_fcp_disconnec\|nvmet_tcp_disconnect\|io_ctrl.*disconnect"'

alias delltriage-grep-add-port-a='delltriage-nt-logs-node-a | grep --color "add_ports.*is_local true"'
alias delltriage-grep-add-port-fc-a='delltriage-nt-logs-node-a | grep --color "add_ports.*trtype fc.*is_local true"'
alias delltriage-grep-add-port-tcp-a='delltriage-nt-logs-node-a | grep --color "add_ports.*trtype tcp.*is_local true"'
alias delltriage-grep-add-port-b='delltriage-nt-logs-node-b | grep --color "add_ports.*is_local true"'
alias delltriage-grep-add-port-fc-b='delltriage-nt-logs-node-b | grep --color "add_ports.*trtype fc.*is_local true"'
alias delltriage-grep-add-port-tcp-b='delltriage-nt-logs-node-b | grep --color "add_ports.*trtype tcp.*is_local true"'

alias delltriage-grep-nt-start-a='delltriage-nt-logs-node-a | grep --color "nt_start"'
alias delltriage-grep-nt-start-b='delltriage-nt-logs-node-b | grep --color "nt_start"'

alias delltriage-grep-set-active-a='delltriage-nt-logs-node-a | grep --color "nt_disc_set_active\|nt_disc_set_inactive"'
alias delltriage-grep-set-active-b='delltriage-nt-logs-node-b | grep --color "nt_disc_set_active\|nt_disc_set_inactive"'

alias delltriage-grep-pnvmet-start-a='delltriage-kernel-logs-node-a | grep --color "nvmet_power.*driver.*start"'
alias delltriage-grep-pnvmet-start-b='delltriage-kernel-logs-node-b | grep --color "nvmet_power.*driver.*start"'

alias delltriage-grep-cluster-name-a='delltriage-all-logs-node-a | grep -i --color "cyc_config.*creating cluster"'
alias delltriage-grep-cluster-name-b='delltriage-all-logs-node-b | grep -i --color "cyc_config.*creating cluster"'
#alias delltriage-grep-appliance-name-a='delltriage-all-logs-node-a | grep "Service.*name : Appliance"'
#alias delltriage-grep-appliance-name-b='delltriage-all-logs-node-b | grep "Service.*name : Appliance"'
alias delltriage-grep-appliance-name-a='delltriage-nt-logs-node-a | grep -i "log_subsys" | grep --color name'
alias delltriage-grep-appliance-name-b='delltriage-nt-logs-node-b | grep -i "log_subsys" | grep --color name'

alias delltriage-grep-add-remove-device-a='delltriage-nt-logs-node-a | grep -i --color "add_device\|add_namespace\|remove_device\|remove_nsid\|remove_namespace"'
alias delltriage-grep-add-remove-device-b='delltriage-nt-logs-node-b | grep -i --color "add_device\|add_namespace\|remove_device\|remove_nsid\|remove_namespace"'

alias delltriage-servicemode-logs-a="nice -20 ./cyc_triage.pl -b . -n a -j -- -t servicemode"
alias delltriage-servicemode-logs-b="nice -20 ./cyc_triage.pl -b . -n b -j -- -t servicemode"

alias delltriage-grep-nt-kernel-a='delltriage-all-logs-node-a |grep "\[nt\]\|kernel"|less -I'
alias delltriage-grep-nt-kernel-a-r='delltriage-all-logs-node-a-r |grep "\[nt\]\|kernel"|less -I'
alias delltriage-grep-nt-kernel-b='delltriage-all-logs-node-b |grep "\[nt\]\|kernel"|less -I'
alias delltriage-grep-nt-kernel-b-r='delltriage-all-logs-node-b-r |grep "\[nt\]\|kernel"|less -I'
alias delltriage-host-grep-connect-fc='grep "nvme.*create assoc" messages|grep -v discovery'
alias delltriage-host-grep-connect='grep "nvme.*new ctrl" messages|grep -v discovery'

alias delltriage-grep-version-a='delltriage-all-logs-node-a | grep -i --color "software revision"'
alias delltriage-grep-version-b='delltriage-all-logs-node-b | grep -i --color "software revision"'
delltriage-host-grep-traddr ()
{
    traddr_file=$1;
    grep -o "nvme.*traddr=[^ ]*" ${traddr_file};
}

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

alias delldc-xtremapp-node-a='_delldc-node-x node_a "-t xtremapp"'
alias delldc-xtremapp-node-b='_delldc-node-x node_b "-t xtremapp"'
alias delldc-xtremapp-node-a-r='_delldc-node-x node_a "-t xtremapp -r"'
alias delldc-xtremapp-node-b-r='_delldc-node-x node_b "-t xtremapp -r"'

alias delldc-grep-connect-a='delldc-nt-node-a | grep --color  "nvme control.*alloc"'
alias delldc-grep-connect-b='delldc-nt-node-b | grep --color  "nvme control.*alloc"'
alias delldc-grep-connect-disconnect-a='delldc-nt-node-a | grep --color  "nvme control.*alloc\|log_io.*discon"'
alias delldc-grep-connect-disconnect-b='delldc-nt-node-b | grep --color  "nvme control.*alloc\|log_io.*discon"'

alias delldc-grep-connect-tcp-a='delldc-nt-node-a | grep --color  "nvme control.*alloc.*trtype tcp"'
alias delldc-grep-connect-tcp-b='delldc-nt-node-b | grep --color  "nvme control.*alloc.*trtype tcp"'
alias delldc-grep-connect-disconnect-tcp-a='delldc-nt-node-a | grep --color  "nvme control.*alloc.*trtype tcp\|log_io.*discon.*trtype tcp"'
alias delldc-grep-connect-disconnect-tcp-b='delldc-nt-node-b | grep --color  "nvme control.*alloc.*trtype tcp\|log_io.*discon.*trtype tcp"'

alias delldc-grep-add-port-a='delldc-nt-node-a | grep --color "add_ports.*is_local true"'
alias delldc-grep-add-port-fc-a='delldc-nt-node-a | grep --color "add_ports.*trtype fc.*is_local true"'
alias delldc-grep-add-port-tcp-a='delldc-nt-node-a | grep --color "add_ports.*trtype tcp.*is_local true"'
alias delldc-grep-add-port-b='delldc-nt-node-b | grep --color "add_ports.*is_local true"'
alias delldc-grep-add-port-fc-b='delldc-nt-node-b | grep --color "add_ports.*trtype fc.*is_local true"'
alias delldc-grep-add-port-tcp-b='delldc-nt-node-b | grep --color "add_ports.*trtype tcp.*is_local true"'

delldc-file-list ()
{
    echo "on the root directory of the DC"
    echo "<test name>.log.core.debug"
    echo "<test name>.log.debug: e.g CP_HA_MSTP_TEST-wk-d5206-251113-082750.log.core.debug"
    echo;
    echo "servie-data/triage_analysis/TIMELINE"
    echo "service-data/node_a/command_output/housemd";
    echo "==========================================";
    echo "show_volumes_print_type__csv_.txt"
    echo "show_lun_mappings_print_type__csv_.txt"
    echo "show_initiator_groups_print_type__csv_.txt – Note that “nvme_maps” is always 0 even if there are NVME mappings, from what I’ve seen"
    echo "show_initiators_print_type__csv_.txt"
    echo "show_initiators_connectivity_print_type__csv_.txt – This is for SCSI connections from registered initiators (ie. initiators in initiator groups).  If an initiator is not logged in at all, it won’t be in the file.  "
    echo "show_discovered_initiators_connectivity_print_type__csv_.txt – This is for SCSI connections from unregistered initiators"
    echo "show_nvme_host_connectivity_print_type__csv_.txt "
    echo "show_nvme_discover_host_connectivity_print_type__csv_.txt "
    echo "column -s, -t -N show_nvme_subsystem_ports_targets"
    echo
    echo "show_ioms"
    echo "show_feports - link issues"
    echo "show_sfps"
    echo "show_scsi_targets"
    echo "show_target_port_groups "
    echo "show_scsi_registrations – This has an entry for every volume regardless of whether it has a registration or not.  There is an NVME version too."
    echo "show_scsi_reservations "
    echo "fcc.sh_stats"
    echo "fabric_disruption"
    echo "appliance.json : for multi appliance of federation will resolve powerstore names to their tags"
    echo "TIMELINE - use delldc-grep-chipthompson-TIMELINE"
}

delldc-show-connectivity ()
{
    local housemd_file=;

    echo > show_connectivity.txt;

    echo "searching for [show_ioms_print_type__csv_.txt]"
    housemd_file=$(fd -t f show_ioms_print_type__csv_.txt);
    echo -e  "found : ${housemd_file}";
    ask_user_default_yes "continue";
    if [ $? -eq 1 ] ; then
        echo "===> show_ioms_print_type__csv_.txt <====" >> show_connectivity.txt
        cat ${housemd_file} | column -s, -t -o " | "  >> show_connectivity.txt
    fi;

    echo -e "searching for [show_feport_print_type__csv_.txt]";
    housemd_file=$(fd -t f show_feport_print_type__csv_.txt);
    echo -e  "found : ${housemd_file}";
    ask_user_default_yes "continue";
    if [ $? -eq 1 ] ; then
        echo -e "\n\n===> show_feport_print_type__csv_.txt <====" >> show_connectivity.txt
        cat ${housemd_file} | column -s, -t -o " | "  >> show_connectivity.txt
    fi;

    echo "searching for [show_nvme_host_connectivity_print_type__csv_.txt]";
    housemd_file=$(fd -t f show_nvme_host_connectivity_print_type__csv_.txt);
    echo -e  "found : ${housemd_file}";
    ask_user_default_yes "continue";
    if [ $? -eq 1 ] ; then
        echo -e "\n\n===> show_nvme_host_connectivity_print_type__csv_.txt <====" >> show_connectivity.txt
        cat ${housemd_file} | column -s, -t -o " | "  >> show_connectivity.txt
    fi;

    echo -e "\n\ncreated file : show_connectivity.txt";
    ask_user_default_yes "open the file and search for link_down_in_use? "
    if [ $? -eq 0 ] ; then return ; fi; 
    v show_connectivity.txt
}

delldc-grep-chipthompson-TIMELINE ()
{ 
    if [ -e TIMELINE  ] ; then
        grep -e FAULT -e QA -e PYTEST -e PANIC -e PUHC_ERROR -e FLOW_ERR -e NDU.REBOOT -e ndu_prepare -e ndu_perpare -e NDU_RESULT_UPGRADE_FAILED -e NDU_RESULT_UPGRADE_SUCCEEDED -e NDU_RESULT_ROLLBACK_SUCCEEDED -e BSC.starting -e PM.Start -e PKILL -e _PM TIMELINE
    else
        echo "missing file TIMELINE";
    fi;
}

delldc-xtrace-morty-datacollect ()
{
    echo "on the service-data folder invoke : morty_datacollect"
}

devin-install ()
{
    curl -fsSL  https://cli.devin.ai/install.sh | bash
}

devin-config-file ()
{
    echo " ~/.config/devin/config.json";
    echo "================================";
    cat ~/.config/devin/config.json;
}

devin-mcp-server-config-file ()
{
    echo " ~/.config/devin/mcp_config.json";
    echo "================================";
    cat ~/.config/devin/mcp_config.json;
}

devin-powerstoreai-skill-update ()
{
    # check if this is a git repo at all
    git b 2>/dev/null
    if [ $? -ne 0 ] ; then
        echo "this is not a git repo";
        return -1;
    fi;

    # check that you are in the powerstore ai repo
    if [ $(git r |grep PowerStore-AI | wc -l ) -eq 0 ] ; then 
        echo "this is not PowerStore-AI repo";
        return -1;
    fi;

    echo "about to do :";
    echo "=============";
    echo "(1) git pull";
    echo "(2) ./helpers/configure-global-rules.sh --setup"
    echo "(3) source ~/.bashrc"
    echo "(4) ./sync_global_workflows.sh -y"

    ask_user_default_no "continue ? ";
    if [ $? -eq 0 ] ; then
        return 0;
    fi;

    git pull;
    ./helpers/configure-global-rules.sh --setup
    source ~/.bashrc
    ./sync_global_workflows.sh -y
}

devin-powerstoreai-install ()
{
    echo "git clone git@eos2git.cec.lab.emc.com:cyclone/PowerStore-AI.git"
    print_underline_size "_" 80;

    ask_user_default_yes "continue ? ";
    if [ $? -eq 0 ] ; then return ; fi;
    git clone git@eos2git.cec.lab.emc.com:cyclone/PowerStore-AI.git;
    echo;

    echo "about to : "
    echo "(1) cd PowerStore-AI"
    echo "(2) ./helpers/configure-global-rules.sh --setup"

    ask_user_default_yes "continue ? ";
    if [ $? -eq 0 ] ; then return ; fi;

    echo "cd PowerStore-AI" 
    print_underline_size "_" 80;
    cd PowerStore-AI

    echo "./helpers/configure-global-rules.sh --setup";
    print_underline_size "_" 80;
    ./helpers/configure-global-rules.sh --setup

    echo "now do : "
    echo "(1) source ~/.bashrc";
    echo "(2) ./sync_global_workflows.sh -y";

}

dellgit-sshkey ()
{
    ssh-keygen -o -t rsa -C "ssh@eos2git.cec.lab.emc.com"
    cat ~/.ssh/id_rsa.pub
    echo "register this key with github"
}

alias yonidellsshkeyset='ssh-copy-id -i ~/.ssh/id_rsa.pub y_cohen@10.55.226.121'
alias yyy='yonidellsshkeyset'

# ------------------------------------------------------------------------------------
#                python 
# from /home/y_cohen folder invoke this which spins a docker that is running python3.11 as server 
# ------------------------------------------------------------------------------------
# that you can access from web browser with : http://127.0.0.1:8888/lab
# docker run -p 8888:8888 -v ${PWD}:/home/y_cohen jupyter/base-notebook
# ------------------------------------------------------------------------------------
# to run pycharm go to /home/y_cohen/Downloads/pycharm-community-2024.1.4/bin
# and do ./pycharm.py
pycharm ()
{
    cd /home/y_cohen/Downloads/pycharm-community-2024.1.4/bin;
    ./pycharm.sh
}
# ------------------------------------------------------------------------------------
