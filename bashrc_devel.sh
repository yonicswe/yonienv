#!/bin/bash

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

# build only kernel
alias mkkernelbuild='make -j ${ncoresformake}'

# build only modules
alias mkkernelbuildmodules='make -j ${ncoresformake} modules' 

# build kernel and modules.
mkkernelbuildall ()
{
    echo -e "============================================";
    echo -e "make -j ${ncoresformake}"
    echo -e "make -j ${ncoresformake} modules"
    echo "============================================";
    make -j ${ncoresformake} && make -j ${ncoresformake} modules
}

#==============================================================
#  _  __                      _ 
# | |/ / ___  _ _  _ _   ___ | |
# | ' < / -_)| '_|| ' \ / -_)| |
# |_|\_\\___||_|  |_||_|\___||_|
#==============================================================                               
                              
# install only kernel
alias mkkernelinstall='sudo make install'

# install only modules.
alias mkkernelinstallmodules='sudo make -j ${ncoresformake} modules_install'

# install kernel and modules.
mkkernelinstallall () 
{ 
    echo -e "============================================";
    echo -e "sudo make -j ${ncoresformake} modules_install" 
    echo -e "sudo make -j ${ncoresformake} install"
    echo -e "============================================";
    sudo make -j ${ncoresformake} modules_install && sudo make install
}


# build and install kernel and moduels.
mkkernelbuildinstallall ()
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
mkkernelbuildinstallmodules ()
{
    echo -e "============================================";
    echo -e "make      -j ${ncoresformake} modules"
    echo -e "sudo make -j ${ncoresformake} modules_install" 
    echo -e "============================================";
    make -j ${ncoresformake} modules && sudo make -j ${ncoresformake} modules_install
}

alias mkkernelheadersinstall='sudo make headers_install INSTALL_HDR_PATH=/usr'
