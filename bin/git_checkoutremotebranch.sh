#!/bin/bash
source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_fs.sh

remote_branch=;
local_branch=;

ask_user_default_no "git fetch before we start ? ";
if [ $? -eq 1 ] ; then
    git fetch -p;
fi;

remote_branch="$(git b -r |sed 's/.*origin\///g'| fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

if [[ -z ${remote_branch} ]] ; then
    echo "you must specify a valid branch";
    return -1;
fi;

echo "remote branch : ${remote_branch}";

ask_user_default_no "rename the branch ? ";
if [ $? -eq 1 ] ; then
    read -p "new name : " local_branch;
else
    local_branch=${remote_branch};
fi;

for b in $(git b |grep -v HEAD ) ; do
    if [[ ${b} == "${local_branch}" ]] ; then 
        echo "${local_branch} already checked out !! remove it and try again";
        echo "doing return";
        return -1;
    fi;
done;

echo -e  "\t${GREEN}git fetch origin ${YELLOW}${remote_branch}${NC}";
echo -e  "\t${GREEN}git checkout -b ${YELLOW}${local_branch}${GREEN} FETCH_HEAD${NC}";

ask_user_default_no "continue";
if [ $? -eq 0 ] ; then return -1; fi;

git fetch origin ${remote_branch};
git checkout -b ${local_branch} FETCH_HEAD;

echo "would you like to set ${local_branch} to track upstream ${remote_branch}";
ask_user_default_yes;
if [ $? -eq 1 ] ; then
    git branch --set-upstream-to=origin/${remote_branch};
fi;

return 0;
