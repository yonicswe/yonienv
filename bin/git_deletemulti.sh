#!/bin/bash

branch_filter=${1};
branch_list=();
branches=();
delete_branches=();

if [ -n "${branch_filter}" ] ; then
    branch_list=($(git b | grep ${branch_filter}| sed '/\*.*/d'));
else
    branch_list=($(git b | sed '/\*.*/d'));
fi;

for b in ${branch_list[@]} ; do
    branches+=($b "" off);
done;

# calulate size and hight of menu
#s=${#branches[@]};
#h=$((2 * $s));

delete_branches=($(whiptail --checklist "delete branch" 20 100 10 "${branches[@]}" 3>&1 1>&2 2>&3));
delete_branches=($(echo ${delete_branches[@]} | sed 's/"//g'));

for b in ${delete_branches[@]} ; do
    echo -e  "git delete branch ${RED}$b${NC}";
    git bdelete $b;
done;
