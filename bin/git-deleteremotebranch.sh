#!/bin/bash
source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_fs.sh

remote_branch=$1;

if [[ -z "${remote_branch}" ]] ; then
    if [[ $(git br|wc -l) -eq 0 ]] ; then
        echo "you probably just cloned the repo you must also do git fetch" 
        ask_user_default_no "continue with fetch ?";
        if [[ $? -eq 0 ]] ; then
            exit;
        fi;
        git fetch origin
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

echo -e  "about to : ${GREEN}git push -d origin ${YELLOW}${remote_branch}${NC}";
ask_user_default_no "delete the remote branch ? ";

git push -d remote branch;

# check if remote branch is also checkout already
for b in $(git b |grep -v HEAD ) ; do
    if [[ ${b} == "${remote_branch}" ]] ; then 
        echo "${remote_branch} is also checked out locally";
    fi;
done;

echo "would you like to clean local git repo";
echo -e  "\t${GREEN}git fetch -p${NC}";
ask_user_default_yes;
if [ $? -eq 1 ] ; then
    git fetch -p;
fi;

exit;
