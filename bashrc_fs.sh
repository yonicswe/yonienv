#!/bin/bash

alias editbashfs='${v_or_g} ${yonienv}/bashrc_fs.sh'

#  ___                         _   
# | _ \ _ _  ___  _ __   _ __ | |_ 
# |  _/| '_|/ _ \| '  \ | '_ \|  _|
# |_|  |_|  \___/|_|_|_|| .__/ \__|
#                       |_|        
#                                     
# 
#   ___       _               
#  / __| ___ | | ___  _ _  ___
# | (__ / _ \| |/ _ \| '_|(_-<
#  \___|\___/|_|\___/|_|  /__/
#
#   colors
#===================
# Black       0;30     Dark Gray     1;30
# Blue        0;34     Light Blue    1;34
# Green       0;32     Light Green   1;32
# Cyan        0;36     Light Cyan    1;36
# Red         0;31     Light Red     1;31
# Purple      0;35     Light Purple  1;35
# Brown       0;33     Yellow        1;33
# Light Gray  0;37     White         1;37
# 
#                color struct explained
# ─────────────────────────────────────────────────────────────────────────────
#     format         forground     background
#     0 - normal      30 black       40 black
#     1 - bold        31 red         41 red
#     2 - underline   32 green       42 green
#                     33 yellow      43 yellow
#                     34 blue        44 blue
#                     35 purple      45 purple
#                     36 cyan        46 cyan
#                     37 white       47 white
# ─────────────────────────────────────────────────────────────────────────────
#    
#  color structue
#  forground ; format ; background   
#    
#    
#    
#    
#  \e[1;4;31m
#    
#  
#  ┌─────────────┬───┬───────────────────┬───┬────────────────┬───┬───┬─────────────┬───┐
#  │\e           │ [ │ 1                 │ ; │ 4              │ ; │ 31│ m           │   │
#  ├─────────────┼───┼───────────────────┼───┼────────────────┼───┼───┼─────────────┼───┤
#  │start color  │   │ 0 - normal        │   │ 4 - underline  │   │   │ end color   │   │
#  │sequence     │   │ 1 - bold          │   │                │   │   │ sequence    │   │
#  │             │   │ 2 - underline     │   │                │   │   │             │   │
#  │             │   │                   │   │                │   │   │             │   │
#  │             │   │                   │   │                │   │   │             │   │
#  │             │   │                   │   │                │   │   │             │   │
#  │             │   │                   │   │                │   │   │             │   │
#  │             │   │                   │   │                │   │   │             │   │
#  └─────────────┴───┴───────────────────┴───┴────────────────┴───┴───┴─────────────┴───┘
#  
#  
# 

# 
# command prompt colors
# 
# export PS1="\[\033[1;31m\](\u) \[\033[1;36m\]\h:\[\033[0m\]/\W=> "

parse_git_branch() 
{
    if [ -d .git ] ; then 
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/';
    fi;
}

parse_svn_branch() {
  parse_svn_url | sed -e 's#^'"$(parse_svn_repository_root)"'##g' | awk -F / '{print "(svn::"$1 "/" $2 ")"}'
}
parse_svn_url() {
  svn info 2>/dev/null | grep -e '^URL*' | sed -e 's#^URL: *\(.*\)#\1#g '
}
parse_svn_repository_root() {
  svn info 2>/dev/null | grep -e '^Repository Root:*' | sed -e 's#^Repository Root: *\(.*\)#\1\/#g '
}


export COLORED_PROMPT=false;
prompt_color () 
{
    if [ $COLORED_PROMPT == "true" ] ; then 
        export COLORED_PROMPT=false
        # export PS1="(\u) \h:\!=> " 
        export PS1="(\u) \h:/\W=> " 
    else
        export COLORED_PROMPT=true
        # export PS1="\[\033[1;31m\](\u) \[\033[1;32m\]\h:\!=> \[\033[0m\] "
        export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\]=> "
        # export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\] \[\033[01;34m\]\$(parse_git_branch)\$(parse_svn_branch)\[\033[00m\]$\[\033[00m\]=> "
    fi

    if [ "${CS_PROMPT}" == "true" ] ; then 
        export CS_PROMPT=false;
        prompt_sc > /dev/null;
    else
        export CS_PROMPT=true;
        prompt_sc > /dev/null;
    fi
} 

