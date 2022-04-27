#!/bin/bash

alias editbashgit='${v_or_g} ${yonienv}/bashrc_git.sh'

# alias gitdiff="git difftool --tool=${v_or_g} --no-prompt"
alias gitdiff='git d'
alias gitdiffkdiff3='git difftool --tool=kdiff3 --no-prompt'
alias gitdiffstat='git --no-pager diff --stat'
alias gitlog='git log --name-status'
gl ()
{
    n=${1:-1000};
    git log --decorate --date=short --pretty=format:"%C(green)%cd - %C(red)%h%Creset - %C(auto)%d%C(reset) %s %C(bold blue)<%an>%Creset" -$n;
}

# alias gitmkhook='gitdir=$(git rev-parse --git-dir); scp -p -P 29418 yonatanc@l-gerrit.mtl.labs.mlnx:hooks/commit-msg ${gitdir}/hooks/'
gitd ()
{
    local diff_this_file=${1};

    local -a modified_file_list;
    modified_file_list=( $(git status -s | awk '/\ M/{print $2}') );

    if [ -n "${diff_this_file}" ] ; then 
        git dv ${diff_this_file};
    else
        git status -uno;
    fi;

    complete -W "$(echo ${modified_file_list[@]})" gitd gitdiff;

}
# alias gitdiscardunstaged='git checkout -- .'
alias gitstashunstaged='git stash --keep-index'
alias gitunstageall='git reset HEAD'

gituncommit ()
{
    git log -1 --pretty=format:'%H' > .reuse_commit.txt;
    echo "saved index ($(cat .reuse_commit.txt)) in .reuse_commit.txt";
    git reset --soft HEAD^
}

gitb () 
{
    local branch="$1"
#     git b | awk '/^\*/{print "\033[32m-->["$2"]\033[0m"} !/^\*/{print "    "$1}'
    if [ -z ${branch} ] ; then   
        git b | sed 's/^\*\ /-->\ /g' | awk '/-->/{print "\033[31m" $1 " " $2  "\033[0m"} !/-->/{print "    "$1}' | sort -dV
    else
        git b | sed 's/^\*\ /-->\ /g' | awk '/-->/{print "\033[31m" $1 " " $2  "\033[0m"} !/-->/{print "    "$1}' | grep "${branch}" | sort -dV
    fi

    complete -W "$(git branch)" gitb
}

alias gitwhichbranch="git  s  | awk '/On branch/{print $4}'"

