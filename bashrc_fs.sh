#!/bin/bash

alias editbashfs='g ${yonienv}/bashrc_fs.sh'

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
# command prompt colors
# 
# export PS1="\[\033[1;31m\](\u) \[\033[1;36m\]\h:\[\033[0m\]/\W=> "

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(git::\1)/'
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
} 

export CS_PROMPT=false;
prompt_sc () 
{
    if [ ${CS_PROMPT} == true ] ; then 
        export CS_PROMPT=false;
        export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\]=> "
    else
        export CS_PROMPT=true;
        export PS1="\[\033[1;31m\]\u\[\033[1;37m\]@\[\033[1;35m\]\h:\[\033[1;33m\]/\W\[\033[0m\] \[\033[01;34m\]\$(parse_git_branch)\$(parse_svn_branch)\[\033[00m\]$\[\033[00m\]=> "
    fi
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


alias l='ls --group-directories-first -ltr --color -F'
alias c='cd'
alias ..='cd ../ ; pwd -P'
alias p='pwd -P'
alias mv='mv -v'
alias rm='rm -iv'
alias cp='cp -iv'
alias po='popd 1>/dev/null ; pd ; pd_complete'
alias dirs='dirs -l -v'
alias j='jobs -l'
alias f='fg'
alias b='bg'
# alias grepc='grep -nH --include=*.c --include=*.h --include=*.cpp --include=*.hpp'
alias grepc='ag --cc --noheading'
alias greptxt='grep -nrH --color --include=*.txt'
alias ag='ag --noheading'
alias ssh='ssh -X'
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

    if [ $(rpm -q tree | wc -l ) -eq 0 ] ; then 
        echo "install tree : sudo yum install tree";
        return;
    fi

    if [ $# -gt 0 ]  ; then
        if [[ $1 =~ [[:alpha:]] ]] ; then 
            dir="$*"
        else 
            opts="-L $1"    
            shift            
            dir="$*"
        fi
    fi

    tree -ACF $opts $dir 
}

# cat which 
cw () 
{
    file=${1};
    [ -z ${file} ] && return
    cat $(which ${file});
}

# gvim which
gw () 
{
    file=${1};
    [ -z ${file} ] && return
    gvim $(which ${file});
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
        history | grep -i $a 
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
    fileName="$1"

    newFileName=$(echo "$fileName" | sed 's/\ /_/g')
    mv -i -v "$fileName" $newFileName 
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

dirvimdiff () 
{
    dir1=$1
    dir2=$2
#   diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print "vimdiff "$2" "$4}'    
    diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print $2" "$4}'| 
        while read r1 r2 ; do 
            vimdiff $r1 $r2 < /dev/tty
        done
}

dirgvimdiff () 
{
    dir1=$1
    dir2=$2
#   diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print "vimdiff "$2" "$4}'    
    diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print $2" "$4}'| 
        while read r1 r2 ; do 
            gvimdiff $r1 $r2 
            gvimdiff $r1 $r2 < /dev/tty
        done
}

