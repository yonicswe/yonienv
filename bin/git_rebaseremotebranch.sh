#!/bin/bash

source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_fs.sh

ask_user_default_no "git fetch before we start ? ";
if [ $? -eq 1 ] ; then
    git fetch origin;
fi;

branch="$(git br | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

if [ -z "${branch}" ] ; then
    exit;
fi;

branch=$(echo ${branch} | sed 's/origin\///g');

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
