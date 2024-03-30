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

alias gitconfig="vim ~/.gitconfig";
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

# gitcheckoutbranchfromtag ()
# {
    # local tag=$1;
    # new_branch_name=$2;

    # git checkout -b ${new_branch_name} tags/${tag};
# }

gitrebaseremotebranch ()
{
    ask_user_default_no "git fetch before we start ? ";
    if [ $? -eq 1 ] ; then
        git fetch origin;
    fi;

    branch="$(git br | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

    if [ -z "${branch}" ] ; then
        return;
    fi;

    branch=$(echo ${branch} | sed 's/origin\///g');

    echo -e "\t${BLUE}git fetch origin ${GREEN}${branch}${NC}";
    echo -e "\t${BLUE}git rebase ${GREEN}FETCH_HEAD${NC}";
    ask_user_default_no  "continue ?";
    if [ $? -eq 0 ] ; then
        return;
    fi;

    echo "git fetch origin ${branch};";
    git fetch origin ${branch};
    echo "git rebase FETCH_HEAD;";
    git rebase FETCH_HEAD;
}

gitcheckoutbranch ()
{
    branch="$(git b | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

    if [ -n "${branch}" ] ; then
        echo "git checkout branch : ${branch}";
        git checkout ${branch};
    fi;
}

gitcheckoutremotebranch ()
{
    local remote_branch=;
    local local_branch=;

    ask_user_default_no "git fetch before we start ? ";
    if [ $? -eq 1 ] ; then
        git fetch -p;
    fi;

    remote_branch="$(git b -r |sed 's/.*origin\///g'| fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

    if [[ -z ${remote_branch} ]] ; then
        echo "you must specify a valid branch";
        return -1;
    fi;

    echo "remote branch : ${remote_branch}";

    ask_user_default_no "rename the branch ? ";
    if [ $? -eq 1 ] ; then
        read -p "new name : " local_branch;
    else
        local_branch=${remote_branch};
    fi;

    for b in $(git b |grep -v HEAD ) ; do
        if [[ ${b} == "${local_branch}" ]] ; then 
            echo "${local_branch} already checked out !! remove it and try again";
            echo "doing return";
            return -1;
        fi;
    done;

    echo -e  "\t${GREEN}git fetch origin ${YELLOW}${remote_branch}${NC}";
    echo -e  "\t${GREEN}git checkout -b ${YELLOW}${local_branch}${GREEN} FETCH_HEAD${NC}";

    ask_user_default_no "continue";
    if [ $? -eq 0 ] ; then return -1; fi;

    git fetch origin ${remote_branch};
    git checkout -b ${local_branch} FETCH_HEAD;

    echo "would you like to set ${local_branch} to track upstream ${remote_branch}";
    ask_user_default_yes;
    if [ $? -eq 1 ] ; then
        git branch --set-upstream-to=origin/${remote_branch};
    fi;

    return 0;
}

#git-deletebranch ()
#{
    #branch="$(git b | fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')"

    #if [ -n "${branch}" ] ; then
        #ask_user_default_no "git branch -D ${branch} ";
        #if [ $? -eq 1 ] ; then
            #git checkout ${branch};
        #fi;
    #fi;
#}

git-deletemultiplebranches ()
{
    local branch_filter=${1};
    local branch_list=();
    local branches=();
    local delete_branches=();

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
}

git-deletebranch ()
{
    local branch=;

    if [[ -z ${branch} ]] ; then
        branch="$(git b |sed 's/.*origin\///g'| fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    fi;

    if [[ -z ${branch} ]] ; then
        echo "you must specify a valid branch";
        return -1;
    fi;

    echo "git branch -D ${branch}";
    ask_user_default_no "are you sure ? ";
    if [[ $? -eq 1 ]] ; then
        git branch -D ${branch};
    fi;
}

git-deleteremotebranch ()
{
    local branch=;

    if [[ -z ${branch} ]] ; then
        branch="$(git b -r |sed 's/.*origin\///g'| fzf -0 -1 --border=rounded --height='20' | awk -F: '{print $1}')";
    fi;

    if [[ -z ${branch} ]] ; then
        echo "you must specify a valid branch";
        return -1;
    fi;

    echo "git push -d origin ${branch}";
    ask_user_default_no "are you sure ? ";
    if [[ $? -eq 1 ]] ; then
        git push -d origin ${branch};

        if [[ 1 == $(git b |grep ${branch} | wc -l ) ]] ; then
            ask_user_default_yes "also delete local branch ?";
            if [[ $? -eq 1 ]] ; then
                git bdelete ${branch};
            fi;
        fi;

        ask_user_default_no "git fetch -p ? ";
        if [[ $? -eq 1 ]] ; then
            git fetch -p;
        fi;
    fi;

    return 0;
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


gitsmtop ()
{
    cd $(git rev-parse --show-superproject-working-tree);
}

gitsmstatus ()
{ 
    git sm status | awk '{if (NF > 2) {print $2 " " $3} }' | column -t; 
}

gitsmlist ()
{
    local b=;

   \ls .git/modules/source/ |while read s ; do
       b=$(cat .git/modules/source/$s/HEAD);
       b=$(echo $b | awk '/^ref/{print $2}');
       if [ -z ${b} ] ; then
           echo -n $(cat .git/modules/source/$s/HEAD) ;
           echo " $s";
       else  
           echo -n $(cat .git/modules/source/$s/$b);
           echo -e " $s (${GREEN}$b${NC})";
       fi;
   done
}

alias git-describe-branches='for line in $(git branch); do
     description=$(git config branch.$line.description)
     if [ -n "$description" ]; then
       echo "$line     $description"
     fi
done'

alias git-describe-branches-2='git branch | while read line; do
     description=$(git config branch.$(echo "$line" | sed "s/\* //g").description)
     echo "$line     $description"

done'
# howtos and trouble shooting
# delete .git/index.lock 
#   - when this happens "another git process seems to be running in this repository
