#!/bin/bash
source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_fs.sh

remote_branch=$1;
local_branch=;
with_force=;

remote_branch_bkp_file=~/.remote_branch;
if [ -e ${remote_branch_bkp_file} ] ; then
    last_used_branch=$(cat ${remote_branch_bkp_file})
    #complete -W "$(echo ${last_used_branch})" git
fi;

if [[ -z "${remote_branch}" && -n "${last_used_branch}" ]] ; then
    ask_user_default_no "use again ?  ${last_used_branch}" 
    if [ $? -eq 1 ] ; then
        remote_branch=${last_used_branch};
    fi;
fi;

if [[ -z "${remote_branch}" ]] ; then
    if [[ $(git b|wc -l) -eq 0 ]] ; then
        echo "you probably just cloned linux repo doing git fetch" 
        git fetch -p;
    else
        ask_user_default_no "git fetch before we start ? ";
        if [ $? -eq 1 ] ; then
            git fetch -p;
        fi;
    fi;
    remote_branch="$(git br |sed 's/.*origin\///g'| fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
fi;

if [[ -z ${remote_branch} ]] ; then
    echo "you must specify a valid branch";
    exit;
fi;

echo "remote branch : ${remote_branch}";

ask_user_default_no "rename the branch ? ";
if [ $? -eq 1 ] ; then
    read -p "new name : " local_branch;
else
    local_branch=${remote_branch};
fi;

echo ${remote_branch} > ${remote_branch_bkp_file};

for b in $(git b |grep -v HEAD ) ; do
    if [[ ${b} == "${local_branch}" ]] ; then 
        echo "${local_branch} already checked out !! remove it and try again";
        echo "doing return";
        exit;
    fi;
done;

read -p "with force ? [y/N]" ans;
if [[ "${ans}" =~ "y" ]] ; then
    with_force='-f';
fi;

echo -e  "\t${GREEN}git fetch origin ${YELLOW}${remote_branch}${NC}";
echo -e  "\t${GREEN}git checkout ${with_force} -b ${YELLOW}${local_branch}${GREEN} FETCH_HEAD${NC}";

ask_user_default_no "continue";
if [ $? -eq 0 ] ; then exit ; fi;


git fetch origin ${remote_branch};
git checkout ${with_force} -b ${local_branch} FETCH_HEAD;

echo "would you like to set ${local_branch} to track upstream ${remote_branch}";
ask_user_default_yes;
if [ $? -eq 1 ] ; then
    git branch --set-upstream-to=origin/${remote_branch};
fi;

exit;