alias psc='prompt_sc'
prompt_sc () 
{
    local _CS_PROMPT=

    if ! [ -d .git ] ; then
        echo "this is not a git directory. Exiting..."
        export CS_PROMPT=false;
        export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\]=> "
        return;
    fi

    export CS_PROMPT=true;
#   export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\] \[\033[01;34m\]\$(parse_git_branch)\$(parse_svn_branch)\[\033[00m\]$\[\033[00m\]=> "
    export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\] \[\033[01;34m\]\$(parse_git_branch)\[\033[00m\]$\[\033[00m\]=> "

#     if [ -e .prompt_sc ] ; then
#         _CS_PROMPT=$(cat .prompt_sc)
#         [ ${_CS_PROMPT} == true ] && CS_PROMPT=false;
#         [ ${_CS_PROMPT} == false ] && CS_PROMPT=true;
#     fi
#      
#     
#     if [ ${CS_PROMPT} == true ] ; then 
#         export CS_PROMPT=false;
#         export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\]=> "
#     else
#         export CS_PROMPT=true;
#         export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\] \[\033[01;34m\]\$(parse_git_branch)\$(parse_svn_branch)\[\033[00m\]$\[\033[00m\]=> "
#     fi
#     echo ${CS_PROMPT} > .prompt_sc
}

prompt_color

# colors for ls command
eval $(dircolors ${yonienv}/dir_colors)



refresh_ssh ()
{
	local line_number=$1;
	[ -z "${line_number}" ] && return;
	vim ~/.ssh/known_hosts +${line_number} +d +x;
} 

#
# jobs
#
alias j='jobs -l'
alias f='fg'
alias b='bg'
k () {
    job=$1 ; 
    kill_str="kill -9 %${job}" ; 
    eval ${kill_str} ; 
}


alias l='ls --group-directories-first -l --color -F'
alias lt='ls --group-directories-first -lt --color -F'
alias ltr='ls --group-directories-first -ltr --color -F'

alias c='cd'
alias ..='cd ../ ; pwd -P'
alias p='pwd -P'
pp ()
{
    echo $(hostname -i):$(pwd -P)/$1
}
alias mv='mv -v'
alias rm='rm -iv'
alias rmd='rm -rf'
alias cp='cp -iv'
alias po='popd 1>/dev/null ; pd ; pd_complete'
alias dirs='dirs -l -v'
alias j='jobs -l'
alias f='fg'
alias b='bg'
# alias grepc='grep -nH --include=*.c --include=*.h --include=*.cpp --include=*.hpp'
alias grepc='ag --cc --noheading'
# alias greptxt='grep -nrH --color --include=*.txt'
# alias greptxt='ag -t '
alias greptxt='ag -G .*\.txt'
alias grepascii='grep -nH -r -I --color '
alias grepmake='grep -nH -r -I --color --include=*[m,M]ake*'
# grepascii ()
# {
#     grepme="$1";
#     [ -z ${grepme} ] && return;
#     find . -type f -exec grep -Iq . {} \; -print
# }

alias ag='ag --noheading'
alias ssh='ssh -X -o ConnectTimeout=3'
alias pstree='pstree -Uphacl'

# list only directories 
lld ()
{
   ls -ltrd --color $(ls -l | awk '/^d/{print $9}')
}

# list hidden files
la ()
{
    verbose=0

    oper=$1
    case $oper in 
    "-l")
        new_path=$2
        verbose=1
        ;; 
    *)
        new_path=$1
        ;;
    esac

    if [ -n "${new_path}" ] ; then 
        cd ${new_path}
    fi

    if  (( $verbose == 1 )) ; then 
        ls --color -ld $(ls -Atr  | awk '/^\./{print $0}' ) 
    else
        ls -Atr  | awk '/^\./{print $0}' | xargs
    fi        

    if [ -n "${new_path}" ] ; then 
      cd -  1>/dev/null
    fi         
}

# show disk layout
dfa () 
{ 
    /bin/df -ThP|column -t
# 	param=$1		
# 	/bin/df $param -ThP | 
# 		while read x1 x2 x3 x4 x5 x6 x7 x8 ; do  
# 			printf "%-30s %-8s %-8s %-8s %-8s %-8s %-8s %-8s\n" $x1 $x2 $x3 $x4 $x5 $x6 $x7 $x8;
# 		done 
}

# sort files and directories by size
du1 ()
{
	local path=$1
	du -h --max-depth=1 $path | sort -h 
}

