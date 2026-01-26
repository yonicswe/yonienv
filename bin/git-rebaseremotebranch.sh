#!/bin/bash

source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_fs.sh

rebase_remote_branch_bkp_file=~/.rebase_remote_branch;
if [ -e ${rebase_remote_branch_bkp_file} ] ; then
    last_used_branch=$(cat ${rebase_remote_branch_bkp_file})
fi;

branch=$1;

if [[ -z "${branch}" && -n "${last_used_branch}" ]] ; then
    ask_user_default_no "use again ?  ${last_used_branch}" 
    if [ $? -eq 1 ] ; then
        branch=${last_used_branch};
    fi;
fi;

if [ -z "${branch}" ] ; then
    if [[ $(git br|wc -l) -eq 0 ]] ; then
        echo "you probably just cloned linux repo you must also do git fetch" 
        ask_user_default_no "continue with fetch ?";
        if [[ $? -eq 0 ]] ; then
            exit;
        fi;
        git fetch origin
    else
        ask_user_default_no "git fetch before we start ? ";
        if [ $? -eq 1 ] ; then
            git fetch origin;
        fi;
    fi;

    branch="$(git br | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
    if [ -z "${branch}" ] ; then
        exit;
    fi;
    branch=$(echo ${branch} | sed 's/origin\///g');
fi;

if [ -z "${branch}" ] ; then
    exit;
fi;

echo ${branch} > ${rebase_remote_branch_bkp_file};
echo -e "\t${BLUE}git fetch origin ${GREEN}${branch}${NC}";
echo -e "\t${BLUE}git rebase ${GREEN}FETCH_HEAD${NC}";
ask_user_default_no  "continue ?";
if [ $? -eq 0 ] ; then
    exit;
fi;

echo "git fetch origin ${branch};";
git fetch origin ${branch};
echo "git rebase FETCH_HEAD;";
git rebase FETCH_HEAD;
