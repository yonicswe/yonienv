#!/bin/bash

branch="$(git b | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

if [ -n "${branch}" ] ; then
    echo "git checkout branch : ${branch}";
    git checkout ${branch};
fi;