du11 ()
{
    du -sch $(find . -maxdepth 1 | grep -vP ".snapshot|^.$")|grep -P "M\s|G\s"
}

duroot ()
{
    local path=${1:-/};
    sudo du -h -x --max-depth=1 --exclude="/proc" --exclude="/misc" --exclude="/dev" ${path} | sort -h
}

t () 
{
    local opts=""
    local dir=""        

#     if [ $(rpm -q tree | wc -l ) -eq 0 ] ; then 
#         echo "install tree : sudo yum install tree";
#         return;
#     fi

    if [ $# -gt 0 ]  ; then
        if [[ $1 =~ [[:alpha:]] ]] ; then 
            dir="$*"
        else 
            opts="-L $1"    
            shift            
            dir="$*"
        fi
    fi

    tree --charset UTF-8 -CF $opts $dir 
}

# cat which 
cw () 
{
    file=${1};
    [ -z ${file} ] && return
    cat $(which ${file});
}

# gvim which
vw () 
{
    file=${1};
    [ -z ${file} ] && return
    ${v_or_g} $(which ${file});
}

# rpm which 
rw () 
{
    file=${1};
    [ -z ${file} ] && return
    rpm -qf $(which ${file});
}

#  _     _      _                   
# | |_  (_) ___| |_  ___  _ _  _  _ 
# | ' \ | |(_-<|  _|/ _ \| '_|| || |
# |_||_||_|/__/ \__|\___/|_|   \_, |
#                              |__/ 
# history file mode - append                              
shopt -s histappend

export HISTTIMEFORMAT="%D %T "

h () 
{ 
    local a=$1;

    if [ -z $a ] ; then 
        history 
    else 
        history | /bin/grep --color -i $a 
    fi
}

# get a directory name as parameter 
# then create it and move all files ( not folders )
# to it.
mv2dir ()
{
   local all=0;
   local ans=;
   local source_items=; 
   local target_exist=0;

   local pars=$*

#    if [ "$1" == "-a" ] ; then 
# move hidden files as well..
#          source_items="$(ls -A| xargs)" 
#          target_folder=$2            
   if [ $# -eq 2 ] ; then 
         source_items=( $(find . -maxdepth 1 -type f -name "*${1}*" -printf "%f ") )
         target_folder=$2
   else
         source_items="$(find . -maxdepth 1 -type f -printf "%f\n" | xargs)"
         target_folder=$1            
   fi      

   # abort if the target dir already exist         
   if [ -d ${target_folder} ] ; then 
       read -p "${target_folder} exists!! continue [y/N]" ans
       if [ "$ans" != "y" ] ; then 
           return;
       else 
           target_exist=1;
       fi
   fi

   # create the target directory 
   if (( ${target_exist} == 0 )) ; then 
       echo "mkdir ${target_folder}";
       mkdir ${target_folder};
   fi

   # do the move
   mv -v ${source_items[@]} ${target_folder}
}

# rename a file name comprised with space 
# by replacing space with underscore
space_2_underscore ()
{
    fileName="$1";

    if [ -z "${filename}" ] ; then
        for i  in * ; do 
            newFileName=$(echo "$i" | sed 's/\ /_/g')
            mv -i -v "$i" $newFileName 
        done
    else
        newFileName=$(echo "$fileName" | sed 's/\ /_/g')
        mv -i -v "$fileName" $newFileName 
    fi;
} 

rpmsearch () 
{
	case=$1
	if ! [ $case == "-i" ] ; then 
		case=""
	fi

	rpm -qa | grep $case "$@"
}


pgrep () 
{
    verbose=no;
    while [ "$1" ] ; do 
        case $1 in
            -l) 
                verbose=yes
                print_ip_and_exit=true
                shift
                ;;
            *)
                proc_name=$1
                shift
                ;; 
        esac
    done

    if [ "$verbose" == yes ] ; then 
        ps -eo pid,comm |grep -i ${proc_name}; 
    else 
		#  print just the process name 
        ps -eo pid,comm |grep -i ${proc_name} | awk '{print $1}';
    fi

	unset proc_name		

}

psmine ()
{
    ps aux  |grep ^${USER}
}

# export GREP_OPTIONS="--color --binary-files=without-match -D skip"
alias grepfiles='grep -nH --color --binary-files=without-match -D skip'

