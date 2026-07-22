#!/bin/bash
branch=${1};
if [ -z ${branch} ] ; then
    branch="$(git br | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
fi;

if [ -n "${branch}" ] ; then
    echo "git ll ${branch}";
    git ll origin ${branch};
fi;
