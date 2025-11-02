#!/bin/bash

source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_fs.sh

remote_branch=$1;

if [ -z "${remote_branch}" ] ; then
    ask_user_default_no "git fetch before we start ? ";
    if [ $? -eq 1 ] ; then
        git fetch origin;
    fi;

    remote_branch="$(git br |sed 's/.*origin\///g'| fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
fi;

if [[ -z ${remote_branch} ]] ; then
    echo "you must specify a valid branch";
    exit;
fi;

echo "remote branch : ${remote_branch}";

echo "git branch --set-upstream-to=origin/${remote_branch};";
ask_user_default_no  "continue ?";
if [ $? -eq 0 ] ; then
    exit;
fi;

git branch --set-upstream-to=origin/${remote_branch};
