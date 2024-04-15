#!/bin/bash

branch=${1};


if [[ -z "${branch}" ]] ; then
    branch="$(git b | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"
fi;

if [[ -z "${branch}" ]] ; then
    echo "missing branch name";
    exit;
fi;

git branch -D ${branch};