dirdiff () 
{
    local dir1=$1
    local dir2=$2
    declare -a files1;
    declare -a files2;

    local ans;

#   diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print "vimdiff "$2" "$4}'    
    diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print $2" "$4}'| 
        while read r1 r2 ; do 
            echo $r1 differ $r2;
            files1=( $(echo ${files1[@]} $r1) );
            files2=( $(echo ${files2[@]} $r2) );

#             read -p " [y/N]" ans;
#               if  [ "$ans" == "y" ] ; then
#                  echo diff $r1 $r2;
#                   # ${_vd} $r1 $r2 < /dev/tty;
#                   # ${_vd} $r1 $r2;
#               fi
        done

            echo files1 ${files1[@]};
            echo files2 ${files2[@]};
}

# dirgvimdiff () 
# {
#     dir1=$1
#     dir2=$2
# #   diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print "vimdiff "$2" "$4}'    
#     diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print $2" "$4}'| 
#         while read r1 r2 ; do 
#             gvimdiff $r1 $r2 
#             gvimdiff $r1 $r2 < /dev/tty
#         done
# }

dirdiffbrief () 
{
    dir1=$1
    dir2=$2
#   diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print "vimdiff "$2" "$4}'    
    diff -qrup ${dir1} ${dir2} -x \*svn\*
}