gitdiscardcached () 
{ 
    local -a discardlist;
    local file_to_discard=${1};

    if [ -n "${file_to_discard}" ] ; then  
        echo "git checkout ${file_to_discard}";
        git checkout ${file_to_discard};
        return;
    fi

    discardlist=( $(git diff --name-only --cached) );
    if [ ${#discardlist[@]} -gt 0 ] ; then 
        complete -W "$(echo ${discardlist[@]})" gitdiscardcached;
        _gitdiscard  "${discardlist[@]}"
    fi
}

gitdiscardmodified () 
{
    local -a discardlist;
    local file_to_discard=${1};

    if [ -n "${file_to_discard}" ] ; then  
        echo "git checkout ${file_to_discard}";
        git checkout ${file_to_discard};
        return;
    fi

    discardlist=( $(git ls-files -m) ); 
    if [ ${#discardlist[@]} -gt 0 ] ; then 
        complete -W "$(echo ${discardlist[@]})" gitdiscardmodified gitd;
        _gitdiscard  "${discardlist[@]}"
    fi

}

_gitdiscard () 
{
    local ans;
    local -a discardlist=( $(echo "${@}") );


#   local file_to_discard=${1}; 
#   discardlist=( $(git status -uno -s | awk '{print $2}') );
#   discardlist=( $(git ls-files -m) );


#   echo "${#discardlist[@]} :${discardlist[@]}"

#   if [ -n "${file_to_discard}" ] ; then  
#       echo "git checkout ${file_to_discard}";
#       git checkout ${file_to_discard};
#       return;
#   fi

    if [ ${#discardlist[@]} -gt 0 ] ; then 
        complete -W "$(echo ${discardlist[@]})" gitdiscardmodified gitdiscardcached;
        echo "about to discard "
        for i in ${discardlist[@]} ; do 
            echo -e "\t$i";
        done;

        read -p "Are you sure [y/N]" ans;
        if [ "$ans" == "y" ] ; then
#           git status -uno -s | awk '{system("git checkout " $2)}';
            echo ${discardlist[@]} | awk '{ print "git checkout "$0; system("git checkout " $0)}';
        fi
    fi
}

gitapplyPatchList () 
{
    start_index=$1
    end_index=$2
    patch_path=${3:-.}

#     for i in $(printf "%04d " $(seq ${start_index} ${end_index}))  ; do git am $i*patch ; done
    for i in $(printf "%04d " $(seq ${start_index} ${end_index}))  ; do 
        echo -e "\033[1;31mgit am --reject $( ls ${patch_path}/$i*patch )\033[0m";
        git am --reject $( ls ${patch_path}/$i*patch ) ;
    done
#     for i in $(printf "%04d " $(seq ${start_index} ${end_index}))  ; do echo "git am $( ls ${patch_path}/$i*patch)" ; done
}

alias gitconfig="nv ~/.gitconfig";
# {
#     if [ -e /usr/bin/gvim ] ; then
#         g ~/.gitconfig
#     elif [ -e /usr/bin/vim ] ; then
#         v ~/.gitconfig
#     else
#         echo "you must install vim to see git config file";
#     fi
# }


gitviewpatchsidebyside () 
{
    local patchfile=$1;
    local origfile=$2;

#     gvim -y "+vert diffpatch ${patchfile} " ${origfile};
    ${v_or_g} "+vert diffpatch ${patchfile} " ${origfile};
}

gitcatpatchfile ()
{
    local patchfile=$1;

    cat $patchfile | colordiff
}

gitcommityoni ()
{
    local module=${1};
    if [ -n "${module}" ] ; then 
        sed -i "s/^module/${module}/g" ${yonienv}/git_templates/git_commit_template_yonic;
    fi

    git config commit.template ${yonienv}/git_templates/git_commit_template_yonic; 
    git commit;
    git config --unset commit.template;
    git checkout ${yonienv}/git_templates/git_commit_template_yonic;
}

gitcommitmlx ()
{
    local issue=${1};
    if [ -n "${issue}" ] ; then 
        sed -i "s/Issue:.*/Issue: ${issue}/g" ${yonienv}/git_templates/git_commit_mlx_template;
    fi

    git config commit.template ${yonienv}/git_templates/git_commit_mlx_template;
    git commit;
    git config --unset commit.template;
}

gitcommitmetadata ()
{
    local issue=${1};
    if [ -n "${issue}" ] ; then 
        sed -i "s/Issue:.*/Issue: ${issue}/g" ${yonienv}/git_templates/git_commit_metadata_template;
    fi
    git config commit.template ${yonienv}/git_templates/git_commit_metadata_template;
    git commit;
    git config --unset commit.template;
}

gitcheckouttag ()
{
    local tag=$1;
    new_branch_name=$2;

    git checkout -b ${new_branch_name} tags/${tag};
}

gitcommitfixup ()
{
    local index=$1;
    git commit -m "fixup: ${index}"
}

alias gitconfignopasswd='git config --global credential.helper cache'

gitshowfilefromindex ()
{
    sha=${1};
    file=${2};

    if [ $# -ne 2 ] ; then 
        echo "gitshowfilefromindex <sha> <file>";
        return -1;
    fi

    if ! [ -e "${file}" ] ; then
        echo -e "file : \"${file}\" not found";
        return -1;
    fi    

    git show --stat ${sha} 2>/dev/null > /dev/null;
    if (( $? !=  0 )) ; then 
        echo -e "index : ${sha} does not exist";
        return -1;
    fi

    git show ${sha}:${file} | gvim - +:"set ft=c"
}

gitclearcache ()
{
    ask_user_default_no "are you sure "
    if [ $? -eq 0 ] ; then 
        return -1;
    fi;

    echo "rm -rf .git/rr-cache"
    rm -rf .git/rr-cache
}
