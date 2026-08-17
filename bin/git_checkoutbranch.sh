#!/bin/bash

branch=${1}
with_force=;

if [[ -z "${branch}" ]] ; then 
    branch="$(git b | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
fi;

if [ -n "${branch}" ] ; then
    read -p "with force ? [y/N]" ans;
    if [[ "${ans}" =~ "y" ]] ; then
        with_force='-f';
    fi;
    echo "git checkout ${with_force} branch : ${branch}";
    git checkout ${with_force} ${branch};
fi;