dirdiffbrief () 
{
    dir1=$1
    dir2=$2
#   diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ | awk '{print "vimdiff "$2" "$4}'    
    diff -qrup ${dir1} ${dir2} -x \*svn\* |grep differ
}

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

    if [ $(id -u) -eq 0 ] ; then 
        processor_properties=$(sudo dmidecode --type 4 | 
            awk '/Core Count/{cc++ ; if (cc <= 1) print $0} 
                 /Core Enabled/{ce++ ; if (ce <= 1) print $0} 
                 /Thread Count/{tc++ ; if (tc <= 1) print $0}')
        dmi_decode="from dmidecode :\n$processor_properties";
        d1="$(sudo dmidecode -s   system-manufacturer | tail -1 )"
        d2="$(sudo dmidecode -s   system-product-name | tail -1 )"
        echo -n "Chassis :${d1}, ${d2}"
        
    else
        echo "!!!! invoke as root to get more info !!!!"
    fi

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

myip ()
{
   if [ -z $(echo $(hostname -i | awk '{print $2}') ) ] ; then 
       echo $(hostname -i)
   else
       echo $(hostname -i | awk '{print $2}')
   fi
}

alias ethlistroot='echo -n "root " ; su - -c "ethlist"'
ethlist () 
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
    printf "%-10s  %-5s  %-5s  %-10s  %-10s  %-10s %s\n" "Interface" "stat" "Link" "Promisc" "Speed" "MTU" "IP Addr"; 

    # for e in $(ifconfig -a | awk '/eth|wlan/{print $1}') ; do 
    for e in $(netstat -i | awk '/eth|wlan|eno/{print $1}') ; do 

        up_down=$( [ $(ifconfig $e | grep UP | wc -l ) -gt 0 ] && echo up || echo down ); 
        promisc=$( [ $(ifconfig $e | grep -i promisc | wc -l ) -gt 0 ] && echo promisc || echo no-promisc ); 

        mtu=$( ifconfig $e | awk '/MTU/{print $0}' | sed 's/\(.*\)\(MTU:.*\ \)\(.*\)/\2/g');
        if [ -z "${mtu}" ] ; then 
            mtu=$( ifconfig $e | awk '/mtu/{print $0}'| sed 's/\(.*\)mtu\(.*\)/\2/g')
        fi
#       ip_addr=$( ifconfig $e | awk '/inet addr/{print $0}' | sed 's/\(.*:\)\(.*\ \).*/\2/g');
        ip_addr=$( ifconfig $e | awk '/inet\ /{print $2}');
        if [ -z "${ip_addr}" ] ; then 
            ip_addr=$( ifconfig $e | awk '/inet\ /{print $2}');
        fi

        if [ ${show_link} -eq 1 ] ; then 
            link=$(ethtool $e | awk '/Link detected/{print $3}') ; 
            speed=$(ethtool $e | grep Speed | awk '{print $2}') ;
        fi                        

        printf "%-10s  %-5s  %-5s  %-10s  %-10s  %-10s %s\n" $e "${up_down}" "${link}"  ${promisc} "${speed}" ${mtu} ${ip_addr}; 
    done
}
export -f ethlist

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

extract () {

    if [ -f "$1" ] ; then 
        case $1 in

            *.tar.bz2)  tar xvjf -- "$1"    ;; 
            *.tar.gz)   tar xvzf -- "$1"    ;; 
            *.bz2)      bunzip2 -- "$1"     ;; 
            *.rar)      unrar x -- "$1"     ;; 
            *.gz)       gunzip -- "$1"      ;; 
            *.tar)      tar xvf -- "$1"     ;; 
            *.tbz2)     tar xvjf -- "$1"    ;; 
            *.tgz)      tar xvzf -- "$1"    ;; 
            *.zip)      unzip -- "$1"       ;; 
            *.Z)        uncompress -- "$1"  ;; 
            *.7z)       7z x -- "$1"        ;;
            *)          echo "don't know how to extract '$1'..." ;;

        esac

    else 
        echo "'$1' is not a valid file" 
    fi

}

# find out if I am VM or a real machine.
redpill () 
{
#     if [ $(dmesg | grep --color -i hypervisor | wc -l ) -gt 0 ] ; then 
#         echo "i am a virtual machine (dmesg)";
#     else
#         echo "i am a hypervisor (dmesg)";
#     fi 

    if [ $( cat /proc/cpuinfo | grep --color -i hypervisor | wc -l ) -gt 0 ] ; then 
        echo "i am a virtual machine";
        return 0;
    else
        echo "i am a hypervisor";
        return 1;
    fi 
#     if [ $(which virt-what | grep "no virt-what" | wc -l ) -eq  0 ] ; then
#         su -c "virt-what"
#     fi
       
#     if [ $(which dmidecode | grep "no dmidecode" | wc -l ) -eq  0 ] ; then
#         su -c "dmidecode -s system-manufacturer"
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

    find -mmin ${min} -ls;
}

vncwatcherslist () 
{
    lsof -Pni |awk '{if (NR == 1) print $0 }'  
    lsof -Pni | grep Xvnc | grep -v LISTEN   
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
    complete -W "$(sudo virsh list --inactive | awk '{if (NR > 1 ) print $2}')" vstart
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
                sudo reboot;
            fi
        else
            sudo reboot;
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
