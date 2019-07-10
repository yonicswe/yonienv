#!/bin/bash

alias editbashdevel='${v_or_g} ${yonienv}/bashrc_devel.sh'

#   ___  ___   ___ 
#  / __||   \ | _ )
# | (_ || |) || _ \
#  \___||___/ |___/
#                  
setup_gdbinit_dir_search_path () 
{
    local path=$1
	local gdbinit_file_name=$2

	[ -z "${gdbinit_file_name}" ] && gdbinit_file_name=.gdbinit;
    find ${path} -name "*.cpp" -type f -exec dirname {} \; | 
        sort -u | 
            while read d ; do 
                echo "dir $(readlink -f $d) >> ${gdbinit_file_name}"; 
                echo "dir $(readlink -f $d)" >> ${gdbinit_file_name}; 
            done
}

alias debug='cgdb --args '
alias debuglibs='LD_DEBUG=libs '

setup_gdbinit () 
{
    local dir_search_path=${1:-./};
    local executable=${2:-x};
    local bin_dir=${3:-./};
    local gdbinit=${bin_dir}/.gdbinit; 

    echo -n > ${gdbinit}

	setup_gdbinit_dir_search_path ${dir_search_path} ${gdbinit};

# add some more settings to init file.
cat << EOF >> ${gdbinit}

set breakpoint pending on
set print pretty
set print elements 10
set print frame-arguments none


file ${bin_dir}${executable}
set solib-search-path ${bin_dir}

define np
    select-frame \$arg0
    set \$i = (Packet*)(packet.px)->m_packetIndex
    select-frame 0
    printf "\nPacket : %d\n", \$i
end 
document np
np <stack frame number> to print the packet number being processed.
the stack frame of StreamSourceBase::sendPacket()
end

define nn
    c
    np \$arg0
end

define packetBreak
    undisplay
    tbreak DPU.cpp:474
    condition \$bpnum (Packet*)(packet.px)->m_packetIndex == \$arg0
    enaonly \$bpnum
    commands \$bpnum 
        enable
        continue
    end
end
document packetBreak
packetBreak <packet number> will place a conditional breakpoint 
to stop at specified packet.
end

define packetPrint
    print/d (Packet*)(packet.px)->m_packetIndex 
end

define tcp 
    p this->general_element_.HashVal
    x/2s this->m_ClientInfo->IPAddr->GenAddrAsStr.data()
    p this->m_ClientInfo->Port
    x/2s this->m_ServerInfo->IPAddr->GenAddrAsStr.data() 
    p this->m_ServerInfo->Port
end

define ptcp 
    printf "client : %s:%d\n", \$arg0->m_ClientInfo.IPAddr.GenAddrAsStr.c_str(), \$arg0->m_ClientInfo->Port
    printf "server : %s:%d\n", \$arg0->m_ServerInfo.IPAddr.GenAddrAsStr.c_str(), \$arg0->m_ServerInfo->Port
end
document ptcp
ptcp <TCPSession pointer>
will print the 5 tuple of the tcp session argument
end

define xx
    x/40xb \$arg0
end

define sb
    save breakpoints ${TASK_PATH}/.gdb_breakpoints
end    

define lb
    source ${TASK_PATH}/.gdb_breakpoints
end 
document lb
restore breakpoints saved by bsave
end

define ff
    fin
end    

define enaonly
    disable
    enable \$arg0
end
document enaonly
enable only specified breakpoint and disable the rest
end

define disaonly
    enable
    disable \$arg0
end
document disaonly
disable only specified breakpoint and enable the rest
end

define valgrindStart
    target remote | vgdb
end
document valgrindStart
use 'monitor help' to see available function that 
can be sent to valgrind gdb server
end

set prompt (${executable})=> 

source ~/share/ipteam_env/cgdb/stl-views-1.0.3.gdb
source ${TASK_PATH}/.gdb_breakpoints

EOF

} 

gdbbt () 
{
    local exe=$1
    local corefile=$2
    gdb --batch --quiet -ex "thread apply all bt full" -ex "quit" ${exe} ${corefile}
}


