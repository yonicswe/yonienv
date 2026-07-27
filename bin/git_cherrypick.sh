#!/bin/bash

if (( $# == 2 )) ; then
    c1=$1;
    c2=$2;
    echo "git cherry-pick ${c2}^..${c1}"
    git log --oneline --pretty=format:'%C(yellow) %h %Cred%<(9,trunc)%aN %Cgreen%s %Creset' ${c2}^..${c1}
    read -p "continue [Y/n]" ans;
    if [[ ${ans} =~ "n" ]] ; then
        exit;
    fi;
    git cherry-pick ${c2}^..${c1}
    exit;
fi;

branch="$(git b | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

if [ -n "${branch}" ] ; then
    echo "git cherry-pick ${branch}";
    git cherry-pick ${branch};
fi;
