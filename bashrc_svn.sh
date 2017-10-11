#!/bin/bash

#   ___ __   __ _  _ 
#  / __|\ \ / /| \| |
#  \__ \ \ V / | .` |
#  |___/  \_/  |_|\_|
#

export SVN_EDITOR=vim
# alias svl='svn ls'
alias svi='svn info'

# TODO : consider building the 'complete' list with svn list -R 
repo_url="snt.nice.com"
repo_list=" ${repo_url}NiceTrackMC/RnD/MonitoringCenter/MC5/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Versions/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/6.0/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/6.0/NiceTrackI/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/yonic"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/branches/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/common/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/common/utils/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Customers/"
repo_list+=" ${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/trunk/ICM/"
# svn_commands="add blame cat changelist checkout cleanup commit copy delete diff export help import info list ls lock log"
# svn_commands=$svn_commands" merge mergeinfo mkdir move propdel propedit propget proplist propset"
# svn_commands=$svn_commands" resolve resolved revert status switch unlock update"

repo_acs_list=" ${repo_url}/ACSRepo/ACS"

# complete -W '$repo_list' svl 
branches_root_url="${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/branches"


svn_reachable () 
{

    local ret=0;
#     return 1;
#   ping ${repo_url} -c 1 -w 1 > /dev/null
#  	svn ls svn://${repo_url}/NiceTrackMC > /dev/null
    nc -z -w 1 ${repo_url} 3690
	ret=$?
	if [ $ret -ne 0 ] ; then 
        return 1
    else       
        return 0;
    fi        
}

get_branches () 
{
    rm -f ~/svn_error.log

    svn_reachable;
    r=$?  ;
    if [ $r -ne  0 ] ; then 
        return;
    fi

    local -a b=( $(svn list -R --depth=immediates svn://${branches_root_url}| 
                    while read p ; do 
                        echo ${branches_root_url}/${p}; 
                    done) )
    echo ${b[*]};
}

# branches_url="${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/6.0 $(get_branches)"

svn_complete () 
{
    export branches_url="${repo_url}/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/6.0 $(get_branches)"
    complete -W '${branches_url} ${repo_list} ${repo_acs_list}' task_setup.sh svl svnmergebranch svnco
}

# svn_complete 

svl () 
{   
    local url=${1};
    svn_complete

    if [ -z ${url} ] ; then 
        svn ls 
    else                    
        svn ls svn://${1}
    fi                
}

svnco () 
{   
    local url=${1};
    shift
    local depth=$*;
    
    if ! [ -z ${url} ] ; then 
        echo "svn co svn://${url} ${depth}"
        svn co svn://${url} ${depth}
    fi                
}

path2URL () 
{
    path=$1
	svninfo=$(svn info . | grep URL)
    url=$(echo ${svninfo} |awk '{print $2}')
	echo ${url}
}


svnsw () 
{
    local rev=${1};
    local url;

    # get the URL 
    url=$(path2URL .)@${rev};
    echo "switching to ${url}";
    svn sw ${url};
}

svnstatu () {
    all=$1

    if [ "$all" == "all" ] ; then 
        svn status -u 
    else
        svn status -u | grep -v "^?" 
    fi
}

svnstat () {
    all=$1

    if [ "$all" == "all" ] ; then 
        svn status  
    else
        svn status  | grep -v "^?" 
    fi
}

svnrevert () {
    what=$1
    now=$(date +"%d%b%Y_%H%M%S")

    read -p "save a copy before reveret [y]" answer
    echo 
    if [ "${answer}" == "y"  -o -z "${answer}" ] ; then 
        echo "saving ${what}.${now}"
        if [  $(file ${what} | grep directory | wc -l) -gt 0 ] ; then 
            cp -a ${what} ${what}.${now}
        else
            cp ${what} ${what}.${now}
        fi
    fi
    
    svn revert ${what}
}

svncat () 
{
    f=$1
    rev=$2
    [ -z "$f" ] && return
    [ -n "${rev}" ] && rev=@$rev

    ff=$(svn info $f|grep URL|sed 's/.*\ //g')
    svn cat ${ff}${rev}
}


svnresolved () { 
    where=$1
    read -t 2 -p "recursive ?[r]" user_choice
    if [ "${user_choice}" == "r" -o -z "${user_choice}" ] ; then 
        echo "svn -R resolved ${where}"
        svn -R resolved ${where}
    else
        echo "svn resolved ${where}"
        svn resolved ${where}
    fi
}