alias cdlibmodules='cd /lib/modules/`uname -r`'
listibkerenlmodules ()
{ 
    t 1 /lib/modules/`uname -r`

#     pushd /lib/modules/`uname -r` 1>/dev/null;
#     echo -e "\n====\n"
#     ls | while read f ; do readlink -f $f ; done
#     popd 1>/dev/null;
}


########################################################################
# kernel stuff
########################################################################
# kernel dynamic debug with pr_debug
pr_debug_usage ()
{
    echo "pr_debug [-f <func>] [-d ] [-e] [-h]";
    echo "-f <func> [-d]: enable debug prints in func, -d to remove it";
    echo "-e            : show functions that with enabled pr_debug";
    echo "-h            : print this help";
}

pr_debug () 
{
    local func="";
    local delete=0;
    local show_enabled=0;
    local usage=0;

    OPTIND=0;
    while getopts "f:deh" opt; do
        case $opt in 
        f)
            func=${OPTARG}
            ;;
        d)
            delete=1;
            ;;
        e)
            show_enabled=1;                
            ;;
        h)  
            usage=1;                
            ;;
        esac;
    done;

    if [ ${usage} -eq 1 ] ; then 
        pr_debug_usage;
        return;
    fi

    if [ ${show_enabled} -eq 1 ] ; then 
        sudo cat /sys/kernel/debug/dynamic_debug/control |awk '/.*=pfl/{print $0}';
        return;
    fi; 

    if [ -z "${func}" ] ; then 
        sudo cat /sys/kernel/debug/dynamic_debug/control;
        return;
    fi;

    if [ ${delete} -eq 1 ] ; then 
        su - -c "echo \"func ${func} =_\" > /sys/kernel/debug/dynamic_debug/control";
    else 
        for f in ${func} ; do 
            echo "pr_debug : $f";
            if [ $(id -u) -eq 0 ] ; then 
                echo "func ${f} +pfl" > /sys/kernel/debug/dynamic_debug/control;
            else
                su - -c "echo \"func ${f} +pfl\" > /sys/kernel/debug/dynamic_debug/control";
            fi
        done
    fi;
}

# alias listinstalledkernels='ls -ltr /boot/vmlinuz*'
listinstalledkernels ()
{
    local grub=;
    local libmodules=;
    local f;
    local ff;

    echo " grub1  modules    /boot/..";

    sudo find /boot -type f -and \( -not -name ".*" \) -name "*vmlinuz*" -printf "%T+\t%p\n" | sort | cut -f2 | 
        while read f ; do basename $f ; done | 

#     sudo find /boot -type f -name "vmlinuz*" -printf "%f\n" |
        while read f ; do 
            grub=" ";
            libmodules=" ";
            if [ -e /boot/grub/grub.conf ] ; then 
                if [ $(grep -nH "$f" /boot/grub/grub.conf | wc -l) -gt 0 ] ; then
                    grub="x";
                fi
            fi

#             libmodulesdir=$(sudo strings /boot/$f |grep "EDT\|IST" -m1  | cut -d" " -f1)
            ff=$(echo $f  | grep -v old)
            if [ -n "$ff" ] ; then 
                libmodulesdir=$(sudo strings /boot/$ff |grep "EDT\|IST\|SMP" -m1  | cut -d" " -f1)
                if [ -d /lib/modules/${libmodulesdir} ] ; then
#             if [ -d /lib/modules/$(echo $f | sed 's/vmlinuz-//g') ] ; then
                    libmodules="x";
                fi
            fi

            t=$(stat --printf "%y" /boot/$f|sed 's/\..*//g')                

            if [ -n "$ff" ] ; then 
               echo "  ${grub}   |   ${libmodules}    | $t | $ff";
            fi

        done
}

alias catgrub='cat /boot/grub/grub.conf'
catgrubvsinstalled ()
{
    catgrub | awk '/^kernel/{print $2}' |  sed 's/\///g' |
        while read k ; do 
            if [ -e /boot/$k ] ; then 
                echo "    | /boot/$k";
            else
                echo " x  | /boot/$k";
            fi               
        done
}

