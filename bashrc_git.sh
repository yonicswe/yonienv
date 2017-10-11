#!/bin/bash

alias gitdiffvim='git difftool --tool=vimdiff --no-prompt'
alias gitdiffgvim='git difftool --tool=gvimdiff --no-prompt'
alias gitdiffkdiff='git difftool --tool=kdiff3 --no-prompt'
alias gitdiffstat='git --no-pager diff --stat'
alias gitlog='git log --name-status'
alias gitmkhook='gitdir=$(git rev-parse --git-dir); scp -p -P 29418 yonatanc@l-gerrit.mtl.labs.mlnx:hooks/commit-msg ${gitdir}/hooks/'
alias gitd='git d'
gitb () 
{
    git b | awk '/^\*/{print $1" "$2} !/^\*/{print "  "$1}'
}