alias tt='probe_topology'
alias probe_topology_root='echo -n "root " ; su - -c "probe_topology"'
probe_topology () 
{
    declare -a core;
    declare -a shadow_core;
    declare -a socket;
    declare -a ordered_socket;
    declare -a ordered_core;
    local processor_model="";
#     local processor_model_str_len;
    local processor_properties="";
    local dmi_decode="";
    local i;
    local core_0_shadow;
    local cpu_cores;
    local siblings;
    local memory;
    local hyper_thread_enabled=;

    core=( $(cat /proc/cpuinfo | awk '/processor/{print $3}') );
    socket=( $(cat /proc/cpuinfo | awk '/physical id/{print $4}') ); 

    ordered_socket=( $(for (( i=0 ; i < ${#socket[*]} ; i++ )) ; do echo "${socket[$i]} ${core[$i]}" ; done |sort -u | awk '{print $1}' ) );
    ordered_core=( $(for (( i=0 ; i < ${#socket[*]} ; i++ )) ; do echo "${socket[$i]} ${core[$i]}" ; done |sort -u | awk '{print $2}' ) );

    # check hyper-threading
    core_0_shadow=$(cat /sys/devices/system/cpu/cpu0/topology/thread_siblings_list)
    if [ ${core_0_shadow} != ${core[0]} ] ; then 
        core_0_shadow="enabled";
        # hyper threading is enabled
        for (( i=0 ; i < ${#core[*]} ; i++ )) ; do 
            shadow_core[$i]="$(cat /sys/devices/system/cpu/cpu${i}/topology/thread_siblings_list)"
        done
    fi        

    processor_model=$(cat /proc/cpuinfo | awk '/model name/{print $0}' | head -n1);
    cpu_cores=$(cat /proc/cpuinfo | grep "cpu cores" |sort -u)
    siblings=$(cat /proc/cpuinfo | grep "siblings" |sort -u)
    processor_model+=" (${cpu_cores}, ${siblings})"
    processor_model+=$(echo ; lscpu | grep -i "thread");
    hyper_thread_enabled=$(lscpu |awk '/Thread/{split($0,a,":") ;gsub(" ","",a[2]);print a[2] }')
    if (( ${hyper_thread_enabled} > 1 )) ; then 
        processor_model+=" ( Hyper Thread Enabled )"
    else
        processor_model+=" ( NO !! Hyper Thread )"        
    fi        
#     processor_model_str_len=$(expr length "${processor_model}");

    print_underline "${processor_model}" "="

#     if [ $(id -u) -eq 0 ] ; then 
        processor_properties=$(sudo dmidecode --type 4 | 
            awk '/Core Count/{cc++ ; if (cc <= 1) print $0} 
                 /Core Enabled/{ce++ ; if (ce <= 1) print $0} 
                 /Thread Count/{tc++ ; if (tc <= 1) print $0}')
        dmi_decode="from dmidecode :\n$processor_properties";
        d1="$(sudo dmidecode -s   system-manufacturer | tail -1 )"
        d2="$(sudo dmidecode -s   system-product-name | tail -1 )"
        echo -n "Chassis :${d1}, ${d2}"
        
#     else
#         echo "!!!! invoke as root to get more info !!!!"
#     fi

#   memory=$(cat /proc/meminfo |grep MemTotal);
    memory="Total Memory : $(free -m | awk '/Mem/{print $2}') MegaBytes";

    echo -e "\n${processor_model}";
    if ! [ -z "${dmi_decode}" ] ; then 
        echo -e "${dmi_decode}"
    fi
    echo -e "${memory}";
    print_underline "${processor_model}" "="

#   head -c ${processor_model_str_len} < /dev/zero | tr '\0' '='
    
    printf "\t\t\t\tOrdered by socket\n"
    
    number_of_sockets=${#socket[*]}
    printed_cores_per_line=$(( ($number_of_sockets / 16) + (($number_of_sockets % 16)>0) ));

    for (( j=0 ; j < ${printed_cores_per_line} ; j++)) ; do 

        (( start_index= $j*16 )) ;

        if (( ${start_index} + 16 < ${number_of_sockets} )) ; then 
            ((end_index = $start_index + 16));
        else
            end_index=${number_of_sockets};
        fi

        printf "\n%-8s|" socket

        for (( i=start_index ; i < end_index; i++ )) ; do 
            printf "%-3d|" ${ordered_socket[$i]};
        done

        printf "\n%-8s|" core 

        for (( i=start_index ; i < end_index; i++ )) ; do 
            printf "%-3d|" ${ordered_core[$i]};
        done

        echo

    done

    echo

    print_underline "${processor_model}" "="
    printf "\t\t\t\tOrdered by core";
#     head -c ${processor_model_str_len} < /dev/zero | tr '\0' '='
     
    number_of_sockets=${#socket[*]}
    printed_cores_per_line=$(( ($number_of_sockets / 16) + (($number_of_sockets % 16)>0) ));

    for (( j=0 ; j < ${printed_cores_per_line} ; j++)) ; do 

        (( start_index= $j*16 )) ;

        if (( ${start_index} + 16 < ${number_of_sockets} )) ; then 
            ((end_index = $start_index + 16));
        else
            end_index=${number_of_sockets};
        fi

#       printf "\n%-8s (%d:%d)" socket $start_index $end_index
        printf "\n%-8s|" socket

        for (( i=start_index ; i < end_index ; i++ )) ; do 
            printf "%-5d|" ${socket[$i]};
        done

        printf "\n%-8s|" core

        for (( i=start_index ; i < end_index ; i++ )) ; do 
            printf "%-5d|" ${core[$i]};
        done

        if [ ${core_0_shadow} == "enabled" ] ; then 
            printf "\n%-8s|" shadow
            for (( i=start_index ; i < end_index ; i++ )) ; do 
                printf "%-5s|" ${shadow_core[$i]};
            done 
        fi

        echo

    done

    print_underline "${processor_model}" "=";

    echo
}

alias freeh='free -h'

myip ()
{
    hostname -I  | awk '{print $2}'
#   ip r  g 1 | awk '{if (FNR==1) {print $3} }'
}

myip_v1 ()
{
    hostnameflags="-I";
    hostname -I 2>/dev/null;
    [ $? -ne 0 ] && hostnameflags="-i";

#   if [ -z $(echo $(hostname ${hostnameflags} | awk '{print $1}') ) ] ; then 
    if [ -z $(echo $(hostname ${hostnameflags})) ] ; then 
        echo $(hostname "${hostnameflags}");
    else
#       echo $(hostname "${hostnameflags}" | awk '{print $1}');
        echo $(hostname "${hostnameflags}");
    fi
}

mydistro ()
{
    hostnamectl | grep  -i "operating system" | sed 's/.*:\ /OS: /g';
    hostnamectl | grep  -i "kernel" | sed 's/.*:\ /Kernel:\ /g';
    hostnamectl | grep  -i "chassis" | sed 's/.*:\ /Chassis:\ /g';
}

mydistro_v1 ()
{
# this code comes from 
# https://unix.stackexchange.com/questions/6345/how-can-i-get-distribution-name-and-version-number-in-a-simple-shell-script
    if [ -f /etc/redhat-release ] ; then
        OS=$(cat /etc/redhat-release)
    elif [ -f /etc/os-release ] ; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
#   elif [ -f /etc/SuSe-release ]; then
#       # Older SuSE/etc.
#       ...
#   elif [ -f /etc/redhat-release ]; then
#       # Older Red Hat, CentOS, etc.
#       ...
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi

    echo $OS $VER
    echo kernel : `uname -r`
}


ethlist ()
{
    ip -4  -o a show |awk '{print $2" "$4}' | column -t | grep -v lo
}

alias Ethlistroot='echo -n "root " ; su - -c "ethlist"'
Ethlist () 
{    
    local link="???";
    local show_link=1;
    local speed="???";
    local up_down="down"
    local promisc;
    local mtu;
    local ip_addr;

    if [ $(id -u) -ne 0 ] ; then 
		echo " !!! RUN AS ROOT TO GET LINK/SPEED STATUS !!!"	
        show_link=0; 
	fi

    # print header
    printf "%-10s  %-5s  %-5s  %-10s  %-10s  %-10s %-20s %s\n" "Interface" "stat" "Link" "Promisc" "Speed" "MTU" "IP Addr" "HW Addr"; 

    # for e in $(ifconfig -a | awk '/eth|wlan/{print $1}') ; do 
    for e in $(netstat -i | awk '/eth|wlan|eno/{print $1}') ; do 

        up_down=$( [ $(ifconfig $e | grep UP | wc -l ) -gt 0 ] && echo up || echo down ); 
        promisc=$( [ $(ifconfig $e | grep -i promisc | wc -l ) -gt 0 ] && echo promisc || echo no-promisc ); 

        mtu=$( ifconfig $e | awk '/MTU/{print $0}' | sed 's/\(.*\)\(MTU:.*\ \)\(.*\)/\2/g');
        if [ -z "${mtu}" ] ; then 
            mtu=$( ifconfig $e | awk '/mtu/{print $0}'| sed 's/\(.*\)mtu\(.*\)/\2/g')
        fi
#       ip_addr=$( ifconfig $e | awk '/inet addr/{print $0}' | sed 's/\(.*:\)\(.*\ \).*/\2/g');
#         if [ -z "${ip_addr}" ] ; then 
#             ip_addr=$( ifconfig $e | awk '/inet\ /{print $2}');
#         fi
        ip_addr=$( ifconfig $e | awk '/inet\ /{print $2}');

        if [ ${show_link} -eq 1 ] ; then 
            link=$(ethtool $e | awk '/Link detected/{print $3}') ; 
            speed=$(ethtool $e | grep Speed | awk '{print $2}') ;
        fi;

        mac=$(ifconfig $e | awk '/ether\ /{print $2}' );

        printf "%-10s  %-5s  %-5s  %-10s  %-10s  %-10s %-20s %s\n" $e "${up_down}" "${link}"  ${promisc} "${speed}" ${mtu} ${ip_addr} "${mac}"; 
    done
}
export -f Ethlist

delete_executables ()
{ 
#     local executable_file_list;
#     executable_file_list=$(find . -maxdepth 1 -exec file {} \; |\grep "ELF.*executable"|awk '{print $1}'|sed 's/:$//')
    find . -maxdepth 1 -exec file {} \; |\grep "ELF.*executable"|awk '{print $1}'|sed 's/:$//' | while read i ; do 
#         for i in ${executable_file_list} ; do
            echo "rm -f $i";
        rm -f $i;
    done
}

findexecutable ()
{
    find -executable | while read f ; do if [ $(file $f | grep ELF.*executable | wc -l ) -ne 0 ] ; then echo $f ; fi ; done
}

define() { 
    curl -s "http://www.collinsdictionary.com/dictionary/english/$*" | sed -n '/class="def"/p' | awk '{gsub(/.*<span class="def">|<\/span>.*/,"");print}' | sed "s/<[^>]\+>//g"; 
}

extractrpm ()
{
    if [ -n $1 ] ; then
        echo "rpm2cpio $1 | cpio -idvm";
        rpm2cpio $1 | cpio -idm;
    fi
}

extract () {

    if [ -f "$1" ] ; then 
        case $1 in

            *.tar.bz2)  tar xvjf -- "$1"    ;; 
            *.tar.gz)   tar xvzf -- "$1"    ;; 
            *.bz2)      bunzip2 -- "$1"     ;; 
            *.rar)      unrar x -- "$1"     ;; 
            *.gz)       gunzip -- "$1"      ;; 
            *.tar)      tar xvf  "$1"     ;; 
            *.tbz2)     tar xvjf -- "$1"    ;; 
            *.tgz)      tar xvzf -- "$1"    ;; 
            *.zip)      unzip -- "$1"       ;; 
            *.Z)        uncompress -- "$1"  ;; 
            *.7z)       7z x -- "$1"        ;;
            *.xz)       xz -d -- "$1"        ;;
            *)          echo "don't know how to extract '$1'..." ;;

        esac

    else 
        echo "'$1' is not a valid file" 
    fi

}

# find out if I am VM or a real machine.
redpill () 
{
    local ret=0;

    ################################################# 
    # try dmidecode
    which dmidecode 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        echo "vendor : $(sudo dmidecode -s system-manufacturer)";
        echo "product: $(sudo dmidecode -s system-product-name)";

        if [ $( sudo dmidecode | grep -i product | grep -i "qemu\|kvm" | wc -l ) -gt 0 ] ; then 
            echo "I am a virtual machine (dmidecode)";
            return 0;
        fi
        echo "I am a hypervisor (dmidecode)";
        return 1;
    fi

    ################################################# 
    # try virt-what
    which virt-what 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        if [ $( sudo virt-what |  wc -l ) -gt 0 ] ; then 
            echo "I am a virtual machine (virt-what)";
            return 0;
        fi;
        echo "I am a hypervisor (virt-what)";
        return 1;
    fi;


    ################################################# 
    #  try lshw
    which lshw 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        sudo lshw -class system -sanitize | grep -i product
        if [ $( sudo lshw -class system -sanitize | grep -i product | grep -i kvm | wc -l ) -gt 0 ] ; then 
            echo "I am a virtual machine (lshw)";
            return 0;
        fi;
        echo "I am a hypervisor (lshw)";
        return 1;
    fi

    ################################################# 
    # try systemd-detect-virt
#     which systemd-detect-virt 2>/dev/null;
#     ret=$?;
#     if [ ${ret} -eq 0 ] ; then
#         if [ $( systemd-detect-virt | grep -i none | wc -l ) -gt 0 ] ; then
#             echo "I am a hypervisor (systemd-detect-virt)";
#             return 1;
#         fi
#         echo "I am a virtual-machine (systemd-detect-virt)";
#         return 0;
#     fi

    ################################################# 
    # try hostnamectl
    which hostnamectl 2>/dev/null;
    ret=$?;
    if [ ${ret} -eq 0 ] ; then
        if [ $( hostnamectl | grep -i virt | wc -l ) -gt 0 ] ; then
            echo "I am a virtual-machine (hostnamectl)";
            return 0;
        fi
        echo "I am a hypervisor (hostnamectl)";
        return 1;
    fi

    if [ $( cat /proc/cpuinfo | grep --color -i hypervisor | wc -l ) -gt 0 ] ; then 
        echo -e "i might be am a virtual machine NO \"hypervisor\" in /proc/cpuinfo"; 
        return 0;
    fi 

    echo "i am a hypervisor (/proc/cpuinfo)";
    return 1;

# using dmesg is not safe as it can be deleted
#     if [ $(dmesg | grep --color -i hypervisor | wc -l ) -gt 0 ] ; then 
#         echo "i am a virtual machine (dmesg)";
#     else
#         echo "i am a hypervisor (dmesg)";
#     fi 

}

ff () 
{ 
    if [ $# -eq 2 ] ; then 
        find $1 -name "*$2*" -type f; 
    else 
        find . -name "*$1*" -type f; 
    fi
}

ffi () 
{ 
    if [ $# -eq 2 ] ; then 
        find ${1} -iname "*$2*" -type f; 
    else 
        find . -iname "*$1*" -type f; 
    fi
}

ffd () 
{ 
    if [ $# -eq 2 ] ; then 
        find $1 -name "*$2*" -type d; 
    else 
        find . -name "*$1*" -type d; 
    fi
}

ffdi () 
{ 
    if [ $# -eq 2 ] ; then 
        find ${1} -iname "*$2*" -type d; 
    else 
        find . -iname "*$1*" -type d; 
    fi
}

findmin ()
{
    local min=${1:--5};

    find -type f -mmin ${min} -ls;
}

vncwatcherslist () 
{
    lsof -Pni |awk '{if (NR == 1) print $0 }'  
    lsof -Pni | grep Xvnc | grep -v LISTEN   
    echo
    netstat -tupa | grep 5901 2>/dev/null
    echo "vncconfig -disconnet"
}

# virtual machine manager : virsh
vm ()
{
    if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi
    virt-manager
}

virsh_complete ()
{
#     if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi
    complete -W "$(sudo virsh list --inactive | awk '{if (NR > 1 ) print $2}')" vstart vrename
    complete -W "$(sudo virsh list | awk '{if (NR > 1) print $2}')" vconsole vreset vstop vforcestop
}

vl ()
{
#     if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi

    echo -e "----------------------------------------------------"
    sudo virsh list --all
    echo -e "----------------------------------------------------"
    echo -e "[vstart] [vconsole] [vreset] [vstop] [vforcest]\n"
    virsh_complete
}

vstart ()
{
    if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi

   sudo virsh start $1
   virsh_complete
}

vstop ()
{
    if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi

    sudo virsh shutdown $1;
    virsh_complete;
}

vforcestop ()
{
    if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi

    sudo virsh destroy $1;
    virsh_complete;
}

vreset ()
{
    if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi

    sudo virsh reset $1;
    virsh_complete;
}

vconsole ()
{
    if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi

    sudo virsh console $1;
    virsh_complete;
}

vrename ()
{
    local old_name=$1;
    local new_name=$2;
    local ans;

    if [ $(id -u) -ne 0 ] ; then echo "must be root" ; return ; fi

    if [ $# -eq 1 ] ; then
        virsh dumpxml ${old_name} > $old_name.xml;

        # TODO: replace with sed or xmlstarlet
        # instead of vim
        ${v_or_g} ${old_name}.xml 

        read -p "continue [y/N]" ans;
        if [ "$ans" == "y" ] ; then
            virsh undefine ${old_name};
            virsh define ${old_name}.xml;
        fi
    else
        echo "vrename <old name> <new name>";
    fi

    virsh_complete
}


alias isnfsMountPoint='stat -f -L -c %T' 

forcereboot () 
{
    local ans=;
    local hypervisor=1;

    redpill;
    hypervisor=$?;

    read -p "about to reboot. Are you sure ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        if [ ${hypervisor} -eq 1 ] ; then 
            read -p "This is an hypervisor. Are you absolutely sure ? [y/N]" ans;
            if [ "$ans" == "y" ] ; then 
                su -c "echo b > /proc/sysrq-trigger";
            fi
        else
            su -c "echo b > /proc/sysrq-trigger";
        fi
    fi
}

shutdown () 
{
    local ans=;
    local hypervisor=1;

    redpill;
    hypervisor=$?;

    read -p "about to shutdown. Are you sure ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        if [ ${hypervisor} -eq 1 ] ; then 
            read -p "This is an hypervisor. Are you absolutely sure ? [y/N]" ans;
            if [ "$ans" == "y" ] ; then 
                sudo shutdown -h now;
            fi
        else
            sudo shutdown -h now;
        fi
    fi 
}

reboot ()
{
    local ans=;
    local hypervisor=1;

    redpill;
    hypervisor=$?;

    read -p "about to reboot. Are you sure ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then 
        if [ ${hypervisor} -eq 1 ] ; then 
            read -p "This is an hypervisor. Are you absolutely sure ? [y/N]" ans;
            if [ "$ans" == "y" ] ; then 
                sudo /sbin/reboot;
            fi
        else
            sudo /sbin/reboot;
        fi
    fi 
}

showosrelease ()
{
    if [ -e /etc/os-release ] ; then 
        cat /etc/os-release;
        return;
    fi

    find /etc -maxdepth 1 -name "*release*" | while read r ; do 
            echo "----------------------------------------"
            echo "|  $r"
            echo "----------------------------------------"
            cat $r;
        done
}

pgrepa () 
{
    local process_name=$1;
    local i=;

    if [ -n $1 ] ; then 
        for i in $(pgrep  $process_name) ; do 
            ps h $i;
        done
    fi
}

freecachedmem ()
{
    sync; echo 1 > /proc/sys/vm/drop_caches
}

create_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};
    user_name=${3:-yonic}
    echo -e "alias ${alias_name}=\"sshpass -p ${yonipass} ssh -YX ${user_name}@${host_name}\""
    alias ${alias_name}="sshpass -p ${yonipass} ssh -YX ${user_name}@${host_name}"
    alias ${alias_name}root="sshpass -p 3tango ssh -YX root@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

m ()
{
#   myip;
    ethlist;
    mydistro;
#     ofedversion;
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