catgrubsetdefault ()
{
   local entry=${1};
   [ -z ${entry} ] && return;
   sudo sed -i "s/default.*/default ${entry}/g" /boot/grub/grub.conf
}

editgrub () 
{
    # su - -c " gvim /boot/grub/grub.conf +':split' +':e x' +'r!find /boot -maxdepth 1 -type f -mmin -60'"
    # sudo vim /boot/grub/grub.conf +':split' +':e x' +'r!ls -ltr /boot'   
    # print the last modified file in /boot 
    # sudo find /boot -maxdepth 1   -type f | xargs ls -ltr | tail -n 3
    if [ "${v_or_g}" == "vim" ] ; then
    su - -c "vim /boot/grub/grub.conf +':split' +':e x' +'r!find /boot -maxdepth 1   -type f | xargs ls -ltr | tail -n 3'"
        echo vim
    else
        echo gvim
    su - -c "gvim /boot/grub/grub.conf +':split' +':e x' +'r!find /boot -maxdepth 1   -type f | xargs ls -ltr | tail -n 3'"
    fi

#   sudo - gvim /boot/grub/grub.conf +':split' +':e x' +'r!find /boot -maxdepth 1   -type f | xargs ls -ltr | tail -n 3'

}
# editgrubvim () 
# {
#   su -c " vim /boot/grub/grub.conf +':split' +':e x' +'r!find /boot -maxdepth 1 -type f -mmin -60'"
#     su -c " ${vimorgvim} /boot/grub/grub.conf +':split' +':e x' +'r!find /boot -maxdepth 1   -type f | xargs ls -ltr | tail -n 3'"
# }

alias make="make -j ${ncoresformake}"
alias configure="./configure -j ${ncoresformake}"

grub2listentries () 
{

#     sudo grep "^menuentry" /boot/grub2/grub.cfg | cut -d "'" -f2
#     one way
      if [ -e /etc/grub2-efi.cfg ] ; then 
          sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2-efi.cfg
      elif [ -e /etc/grub2.cfg ] ; then               
          sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
      else          
          sudo grub2-mkconfig 2>/dev/null | sed 's/).*/)/g' |
              awk -v count=0 '/^menuentry/{print count" " $0; count++}'
      fi              

      echo "________________________________";
      sudo grub2-editenv list
      echo "________________________________";
      echo "to change default boot option"
      echo "    sudo grub2-set-default <entry>";
      echo "to see default boot option"
      echo "    sudo grub2-editenv list";
      echo "________________________________";
#     sudo grub2-mkconfig 2>/dev/null | grep --color ^menuentry
#     sudo grub2-mkconfig 2>/dev/null | sed 's/).*/)/g' |
#         awk -v count=0 '/^menuentry/{print count" " $0; count++}'
}

grub2setdefault ()
{
    sudo grub2-set-default $1;
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg;
}

kernelversion ()
{
    awk 'BEGIN{FS = "="} 
        /^VERSION/{ printf $2"-"}
        /^PATCHLEVEL/{printf $2"-"}
        /^SUBLEVEL/{printf $2}
        /^EXTRAVERSION/{printf $2}' Makefile | sed 's/\ //g';
    echo
}

# build only kernel
kernelbuild ()
{
    echo -e "=============================================================";
    echo -e " building only kernel version $(kernelversion)"; 
    echo -e "        make -j ${ncoresformake} vmlinux"
    echo    "=============================================================";
    if [ -e /usr/bin/time ] ; then
        /usr/bin/time -f "================================\n--->elapsed time %E" make -j ${ncoresformake} vmlinux
    else 
        make -j ${ncoresformake} vmlinux
    fi
    echo -e " built kernel version $(kernelversion)"; 
    echo    "=============================================================";
}