alias svnkdiff3='svn diff --diff-cmd kdiff3caller.sh'
alias svngvimdiff='svn diff --diff-cmd gvimdiff-svn-wrapper -x -upbBw'
alias svnvimdiff='svn diff --diff-cmd vimdiff-svn-wrapper -x -upbBw'
svndiff () 
{
	local save_file=no; 
	local path="";	
    local new_name="";
    local answer="";
    local save_file_name="";
    local url=;

	while [ "$1" ] ; do 
		case $1 in
			-n) 
				save_file=yes;
				shift
				;; 
			*)
				path=$1 
				shift
				;; 
		esac
	done

    now=$(date +"%d%b%Y_%H%M%S")

    if [ -z "${path}" ] ; then 
        path=$(pwd)
    fi

	if ! [ -e $(readlink -f ${path}) ] ; then 
		echo "path does not exist";
		return;			
	fi			

	url=$(path2URL ${path})
#   save_file_name=$(echo ${url}| sed -e 's|'${repo_url}'||g' -e 's|\/|_|g')_LocalChanges${now}.patch
    save_file_name=patch_LocalChanges_${now}.diff
    echo "svn diff --diff-cmd=/usr/bin/diff -x -upbBw ${path}"
    svn diff --diff-cmd=/usr/bin/diff -x -upbBw ${path} | tee ${save_file_name}


    # file size less than 10 bytes means something wrong
    if [ $(stat -c%s ${save_file_name}) -lt 10 ] ; then 
        echo "No diffs found"
        \rm -f ${save_file_name} 1>/dev/null
        return
    fi

    echo

	if [ ${save_file} == "no"  ] ; then
        rm -f ${save_file_name};
		return;
	fi

    sed -i "1i# ${url}" ${save_file_name};


    read -p "change patch name ${save_file_name} [n]: " new_name
    if ! [ -z "$new_name" ] ; then 
        mv ${save_file_name} patch_${new_name}_${now}.diff
    fi

}

svndiffbrief () 
{
	local save_file=no; 
	local path="";	
    local new_name="";
    local answer="";
    local save_file_name="";
    local url=;

	while [ "$1" ] ; do 
		case $1 in
			-n) 
				save_file=yes;
				shift
				;; 
			*)
				path=$1 
				shift
				;; 
		esac
	done
    
    if [ -z "${path}" ] ; then 
        path=$(pwd)
    fi

	if ! [ -e $(readlink -f ${path}) ] ; then 
		echo "path does not exist";
		return;			
	fi			

    now=$(date +"%d%b%Y_%H%M%S")

	url=$(path2URL ${path})
    save_file_name=LocalChangesFileList_${now}.txt
#     save_file_name=$(echo ${url}| sed -e 's|'${repo_url}'||g' -e 's|\/|_|g')__localChangeidFiles${now}.patch

    svn diff --diff-cmd=/usr/bin/diff -x -upbBw -x --brief ${path}|grep Index|sed 's/Index:\ //g' | tee ${save_file_name} 

    # file size less than 10 bytes means something wrong
    if [ $(stat -c%s ${save_file_name}) -lt 10 ] ; then 
        echo "No diffs found"
        \rm -f ${save_file_name}
        return
    fi

    echo

	if [ ${save_file} == "no"  ] ; then
        rm -f ${save_file_name};
		return;
	fi

    sed -i "1i# ${url}" ${save_file_name};

    read -p "change patch name ${save_file_name} [n]: " new_name
    if ! [ -z "$new_name" ] ; then 
        mv ${save_file_name} ${new_name}
    fi

}

svndiffhead () 
{
    svn diff -r HEAD
}


