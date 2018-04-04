#!/bin/bash

alias gitdiffvim='git difftool --tool=vimdiff --no-prompt'
# alias gitdiffgvim='git difftool --tool=gvimdiff --no-prompt'
alias gitdiffkdiff='git difftool --tool=kdiff3 --no-prompt'
alias gitdiffstat='git --no-pager diff --stat'
alias gitlog='git log --name-status'
alias gitmkhook='gitdir=$(git rev-parse --git-dir); scp -p -P 29418 yonatanc@l-gerrit.mtl.labs.mlnx:hooks/commit-msg ${gitdir}/hooks/'
alias gitd='git d'
# alias gitdiscardunstaged='git checkout -- .'
alias gitstashunstaged='git stash --keep-index'
alias gitunstageall='git reset HEAD'
alias gituncommit='git reset --soft HEAD^'
gitb () 
{
    local branch="$1"
#     git b | awk '/^\*/{print "\033[32m-->["$2"]\033[0m"} !/^\*/{print "    "$1}'
    if [ -z ${branch} ] ; then   
        git b | sed 's/^\*\ /-->\ /g' | awk '/-->/{print "\033[31m" $1 " " $2  "\033[0m"} !/-->/{print "    "$1}'
    else
        git b | sed 's/^\*\ /-->\ /g' | awk '/-->/{print "\033[31m" $1 " " $2  "\033[0m"} !/-->/{print "    "$1}' | grep "${branch}"
    fi
}

gitdiscardmodified () 
{
    local ans;
    local -a discardlist;
    discardlist=( $(git status -uno -s | awk '{print $2}') );

    echo ${#discardlist[@]}
    echo ${discardlist[@]}

    if [ ${#discardlist[@]} -gt 0 ] ; then 
        echo "about to discard "
        for i in ${discardlist[@]} ; do 
            echo -e "\t$i";
        done;

        read -p "Are you sure [y/N]" ans;
        if [ "$ans" == "y" ] ; then
            git status -uno -s | awk '{system("git checkout " $2)}';
        fi
    fi
}

applyPatchList () 
{
    start_index=$1
    end_index=$2

    for i in $(printf "%04d " $(seq ${start_index} ${end_index}))  ; do git am $i*patch ; done
}

gitconfig ()
{
    if [ -e /usr/bin/gvim ] ; then
        g ~/.gitconfig
    elif [ -e /usr/bin/vim ] ; then
        v ~/.gitconfig
    else
        echo "you must install vim to see git config file";
    fi
}

gitviewpatchsidebyside () 
{
    local patchfile=$1;
    local origfile=$2;

#     gvim -y "+vert diffpatch ${patchfile} " ${origfile};
    gvim "+vert diffpatch ${patchfile} " ${origfile};
}

gitcatpatchfile ()
{
    local patchfile=$1;

    cat $patchfile | colordiff
}