# build only modules
kernelbuildmodules () 
{
    echo -e "=========================================================================";
    echo -e " building only modules for kernel version $(kernelversion)"; 
    echo -e "        make -j ${ncoresformake} modules"
    echo    "=========================================================================";
    if [ -e /usr/bin/time ] ; then
        /usr/bin/time -f "=======================================\n--->elapsed time %E" make -j ${ncoresformake} modules     
    else 
        make -j ${ncoresformake} modules     
    fi
    echo -e " built modules for kernel version $(kernelversion)"; 
    echo    "=============================================================";
}

# build kernel and modules.
kernelbuildall ()
{
    echo -e "===============================================================================";
    echo -e " building kernel and modules for kernel version $(kernelversion)"; 
    echo -e "        make -j ${ncoresformake}"
    echo    "===============================================================================";
    make prepare;
    make scripts;
    if [ -e /usr/bin/time ] ; then
        /usr/bin/time -f "===================================\n--->elapsed time %E" make -j ${ncoresformake} 
    else 
        make -j ${ncoresformake} 
    fi
    echo -e          " built kernel and modules for kernel version $(kernelversion)"; 
    echo             "================================================";
}

# install only kernel
kernelinstall ()
{
    echo -e "============================================";
    echo -e "installing kernel+modules $(kernelversion)";
    echo -e "sudo make -j ${ncoresformake} install"
    echo -e "============================================";
    
    sudo make install;

    echo -e "============================================";
    echo -e "installed kernel+modules $(kernelversion)";
    echo -e "============================================";
}

# install only modules.
kernelinstallmodules ()
{
    echo -e "============================================";
    echo -e "installing modules for $(kernelversion)";
    echo -e "sudo make -j ${ncoresformake} modules_install" 
    echo -e "============================================";
    sudo make -j ${ncoresformake} modules_install
    echo -e "============================================";
    echo -e "installed modules for $(kernelversion)";
    echo -e "============================================";
}

# install kernel and modules.
kernelinstallall () 
{ 
    if [ -z "$(redpill)" ] ; then 
        read -p "This is not VM are you sure ? [y/N]" ans;
        if [ "$ans" != "y" ] ; then 
            return;
        fi
    fi            

    echo -e "============================================";
    echo -e "installing kernel+modules for $(kernelversion)";
    echo -e "sudo make -j ${ncoresformake} modules_install" 
    echo -e "sudo make -j ${ncoresformake} install"
    echo -e "============================================";
    sudo make -j ${ncoresformake} modules_install && sudo make install
    echo -e "============================================";
    echo -e "installing kernel+modules for $(kernelversion)";
    echo -e "============================================";
}

# build and install kernel and moduels.
kernelbuildinstallall ()
{
    echo -e "============================================";
    echo -e "sudo make -j ${ncoresformake}"
    echo -e "sudo make -j ${ncoresformake} modules"
    echo -e "sudo make -j ${ncoresformake} modules_install"
    echo -e "sudo make -j ${ncoresformake} install"
    echo "============================================";
    make -j ${ncoresformake} && make -j ${ncoresformake} modules && sudo make -j ${ncoresformake} modules_install && sudo make -j ${ncoresformake} install
}

# build and install only the modules.
kernelbuildinstallmodules ()
{
    echo -e "============================================";
    echo -e "make      -j ${ncoresformake} modules"
    echo -e "sudo make -j ${ncoresformake} modules_install" 
    echo -e "============================================";
    make -j ${ncoresformake} modules && sudo make -j ${ncoresformake} modules_install
}

alias kernelinstallheaders='sudo make headers_install INSTALL_HDR_PATH=/usr'

alias makedebug='make CPPFLAGS="-O0 -g"'

#  ___  _____  ___    _    ___  ___ 
# | __||_   _|| _ \  /_\  / __|| __|
# | _|   | |  |   / / _ \| (__ | _| 
# |_|    |_|  |_|_\/_/ \_\\___||___|
#      
# kernel debugging with ftrace        