svnlogforfile () 
{
    filename=$1
    f=$(path2URL $filename) 

    a=($(svn log -q ${f} | awk '/^r.*/{print $1}' |sed 's/r//' |xargs))
    changes=${#a[*]}

    ((max = $changes-1 ))
    echo "$filename was changed ${changes} times. between revs: ${a[*]}"
    echo "============================================================="
    for (( i=0 ; i<$max ; i++)) ; do 
        rev1=${a[$i]}
        ((i2 = $i + 1))
        rev2=${a[$i2]}
        # svndiffr $filename $rev1 $rev2 
        #echo "diffing -r${rev2}:${rev1} ${filename}"
	    svn diff --diff-cmd=/usr/bin/diff -x -upbBw -r${rev2}:${rev1} ${filename} 
    done
}

svnup () 
{
    path=$1
    if [ -z "${path}" ] ; then 
        path=$(pwd)
    fi
    now=$(date +"%d%b%Y_%H%M%S")
    x=$(basename ${path})
    xx=$(basename $(dirname ${path}))
    save_file=${xx}_${x}_LocalChanges.${now}
    2>&1 svn up ${path} | grep -e "^A\ \|^D\ \|^U\ \|^C\ \|^G\ " | tee ${save_file}

    conflicts=$(grep ^C.* ${save_file} | wc -l )
    if [ $conflicts -ne 0 ] ; then 
        echo "$conflicts conflicts found!!!!"
    fi

    if [ $(file ${save_file} | grep -i empty | wc -l ) -gt 0 ] ; then 
        rm -f ${save_file}
        return
    fi

    echo
    read -p "save results in ${save_file} [n]: " answer
    if [ "$answer" != "y" ] ; then 
        rm -f ${save_file}
    fi
}

svnupbranch ()
{
    local base_url=$(svn info |grep Repo.*Root| sed 's/.*svn/svn/g');
#   local base_url="svn://snt.nice.com/NiceTrackMC"
    local trunk_url=$(svn log -v -r0:HEAD --limit 1 --stop-on-copy |grep \(from | sed 's,\(.*from\)\(.*\)\(:.*\),\2,g' | sed 's/\ //g');
    local url=${base_url}${trunk_url};
#   local url="${base_url}$(svn log -v --stop-on-copy . |tail -10 |grep from | sed 's,\(.*from\)\(.*\)\(:.*\),\2,g' | sed 's/\ //g')"    
    local answer="";
    local dry_run="--dry-run";

    read -p "update branch from ${url} ? [y/N] : " answer;
    if [ "$answer" != "y" ] ; then 
       return; 
    fi

    answer="";
    read -p "dry run ? [Y/n] : " answer;
    if [ "$answer" = "n" ] ; then 
        dry_run="";
    fi
    echo "svn merge ${dry_run} ${url}" | tee svnupbranch_comment.txt; 

    svn merge ${dry_run} ${url} | tee --append svnupbranch_comment.txt; 
}

svnmergebranch () 
{
    local url=svn://${1};
    local answer="";
    local dry_run="--dry-run"; 

    read -p "merge to trunk from :  ${url} ? [y/N] : " answer;
    if [ "$answer" != "y" ] ; then 
       return; 
    fi

    answer="";
    read -p "dry run ? [Y/n] : " answer;
    if [ "$answer" = "n" ] ; then 
        dry_run="";
    fi
    echo "svn merge --reintegrate ${dry_run} ${url}"; 
    svn merge --reintegrate ${dry_run} ${url} | tee svnmerge_comment.txt; 
}
                  
svnlog () {

	url=$1;
    user=$2;

	[ -z "$url" ] && url=.

	svn ls $url > /dev/null
	ret=$?
	[ $ret -ne 0 ] && return

    if [ -z ${user} ] ; then 
        svn log -v --stop-on-copy $url | less;
    else
        svn log | sed -n "/${user}/,/-----$/ p" | less;
    fi
}

logu () 
{
	curr_url=$(svi |grep URL |sed 's/.*\ //')	
	log ${curr_url}
}

logq () 
{
    f=$1
	svn log -q ${f}
}

svndiffr () 
{
   local path=$1;
   local prev_rev=$2;
   local next_rev=$3;
   local save_file="";

    if [ -z "${path}" -o -z "${prev_rev}" -o -z "${next_rev}" ] ; then 
        echo "usage(): svndiffr <url path> <revision number> <revision number>"
        return
    fi 

    now=$(date +"%d%b%Y_%H%M%S")

    ff=diffRevs_${prev_rev}_${next_rev}

	url=$(path2URL ${path})
# 	save_file=${ff}-$(echo ${url}| sed -e 's|'${repo_list}'||g' -e 's|\/|_|g').patch
 	save_file=patch_${ff}.diff
   
   svn diff --diff-cmd=/usr/bin/diff -x -upbBw -r${prev_rev}:${next_rev} ${path} | tee ${save_file}

   # file size less than 10 bytes means something wrong
   if [ $(stat -c%s ${save_file}) -lt 10 ] ; then 
        echo "No diffs found"
        rm -f ${save_file}
        return
   fi

   sed -i "1i# ${url}" ${save_file};
   read -p "save results in ${save_file} [n]: " answer

   if [ "$answer" != "y" ] ; then 
        rm -f ${save_file}
   fi
}


tag_ls () {
	module_name=$1
	if [ -z $module_name ] ; then 
		module_name=$(svn info |grep URL | sed 's/.*\/repos\///' | sed 's/\/.*$//')
	fi
	if [ -n $module_name ] ; then 
		echo -e "${module_name} tags :\n====================="
		svn ls $repo/${module_name}/tags/ |awk ' BEGIN {FS="-" } {print $3"/"$2"/"$1" "$0} ' |sort -m
	fi
}


branches () {
	module_name=$1
	if [ -z $module_name ] ; then 
		module_name=$(svn info |grep URL | sed 's/.*\/repos\///' | sed 's/\/.*$//')
	fi
	if [ -n $module_name ] ; then 
		echo -e "${module_name} branches :\n====================="
		svn ls $repo/${module_name}/branches/
	fi
} 

svnchangeuser () 
{
    local user=${1};

    [ -z ${user} ] && return 1;

    svn up --non-interactive --username=${user} --password=${user}

    return 0;
}
