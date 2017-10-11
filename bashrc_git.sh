#!/bin/bash

alias gitdiffvim='git difftool --tool=vimdiff --no-prompt'
alias gitdiffgvim='git difftool --tool=gvimdiff --no-prompt'
alias gitdiffkdiff='git difftool --tool=kdiff3 --no-prompt'
alias gitdiffstat='git --no-pager diff --stat'
alias gitlog='git log --name-status'
alias gitmkhook='gitdir=$(git rev-parse --git-dir); scp -p -P 29418 yonatanc@l-gerrit.mtl.labs.mlnx:hooks/commit-msg ${gitdir}/hooks/'

gitpushtogerrit ()
{
    branch=${1};
    topic=${2};
    remote=${3:-origin};

    if [ $# -lt 2 ] ; then 
         echo "less than 3 params branch=${branch}, topic=${topic}, remote=${remote}" 
    fi              

    if [ -z ${branch} ] || [ -z ${topic} ] ; then 
        echo "missing branch and/or topic"
    else 
        echo "git push ${remote} HEAD:refs/for/${branch}/${topic}"
        git push ${remote} HEAD:refs/for/${branch}/${topic}
    fi

}