ftrace ()
{
    local ans=;
    local func=;
    local pid=;

    # echo 'func' > set_ftrace_filter
    read -p "trace specific func ?  : " func;

    # echo 'pid' > set_ftrace_pid 
    read -p "trace specific pid ?   : " pid;
    read -p "specific trace style [function / function_graph] ? : " trace_style;
    
}

ftraceon ()
{
    local func_name=${1};

    if [ -z "${func_name}" ] ; then
        sudo cat /sys/kernel/debug/tracing/available_filter_functions;
        return;
    fi

    su -c "echo 1 > /sys/kernel/debug/tracing/tracing_on;
           echo ${func_name} > /sys/kernel/debug/tracing/set_ftrace_filter;
           echo function > /sys/kernel/debug/tracing/current_tracer;
           echo 1 > /sys/kernel/debug/tracing/options/func_stack_trace"
}

alias ftracedump="sudo cat /sys/kernel/debug/tracing/trace"

ftraceoff ()
{ 
    su -c "echo 0 > /sys/kernel/debug/tracing/tracing_on;
    echo > /sys/kernel/debug/tracing/set_ftrace_filter;
    echo 0 >  /sys/kernel/debug/tracing/options/func_stack_trace;"
#     echo > /sys/kernel/debug/tracing/current_tracer;
}

infiniband_kernel_module_path=
if [ -d /lib/modules/$(uname -r)/kernel/drivers/infiniband/ ] ; then 
infiniband_kernel_module_path=" /lib/modules/$(uname -r)/kernel/drivers/infiniband/"
fi 
if [ -d /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/mellanox/ ] ; then
infiniband_kernel_module_path+=" /lib/modules/$(uname -r)/kernel/drivers/net/ethernet/mellanox/"
fi
if [ -d /lib/modules/$(uname -r)/extra/ ] ; then
infiniband_kernel_module_path+=" /lib/modules/$(uname -r)/extra/"
fi
if [ -n "${infiniband_kernel_module_path}" ] ; then
complete -W "$(find  ${infiniband_kernel_module_path} -name "*ko" -type f -printf "%f " | sed 's/.ko//g')" rmmod insmod modprobe modinfo
fi

# dmesg -w will print continuously 
alias d='dmesg --color -HxP'
alias dp='dmesg --color -Hx'
alias dw='dmesg --color -Hxw'
alias dcc='sudo dmesg -C'
dyoni ()
{
    echo -n "root ";
    su -c "echo =============yoni-debug============= > /dev/kmsg"
}
# dmesg -w will continuously print to screen (like tail -f)

alias findreject='find -name "*rej"'
alias findorig='find -name "*orig"'
findconflictfiles ()
{
    local delete=

    if [ "$1" == "-d" ] ; then 
        delete="-delete -print";
    fi

    findreject ${delete};
    findorig ${delete};
}

listerrnovalues ()
{
    cpp -dM /usr/include/errno.h | grep define\ E | sort -n -k 3 | awk '{print $2 " "$3}' | column -t;
    cat ${yonienv}/errno_list.txt
}

alias deletepatches='rm -fv *.patch'
alias listpatches='ls -ltr *.patch'
alias deletetags='rm -f cscope.* tags'

killzombies ()
{
    kill $(ps -A -ostat,ppid | awk '/[zZ]/ && !a[$2]++ {print $2}')
}

findkernelsources ()
{
    rpm -q --queryformat="%{SOURCERPM}\n" kernel-`uname -r`
}

extractkernelsrcrpm ()
{
    local kernelfile=$1;
    local ans=;

    read -p "are you on the host that will use this kernel [N/y] ?" ans;
    if [ "${ans}" != "y" ]  ; then 
        echo "you need to be on the same machine"
        return;
    fi
    sudo rpm -ivh --define "_topdir $PWD" ${kernelfile};
    sudo rpmbuild -bp --nodeps --define "_topdir $PWD" SPECS/kernel*.spec
    echo "cd BUILD/${kernelfile}";
}

alias tmuxnewyoni='tmux new -s yoni'
alias tmuxattachyoni='tmux attach -t yoni'
