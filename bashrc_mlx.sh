#!/bin/bash

########################################################################
# mellanox stuff
########################################################################

if ! [ -e ~/.bashmlx_once.$(hostname -s) ] ; then
    export PATH=${PATH}:/.autodirect/mswg/release/MLNX_OFED/
    touch ~/.bashmlx_once.$(hostname -s); 
fi

alias editbashmlx='${v_or_g} ${yonienv}/bashrc_mlx.sh'
alias chownyoni='sudo chown yonatanc:mtl'
export yonipass="yonatanc11"
create_alias_for_host ()
{
    alias_name=${1}
    host_name=${2};

    alias ${alias_name}="sshpass -p ${yonipass} ssh -YX yonatanc@${host_name}"
    alias ${alias_name}root="sshpass -p 3tango ssh -YX root@${host_name}"
    alias ${alias_name}ping="ping ${host_name}"
}

# vnc hosts
create_alias_for_host 1 r-ole01
create_alias_for_host 2 r-ole02
create_alias_for_host 8 r-ole08
create_alias_for_host 9 r-ole08
create_alias_for_host 10 r-ole08
create_alias_for_host 11 r-ole08
create_alias_for_host 15 r-ole15
create_alias_for_host 70 dev-r-vrt-070

# my development hosts
create_alias_for_host 145 dev-l-vrt-145
create_alias_for_host 1455 dev-l-vrt-145-005
# dev-l-vrt-145-006
create_alias_for_host 1456 10.134.145.6 
create_alias_for_host 1457 dev-l-vrt-145-007
create_alias_for_host 1458 dev-l-vrt-145-008
create_alias_for_host 1459 dev-l-vrt-145-009

# dev-l-vrt-146
create_alias_for_host 146 10.134.146.1 
create_alias_for_host 1465 dev-l-vrt-146-005
create_alias_for_host 1466 dev-l-vrt-146-006
create_alias_for_host 1467 dev-l-vrt-146-007

# dev-l-vrt-146-008
create_alias_for_host 1468 10.134.146.8
create_alias_for_host 1469 dev-l-vrt-146-009
create_alias_for_host 191 dev-r-vrt-191

# stm server to run regression
create_alias_for_host stm88 mtl-stm-88
create_alias_for_host stmaz88 mtl-stm-az-088

# performance setup
create_alias_for_host 94 dev-l-vrt-094
create_alias_for_host 97 dev-l-vrt-097

# rxe regression setup
create_alias_for_host 5180 reg-l-vrt-5180
create_alias_for_host 5181 reg-l-vrt-5181
create_alias_for_host 51806 reg-l-vrt-5180-006
create_alias_for_host 51816 reg-l-vrt-5181-006

# guy levi setup
create_alias_for_host 212 dev-l-vrt-212
create_alias_for_host 213 dev-l-vrt-213
create_alias_for_host 202 dev-l-vrt-202

# parav
create_alias_for_host parav sw-mtx-036
create_alias_for_host danit reg-l-vrt-178

# sriov
create_alias_for_host 165 10.134.3.165
create_alias_for_host 166 10.134.3.166
create_alias_for_host 188 10.136.1.188
create_alias_for_host 189 10.134.3.189

###########################################################
#              build servers
###########################################################
# l-net-build06-006
create_alias_for_host ppc64buildserver 10.141.114.6 
create_alias_for_host x86buildserver 10.141.137.239 
create_alias_for_host cluster12 clx-cratus-12

sm ()
{
#   single module install
    local ans;

    sm_complete_words=$(awk '/if.*mod.*==/{print $5}' `which singlemoduleinstall.sh ` | sed 's/"//g')
    complete -W "$(echo ${sm_complete_words})" sm;

    if [ -z $1 ] ; then
        echo "sm [$(echo ${sm_complete_words[@]} | sed 's/\ /|/g' )]";
        return ;
    fi

    if [ -z "$(redpill)" ] ; then
        read -p "This is not VM are you sure ? [y/N]" ans;
        if [ "$ans" != "y" ] ; then
            return;
        fi
    fi

    while test $# -gt 0 ; do
        singlemoduleinstall.sh $1;
        shift;
    done
}

# geometryrestartoffice ()
# {
#     port=${1};
#     [ -z ${port} ] && return;
#     vncserver -kill :${port} ; sleep 10 ; vncserver -geometry 1920x1080 :${port}
#      xrandr -s "1920x1080"
# }

alias randrlaptop12='xrandr -s "1360x768"'
alias randroffice24='xrandr -s "1920x1080"'
alias randroffice27='xrandr -s "1920x1080"'
alias randrhome36='xrandr   -s "1280x720"'


randrme ()
{
    if [ -x /usr/bin/xdpyinfo ] ; then 
        xrandr -s $(xdpyinfo | awk '/dimension/ {print $2}');
    fi
}

alias gerritmkhook='gitdir=$(git rev-parse --git-dir); scp -p -P 29418 yonatanc@l-gerrit.mtl.labs.mlnx:hooks/commit-msg ${gitdir}/hooks/'
gitpushtogerrit ()
{
#     local branch=${1};
#     local topic=${2};
#     local remote=${3:-origin};
    local branch=;
    local topic=;
    local remote=origin;
    local head=HEAD;
    local answer=;

    gitpushtogerritcomplete;

    if [ $# -eq 0 ] ; then
        echo "gitpushtogerrit [-r <remote> | origin] [ -h <git index> | HEAD] -b <branch> -t <topic>" ;
#       complete -W "$(git remote)" gitpushtogerrit
        return;
    fi

    OPTIND=0;
    while getopts "b:t:r:h:" opt; do
        case $opt in
        b)
            branch=${OPTARG};
            ;;
        t)
            topic=${OPTARG};
            ;;
        r)
            remote=${OPTARG};
            ;;
        h)
            head=${OPTARG};
            ;;
        *)
            ;;
        esac;
    done;

    if [ -z "${branch}" -o -z "${topic}" ] ; then
        echo -e "missing branch and/or topic branch: \"${branch}\", topic: \"${topic}\""
        return;
    fi

    echo "git push ${remote} ${head}:refs/for/${branch}/${topic}"

    if [ $( git remote -v | grep ofed | wc -l ) -gt 0 ] ; then
        read -p "Do you need MetaData ? [Y/n] : " answer;
        if [ "$answer" != "n" ] ; then
           return;
        fi
    fi

    read -p "are you sure (checkpatch ok ?) ? [y/N] : " answer;
    if [ "$answer" != "y" ] ; then
       return;
    fi

    echo "pushing"
    git push ${remote} ${head}:refs/for/${branch}/${topic}
    echo "git push ${remote} ${head}:refs/for/${branch}/${topic}" >> .gitpush.log
    cat .gitpush.log | sort -u > .gitpush.log.tmp
    mv .gitpush.log.tmp .gitpush.log  1>/dev/null

#     if [ $# -lt 2 ] ; then
#          echo "less than 3 params branch=${branch}, topic=${topic}, remote=${remote}"
#     fi
#
#     if [ -z ${branch} ] || [ -z ${topic} ] ; then
#         echo "missing branch and/or topic"
#     else
#         echo "git push ${remote} HEAD:refs/for/${branch}/${topic}"
#         git push ${remote} HEAD:refs/for/${branch}/${topic}
#     fi

}

gitpushtogerritcomplete ()
{
    if [ -e .gitpush.log ] ; then
        complete -W "$(git remote) $(cat .gitpush.log | cat .gitpush.log |sed -e 's/.*for\///' -e 's/\//\n/' |sort -u |xargs)"  gitpushtogerrit
    fi
}
# gitpushtogerritcomplete;

listgitrepos ()
{
    local show_branches=no;
    local prefix="ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418"


    OPTIND=0;
    while getopts "bh" opt; do
        case $opt in
        b)
            show_branches=yes;
            ;;
        h)
            prefix="http://yonatanc@l-gerrit.mtl.labs.mlnx:8080";
            ;;
        *)
            ;;
        esac;
    done;

    echo "yonienv                      : https://github.com/yonicswe/yonienv";
    echo
    echo "linus torvald linux upstream : git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git";
    echo "                             : https://github.com/torvalds/linux.git";
    echo
    echo    "mellanox upstream kernel     : ${prefix}/upstream/linux";
    if [ "$show_branches" = "yes" ] ; then
    echo -e "                                |-rdma-rc-mlx";
    echo -e "                                |-rdma-next-mlx";
    echo -e "                                |-for-upstream   // regression next kerenl";
    echo -e "                                \`-for-linust     // regression currentn kernel";
    echo
    fi


    echo    "mellanox rdmacore            : ${prefix}/upstream/rdma-core";
    if [ "$show_branches" = "yes" ] ; then
    echo -e "                                   |-master        // stable";
    echo -e "                                   \`-for-upstream //up to date";
    echo
    fi

    echo "jason    rdmacore            : https://github.com/linux-rdma/rdma-core.git";
    echo "jason    kernel              : https://github.com/jgunthorpe/linux.git";
    echo;
    echo -e "mellanox ofed-4";
    echo -e "            |-- kernel       : ${prefix}/mlnx_ofed/mlnx-ofa_kernel-4.0";
    echo -e "            |-- legacy-libs";
    echo -e "            |      |-- libibverbs   : ${prefix}/mlnx_ofed_2_0/libibverbs";
    echo -e "            |      |-- libmlx4      : ${prefix}/mlnx_ofed_2_0/libmlx4";
    echo -e "            |      \`-- libmlx5      : ${prefix}/connect-ib/libmlx5";
    echo -e "            |      \`-- librdmacm    : ${prefix}/a/mlnx_ofed_2_0/librdmacm";
    echo -e "            \`-- rdma-core   : ${prefix}/mlnx_ofed/rdma-core"; 

    echo;
    echo -e "mellanox github              : https://github.com/Mellanox/";
    echo -e "           \`-- gpuDirect    : https://github.com/Mellanox/nv_peer_memory.git";

    echo;
    echo -e "mellanox regression vrtsdk       : ${prefix}/vrtsdk";
    echo -e "                |-- network      : ${prefix}/Linux_drivers_verification/networking";
    echo -e "                |-- core         : ${prefix}/Linux_drivers_verification/core";
    echo -e "                \`-- directtests : ${prefix}/Linux_drivers_verification/directtests";

    echo;
    echo "mellanox github/devx            : https://github.com/Mellanox/devx.git";
    echo;
    echo -e "mellanox tools"
    echo -e "   |-- perftest                        : ${prefix}/Performance/perftest";
    echo -e "   |-- iproute2 for upstream           : ${prefix}/upstream/iproute2";
    echo -e "   \'-- iproute2 for ofed              : ${prefix}/mlnx_ofed/iproute2";
    echo;
    echo "iproute E ker.org                      : git://git.kernel.org/pub/scm/network/iproute2/iproute2-next.git"

    echo;
    echo "mellanox Firmware tavor      : ${prefix}/ConnectX"
    echo -e "          \`-- golan      : ${prefix}/golan_fw"
}

alias gitclone-ofed-rdmacore='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed/rdma-core'
alias gitclone-ofed-libibverbs='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed_2_0/libibverbs'
alias gitclone-ofed-libmlx5='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/connect-ib/libmlx5'
alias gitclone-ofed-libibumad='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/ib_mgmt/libibumad'
alias gitclone-ofed-libmlx4='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed_2_0/libmlx4'
alias gitclone-ofed-librxe='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed/librxe'
alias gitclone-ofed-librdmacm='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed_2_0/librdmacm'
alias gitclone-ofed-iproute2='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed/iproute2'

alias gitclone-upstream-kernel='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/upstream/linux'
alias gitclone-upstream-opensm='git clone git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/ib_mgmt/opensm'
alias gitclone-upstream-rdmacore='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/upstream/rdma-core'
alias gitclone-upstream-iproute2='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/upstream/iproute2'

alias gitclone-directtests='git clone ssh://l-gerrit.mtl.labs.mlnx:29418/Linux_drivers_verification/directtests/'
alias gitclone-dpdk='git clone https://github.com/mellanox/dpdk.org'
alias gitclone-ucx='git clone https://github.com/openucx/ucx'
alias gitclone-perftest='git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/Performance/perftest'

alias gitrebase-ofed-kernel-5-0='git fetch origin mlnx_ofed_5_0; git rebase FETCH_HEAD'


ucxbuild ()
{
    ./autogen.sh && ./contrib/configure-devel --enable-debug --prefix=$PWD/install && make -j 16 && make install 
}

gitclone-ofed-kernel() 
{
    local dest_name=${1:-mlnx-ofa_kernel-4.0};
    git clone ssh://yonatanc@l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed/mlnx-ofa_kernel-4.0 ${dest_name};
    cd ${dest_name};
    ofedmklinks;
}    

make-ofed-legacy-libs ()
{
    cd libibverbs/  ; mkupstreamlib1sttime ; sudo make install ; 
    cd ../libmlx5/ ; mkupstreamlib1sttime ; sudo make install ; 
    cd ../libibumad ; mkupstreamlib1sttime ; sudo make install;
    cd .. ;
}

gitclone-ofed-legacy-libs ()
{
    gitclone-ofed-libibverbs;
    gitclone-ofed-libmlx5;
    gitclone-ofed-libibumad;
    echo -e "\nfinished clone, would you like to build & install ";
    are_you_sure_default_no;
    [ $? -eq 0 ] && return;
    make-ofed-legacy-libs;
}


ibmod ()
{
# lsmod |grep "^ib_\|^mlx\|^rdma" | awk '{print $1" "$3}' | column -t |grep "ib\|mlx\|rdma";
    local modules_path=;
    local modules_base_path=;
    local module_grep=${1};
    local indx=0;

    if [ -d /usr/lib/modules/$(uname -r) ] ; then
        modules_base_path="/usr/lib/modules/$(uname -r)";
    elif  [ -d /lib/modules/$(uname -r) ]  ; then
        modules_base_path="/lib/modules/$(uname -r)";
    else
        echo "no /lib/modules or /usr/lib/modules/ found";
    fi

    modules_path="${modules_base_path}/kernel/drivers/infiniband"
    if [ -d ${modules_base_path}/kernel/drivers/net/ethernet/mellanox ] ; then
        modules_path+=" ${modules_base_path}/kernel/drivers/net/ethernet/mellanox";
    fi;

    modules_path+=" ${modules_base_path}/compat"
    modules_path+=" ${modules_base_path}/drivers/vfio";

    # ofed libs are usually under extra
    if [ -d ${modules_base_path}/extra ] ; then
        modules_path+=" ${modules_base_path}/extra";
    fi

    if [ -n "${module_grep}" ] ; then 
        if [ ${module_grep} == "print" ] ; then 
            modules_path+=" ${modules_base_path}/kernel/net/core";
            find ${modules_path}  -type f -exec basename {} \; 2>/dev/null | sed -e 's/\.ko$//g' -e 's/\.ko\.xz$//g';
            return;
        fi
    fi

    find ${modules_path}  -type f -exec basename {} \; | sed -e 's/\.ko$//g' -e 's/\.ko\.xz$//g' | sort -u |
        while read m ; do
            lsmod | awk '{print $1" "$3" " }' | \grep $m ;
#             lsmod | cut -d' ' -f1  | \grep $m | \grep "ib\|mlx\|rxe";
    done | column -t | if [ -n "${module_grep}" ] ; then
                          tee | sort -h -k2 | grep ${module_grep} ;
                       else
                         # tee | sort -h -k2 ;
                           tee | sort -d;
                       fi
}
alias noxx='lspci -tvv | grep --color -C 3 nox'
alias nox='lspci | grep --color nox'
# alias cdregression='cd ~/devel/regression'
# alias cdregressioncore='cd ~/devel/regression/core'
# alias cdregressionnet='cd ~/devel/regression/networking'
# alias cdregressionrxe='cd ~/devel/rxe_regression'
# alias cdshare="cd ${HOME}/share/"
source ${yonienv}/regression_complete.sh


alias mkinfinibandcore="make M=drivers/infiniband/core modules -j ${ncoresformake}"
alias mkinfinibandrxe="make M=drivers/infiniband/sw/rxe modules -j ${ncoresformake}"
alias mkinfinibandiser="make M=drivers/infiniband/ulp/iser modules -j ${ncoresformake}"
mkinfinibandmlx4 ()
{
    \make M=drivers/net/ethernet/mellanox/mlx4 modules -j ${ncoresformake}
    \make M=drivers/infiniband/hw/mlx4 modules -j ${ncoresformake}
}
mkinfinibandmlx5 ()
{
    \make M=drivers/infiniband/hw/mlx5 modules -j ${ncoresformake}
    \make M=drivers/net/ethernet/mellanox/mlx5/core modules -j ${ncoresformake}
}

alias mkinfiniband="\make M=drivers/infiniband/ modules -j ${ncoresformake}"

if [ -e ${yonienv}/cdlinux.bkp ] ; then 
    source ${yonienv}/cdlinux.bkp
else
    export linuxkernelsourcecode=/images/kernel/linux
fi

alias cdlinux='cd ${linuxkernelsourcecode}'
changecdlinux () {
    echo "cdlinux : ${linuxkernelsourcecode}";
    read -p "would you like to change ? [y/N] : " answer;
    if [ "$answer" == "y" ] ; then
        read -p "Enter new path : " newlocation;
    export linuxkernelsourcecode=${newlocation};
    echo "export linuxkernelsourcecode=${newlocation}" > ${yonienv}/cdlinux.bkp;
    fi
}
mountkernelsources () {

    local server=${1:-dev-l-vrt-146};

    # test is /images/ exists
    if ! [ -d /images ] ; then 
        echo "there is no /images, use mkrootmountdir to create";
        return;
    fi 

    mountpoint /images  > /dev/null;
    if [ $? -eq 0 ] ; then
        echo "already mounted";
    else
        cd > /dev/null
        echo "sudo mount ${server}:/images/ /images/" ;
        sudo mount ${server}:/images/ /images/
        cd - > /dev/null;
    fi;
    changecdlinux;

}

alias umountkernelsources='set -x ; cd ; sudo umount /images/ ; set +x'
mkrootmountdir ()
{
    local path=${1:-images};
    sudo install -o yonatanc -g mtl -d /${path};
}

# alias mountkernelkabisources='pushd ~ ; set -x ; sudo mount dev-l-vrt-146:/images/kernel/kabi /images/kernel/ ; set +x ; popd'
# alias mountkerneldebug='pushd ~ ; set -x ; sudo mount dev-l-vrt-146:/images/debug /images/debug/ ; set +x; popd'

backupgitkernel ()
{
    tarfile=/images/git_backup_$(date +"%d%b%Y").bz2;
    backupdest=dev-l-vrt-145:/images/kernel;

    echo -e "\n============================\n\tcompress\n============================\n"
    echo "tar cjvf ${tarfile}  /images/kernel"
    echo -e "\n============================\n\tcopy to\n============================\n"
    echo "scp ${tarfile} ${backupdest}"
}

alias backupusrlib64='tar -C / -cjvf usr_lib64.bkp.bz2 /usr/lib64'
alias restoreusrlib64='tar -C / -xjvf usr_lib64.bkp.bz2'

ofedmkmetadata () 
{
    local num_of_commits=$1;
    if [ -n "${num_of_commits}" ] ; then 
        ./devtools/add_metadata.sh -n ${num_of_commits};
    else
        echo "You forgot  <number of commits>"
        return;
    fi

    echo "Verifying yonatan cohen metadata";        
    echo "./devtools/verify_metadata.sh -p metadata/Yonatan_Cohen.csv"
    ./devtools/verify_metadata.sh -p metadata/Yonatan_Cohen.csv;
}

ofeddeletebackport ()
{
    local ans=;
    read -p "are you running this from ofed kernel root directory [Y/n] " ans;
    [ "${ans}" == "n" ] && return;

    read -p "are you checked out on the backport branch [Y/n] " ans;
    [ "${ans}" == "n" ] && return;

    if  [ ! -L configure ] || [ ! -L makefile ] || [ ! -L Makefile ]  ; then
        echo "you need to run ofedmklinks";
        return;
    fi

    read -p "are you sure about deleting backport branch ? [y/N] " ans;
    if  [ ! "${ans}" == "y" ] ; then
        return ;
    fi ;
    echo "./ofed_scripts/cleanup"
    ./ofed_scripts/cleanup

    echo "make distclean"
    make distclean
}

ofedmklinks ()
{
    ln -snf ofed_scripts/Makefile Makefile
    ln -snf ofed_scripts/makefile makefile
    ln -snf ofed_scripts/configure configure
}

ofedupdatebackports ()
{
    ./ofed_scripts/backports_fixup_changes.sh;
    echo -n "continue with backport update " ; are_you_sure_default_yes ;
    [ $? -eq 0 ] && return;
    ./ofed_scripts/ofed_get_patches.sh && ./ofed_scripts/cleanup && ./ofed_scripts/backports_copy_patches.sh 
    echo "git add relevant_patch from backports/ and discard the rest with git checkout ./backports"
}

ofedapplybackports ()
{
    local kernel_version=${1:-2.6.16};
    ./configure -j ${ncoresformake} --kernel-version ${kernel_version} --skip-autoconf;
}
alias ofedconfigurewithcore='./configure -j ${ncoresformake} --with-core-mod'
alias ofedconfigurewithrxe='./configure -j ${ncoresformake} --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-rxe-mod'
alias ofedconfigure='./configure -j ${ncoresformake} --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-ipoib-mod --with-innova-flex --with-e_ipoib-mod --with-memtrack'
alias ofedconfigure4.7='./configure -j ${ncoresformake} --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-ipoib-mod'

ofedconfigureforkernel ()
{
    local kernel_version=$1;
    local kernel_headers=/mswg2/work/kernel.org/x86_64;
    local configure_options="--with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-ipoib-mod"

    if [ -d ${kernel_headers}/linux-${1} ]  ; then
        echo "./configure -j ${ncoresformake} ${configure_options} --kernel-version=${kernel_version} --kernel-sources=${kernel_headers}/linux-${kernel_version}";
        are_you_sure_default_yes;
        [ $? -eq 0 ] && return;
        ./configure -j ${ncoresformake} ${configure_options} --kernel-version=${kernel_version} --kernel-sources=${kernel_headers}/linux-${kernel_version};
    else
        echo "Did not find ${kernel_headers}/linux-"
    fi
}

alias ofedconfigureforkernel-5.2="./configure -j --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlxfw-mod --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-ipoib-mod --kernel-version 5.2  --kernel-sources /mswg2/work/kernel.org/x86_64/linux-5.2/
"

ofedorigindir ()
{
    cd /.autodirect/mswg/release/MLNX_OFED/$(ofed_info -s | sed 's/://g')
}

alias ofedversion='[ -e /usr/bin/ofed_info ] && ofed_info -s | sed "s/://g"'
alias ofedstop='sudo /etc/init.d/openibd force-stop'
alias ofedstart='sudo /etc/init.d/openibd start'
alias ofedrestart='ofedstop; ofedstart'


m ()
{
    myip;
    mydistro;
    ofedversion;

    if [ -e /lib64/libibverbs.so ] ; then 
        echo "/lib64/libibverbs.so -> $(readlink -f /lib64/libibverbs.so)";
    fi
}

vlinstall ()
{
    local answer;
    echo "";

    if (( 0 == $(rpm -q mft | grep mft- | wc -l ) )) ; then
        echo -e "\033[1;33;7m you need to install mft before you install vl\033[0m";
        return;
    fi
#     read -p "continue ? [y/N] : " answer;
#     if [ "$answer" == "y" ] ; then
    sudo /.autodirect/net_linux_verification/tools/install_vls.sh;
#     fi
#  another script that could be used.
#  sudo /mswg/projects/ver_tools/reg2_latest/install.sh;
}

regression_tools_install ()
{
    sudo /mswg/projects/ver_tools/reg2_latest/install.sh;
}

# you must install mft to be able to change link type.
mftinstall ()
{
    local answer;
    echo -e "\033[1;33;7mmake sure that /lib/modules/$(uname -r)/source -> to a valid kernel source tree\033[0m"
    read -p "continue ? [y/N] : " answer;
    if [ "$answer" == "y" ] ; then
        sudo /mswg/release/mft/mftinstall;
    fi
}

mftstatus ()
{
    if [ -x /usr/bin/mst ] ; then 
        echo -e "\033[1;33;7mmake sure that you sudo mst start \033[0m";
        sudo mst status -vv
    else
        echo "you need to install mft 'mftinstall'";
    fi

}

mftcheckstatus ()
{
    return $(sudo mst status | grep "not loaded" | wc -l );
}

mftstart ()
{
   sudo mst start;
   mst_dev_array=( $(ls /dev/mst/) );
}

if [ -d /dev/mst ] ; then
    mst_dev_array=( $(ls /dev/mst/) );
fi

mftchoosedev ()
{
    local index=0;
    local dev_num=;

    for i in ${mst_dev_array[@]} ; do
        echo "[${index}] ${mst_dev_array[$index]}";
        ((index++));
    done

    read -p "choose device: " dev_num;
    return ${dev_num};
}

mftenablesriov ()
{
    local mst_dev=$1;
    local hypervisor=1;

    redpill;
    hypervisor=$?;
    if [ ${hypervisor} -eq 0 ] ; then
        "This is A VM. you need to do this on hypervisor";
        echo -e "\033[1;33;7m This is A VM. you need to do this on hypervisor\033[0m"
        return;
    fi

    mftcheckstatus
    if (( $? != 0 )) ; then
        echo -e "\033[1;33;7myou need to run mftstart \033[0m";
        return 1;
    fi

    if [ -z "${mst_dev}" ] ; then
        mftstatus;
        mftchoosedev;
        mst_dev=/dev/mst/${mst_dev_array[$?]}
    fi;

    echo "sudo mlxconfig -d ${mst_dev} set SRIOV_EN=1 NUM_OF_VFS=8 FPP_EN=1";
    sudo mlxconfig -d ${mst_dev} set SRIOV_EN=1 NUM_OF_VFS=8 FPP_EN=1;
}

# mftdisablesriov ()
# {
# 
# 
# }

mftsetlinktypeeth ()
{
    local mst_dev=$1;
    local hypervisor=1;

    redpill;
    hypervisor=$?;
    if [ ${hypervisor} -eq 0 ] ; then
        "This is A VM. you need to do this on hypervisor";
        echo -e "\033[1;33;7m This is A VM. you need to do this on hypervisor\033[0m"
        return;
    fi

    mftcheckstatus
    if (( $? != 0 )) ; then
        echo -e "\033[1;33;7myou need to run mftstart \033[0m";
        return 1;
    fi

    if [ -z "${mst_dev}" ] ; then
        mftstatus;
        mftchoosedev;
        mst_dev=/dev/mst/${mst_dev_array[$?]}
    fi;

    echo "sudo mlxconfig -d ${mst_dev} set LINK_TYPE_P1=2 LINK_TYPE_P2=2";
    sudo mlxconfig -d ${mst_dev} set LINK_TYPE_P1=2 LINK_TYPE_P2=2;
    echo "sudo mlxfwreset -d ${mst_dev} --level 3 reset"
}

mftsetlinktypeinfiniband ()
{
    local mst_dev=$1;
    local hypervisor=1;

    redpill;
    hypervisor=$?;
    if [ ${hypervisor} -eq 0 ] ; then
        "This is A VM. you need to do this on hypervisor";
        echo -e "\033[1;33;7m This is A VM. you need to do this on hypervisor\033[0m"
        return;
    fi

    if [ -z "${mst_dev}" ] ; then
        mftstatus;
        mftchoosedev;
        mst_dev=/dev/mst/${mst_dev_array[$?]}
    fi;

    echo "sudo mlxconfig -d ${mst_dev} set LINK_TYPE_P1=1 LINK_TYPE_P2=1";
    sudo mlxconfig -d ${mst_dev} set LINK_TYPE_P1=1 LINK_TYPE_P2=1;

    echo "sudo mlxfwreset -d ${mst_dev} --level 3 reset"
}

mftresethca ()
{
    local mst_dev=$1;
    local hypervisor=1;

    redpill;
    hypervisor=$?;
    if [ ${hypervisor} -eq 0 ] ; then
        "This is A VM. you need to do this on hypervisor";
        echo -e "\033[1;33;7m This is A VM. you need to do this on hypervisor\033[0m"
        return;
    fi

    if [ -z "${mst_dev}" ] ; then
        mftstatus;
        mftchoosedev;
        mst_dev=/dev/mst/${mst_dev_array[$?]}
    fi;

#     echo "sudo mlxconfig -d ${mst_dev} set LINK_TYPE_P1=1 LINK_TYPE_P2=1";
#     sudo mlxconfig -d ${mst_dev} set LINK_TYPE_P1=1 LINK_TYPE_P2=1;

    echo "sudo mlxfwreset -d ${mst_dev} reset --skip_driver"
    sudo mlxfwreset -d ${mst_dev} reset --skip_driver;
}

mftquerynvconf ()
{
    local mst_dev=$1;
    local attr;

#     local hypervisor=1;
#     redpill;
#     hypervisor=$?;
#     if [ ${hypervisor} -eq 0 ] ; then
#         "This is A VM. you need to do this on hypervisor";
#         echo -e "\033[1;33;7m This is A VM. you need to do this on hypervisor\033[0m"
#         return;
#     fi

    if [ -z "${mst_dev}" ] ; then
        if [ $(ismoduleup mst_pci) == "no" ] ; then 
            echo mft is down
            return ; 
        fi;
        mftstatus;
        mftchoosedev;
        mst_dev=/dev/mst/${mst_dev_array[$?]}
    fi;

    read -p "specific attribute ? " attr;

    echo "sudo mlxconfig -d ${mst_dev} q";
    if [ -z $attr ] ; then 
        sudo mlxconfig -d ${mst_dev} q;
    else
        sudo mlxconfig -d ${mst_dev} q | grep $attr;

        if [ $(sudo mlxconfig -d ${mst_dev} q | grep $attr | wc -l ) -gt 0 ] ; then 
           echo "sudo mlxconfig -d ${mst_dev} s <attr>=<value>";
        fi
    fi
}

mftgetlinktype ()
{
    for d in /dev/mst/* ; do
        echo ${d};
        sudo mlxconfig -d ${d} q | \grep LINK_TYPE;
    done
}

sriovsetupmlx5_1 ()
{
    echo "set sriov for mlx5_0 : TBD"

#   create 1 VF
    echo 1 > /sys/class/infiniband/mlx5_1/device/sriov_numvfs 


#   get the node_guid from the PF
    node_guid=$(cat  /sys/class/infiniband/mlx5_1/node_guid)

#   generate a new node_guid using the PFs node_guid
    vf_node_guid=$(create_node_guid $node_guid);

#   generate a new port_guid using the the new node_guid
    vf_port_guid=$(create_port_guid $vf_node_guid);

#   get pci address of VF to use for bind->unbind
    ibdev2netdev -v | grep mlx5_2 

#   setup policy of the VF
    echo Follow > /sys/class/infiniband/mlx5_1/device/sriov/0/policy
#   configure node_guid
    echo $vf_node_guid > /sys/class/infiniband/mlx5_1/device/sriov/0/node_guid
    echo $vf_port_guid > /sys/class/infiniband/mlx5_1/device/sriov/0/port_guid

#   unbind/bind to activate configuration
    echo 0000:81:01.2 > /sys/bus/pci/drivers/mlx5_core/unbind
    echo 0000:81:01.2 > /sys/bus/pci/drivers/mlx5_core/bind
}

_checkpatchcomplete ()
{
    [ -z "$(ls *.patch 2>/dev/null)" ] && return;
    ls *.patch | tr ' ' '\n';
    complete -W "$(ls *.patch)" checkpatch checkpatchkernel;
    return;
}

checkpatchkernel ()
{
    local patch_file=;

    if [ $# -eq 0 ] ; then _checkpatchcomplete ; return ; fi;
    local patch_file=$(readlink -f $@);

    cdlinux;
    ./scripts/checkpatch.pl --strict --ignore=GERRIT_CHANGE_ID ${patch_file};
    cd -;
}

checkpatchuserpace ()
{
    local patch_file=$(readlink -f $@);
    local gerrit_ignore="CONST_STRUCT";
    gerrit_ignore+=",EXECUTE_PERMISSIONS";
    gerrit_ignore+=",FILE_PATH_CHANGES";
    gerrit_ignore+=",GERRIT_CHANGE_ID";
    gerrit_ignore+=",PREFER_KERNEL_TYPES";
    gerrit_ignore+=",USE_NEGATIVE_ERRNO";

    if  [ $# -eq 0 ] ; then _checkpatchcomplete ; return ; fi
    if ! [ -e ./scripts/checkpatch.pl ]  ; then 
        cdlinux;
        ./scripts/checkpatch.pl --strict --ignore=${gerrit_ignore} ${patch_file};
        cd -;
    else
        ./scripts/checkpatch.pl --strict --ignore=${gerrit_ignore} ${patch_file};
    fi

}

alias kgb="sudo /.autodirect/GLIT/SCRIPTS/AUTOINSTALL/VIRTUALIZATION/kvm_guest_builder"
alias vmmkredhat74="kgb -o linux  -c 16 -r 8192 -d 35 -l RH_7.4_x86_64_virt_guest   "
alias vmmkredhat75="kgb -o linux  -c 16 -r 8192 -d 35 -l RH_7.5_x86_64_virt_guest   "
alias vmmkfedora28="kgb -o linux  -c 16 -r 8192 -d 35 -l Fedora_28_x86_64_virt_guest"
alias vmmkfedora29="kgb -o linux  -c 16 -r 8192 -d 35 -l Fedora_29_x86_64_virt_guest"
alias vmmkubutu18.4="kgb -o linux  -c 16 -r 8192 -d 35 -l Ubuntu_18.04_x86_64_virt_guest"
alias vmls="kgb -o linux"
vmmkhelp()
{
    echo "su - ";
    echo -e "/.autodirect/GLIT/SCRIPTS/AUTOINSTALL/VIRTUALIZATION/kvm_guest_builder -o linux -l \033[1;31m<your choice of vm>\033[00m -c 16 -r 8192 -d 35";
    echo "choose a VM to install from the list produced by mkvmls"
}

listibuserlibs ()
{
    ib_libs=(.*/libibverbs.so)
    ib_libs+=(.*/libmlx4.*.so)
    ib_libs+=(.*/libmlx5.*.so)
      
    sudo updatedb -U /lib64
    for (( i=0 ; i< ${#ib_libs[@]} ; i++))  ; do
        echo -e "\n\t\t\033[1;35m==== ${ib_libs[$i]#.*/} ====\033[0m"
        locate -r "${ib_libs[$i]}" | while read f ; do ls  --format='context'  $f ; done | awk '{$1="" ; print $0 }' | column -t
    done
}

locatelibibverbs ()
{
    local str="${1:-libibverbs.so}";
    local db="${yonienv}/iblibs_$(hostname -s).db";

    if [ -e ${db} ] ; then 
#       updatedb only if needed. installed lib newer than db
        if [ /lib64/libibverbs.so -nt ${db} ] ; then
            sudo updatedb -U /lib64 -o ${db};
        fi
    else
        sudo updatedb -U /lib64 -o ${db};
    fi

    locate -d ${db} -L ${str} | while read f ; do 
        if [ -L $f ] ; then 
            ls -l $f;
        else 
            echo $f;
        fi
    done
}


findiblib_old ()
{
#     ib_libs=(libmlx5-rdmav2.so libibacmp.so libibumad.so libibverbs.so)
#     ib_libs+=(libibcm.so libhns-rdmav2.so libcxgb3-rdmav2.so libcxgb4-rdmav2.so libi40iw-rdmav2.so)
#     ib_libs+=(librdmacm.so libnes-rdmav2.so libmlx4-rdmav2.so libmthca-rdmav2.so libmlx5.so)
#     ib_libs+=(libocrdma-rdmav2.so libhfi1verbs-rdmav2.so libipathverbs-rdmav2.so libqedr-rdmav2.so)
#     ib_libs+=(libvmw_pvrdma-rdmav2.so librxe-rdmav2.so librspreload.so libibacmp.so);

    ib_libs=(.*/libibverbs.so)
    ib_libs+=(.*/libmlx4.so)
    ib_libs+=(.*/libmlx4-rdmav.*so)
    ib_libs+=(.*/libmlx5.so)
    ib_libs+=(.*/librxe-rdmav.*so)
    ib_libs+=(.*/librxe-rdmav.*so)
    ib_libs+=(.*/libibumad.so)
    ib_libs+=(.*/libibcm.so)
    ib_libs+=(.*/libipathverbs-rdmav.*so)
    ib_libs+=(.*/libnes-rdmav*.so)
    ib_libs+=(.*/libhfi1verbs-rdmav.*so)
    ib_libs+=(.*/libhns-rdmav.*so)
    ib_libs+=(.*/libocrdma-rdmav.*so)
    ib_libs+=(.*/libi40iw-rdmav.*so)
    ib_libs+=(.*/libbnxt_re-rdmav.*so)
    ib_libs+=(.*/libqedr-rdmav.*so)
    ib_libs+=(.*/libvmw_pvrdma-rdmav.*so)
    ib_libs+=(.*/libcxgb4-rdmav.*so)
    ib_libs+=(.*/libcxgb3-rdmav.*so)
    ib_libs+=(.*/libmthca-rdmav.*so)
    ib_libs+=(.*/librdmacm.so)
    ib_libs+=(.*/libibacmp.so)
    ib_libs+=(.*/librspreload.so)


    local ib_libs_search_path=(/usr/lib64/  /usr/local/lib64/)
#   local ib_libs_search_path=(/usr/lib/ /usr/lib64/ /usr/local/lib/  /usr/local/lib64/)
#   local ib_libs_search_path=(/usr/lib/ /usr/lib64/ /usr/local/lib/  /usr/local/lib64/ /lib /lib64/)

    local delete_app=
    local lib=

    if [ -n ${1} ] ; then
        if [ "${1}" == "-d" ] ; then
            read -p "delete ib libs [N/y]: " ans;

            if [ "$ans" != "y" ] ; then
                return;
            fi
            delete_app="-delete";
        else
            lib=$1;
        fi
    fi
    

    libs="${ib_libs[0]}"
    for (( i=1 ; i< ${#ib_libs[@]} ; i++))  ; do
        libs+=" -o -regex ${ib_libs[$i]}"
    done

#     echo $libs;
    for i in $(find ${ib_libs_search_path[@]} -regex $libs) ; do 
        ls -l $i 
    done | column -t;

#         if [ -z $lib ] ; then
#             echo -e "\033[1;35m--- ${i} ----\033[0m"
#             sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f  -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" ${delete_app} 2>/dev/null
#         else
#             sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f  -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" | grep ${lib} 2>/dev/null
#         fi
#         ((count++));
#     done
}

manageiblibs ()
{
#     ib_libs=(libmlx5-rdmav2.so libibacmp.so libibumad.so libibverbs.so)
#     ib_libs+=(libibcm.so libhns-rdmav2.so libcxgb3-rdmav2.so libcxgb4-rdmav2.so libi40iw-rdmav2.so)
#     ib_libs+=(librdmacm.so libnes-rdmav2.so libmlx4-rdmav2.so libmthca-rdmav2.so libmlx5.so)
#     ib_libs+=(libocrdma-rdmav2.so libhfi1verbs-rdmav2.so libipathverbs-rdmav2.so libqedr-rdmav2.so)
#     ib_libs+=(libvmw_pvrdma-rdmav2.so librxe-rdmav2.so librspreload.so libibacmp.so);

    ib_libs=("libibverbs\.*")
    ib_libs+=(libmlx4.so)
    ib_libs+=(libmlx4-rdmav*.so)
    ib_libs+=("libmlx5\.*")
    ib_libs+=(librxe-rdmav*.so)
    ib_libs+=(librxe-rdmav*.so)
    ib_libs+=("libibumad\.*")
    ib_libs+=(libibcm.so)
    ib_libs+=(libipathverbs-rdmav*.so)
    ib_libs+=(libnes-rdmav*.so)
    ib_libs+=(libhfi1verbs-rdmav*.so)
    ib_libs+=(libhns-rdmav*.so)
    ib_libs+=(libocrdma-rdmav*.so)
    ib_libs+=(libi40iw-rdmav*.so)
    ib_libs+=(libbnxt_re-rdmav*.so)
    ib_libs+=(libqedr-rdmav*.so)
    ib_libs+=(libvmw_pvrdma-rdmav*.so)
    ib_libs+=(libcxgb4-rdmav*.so)
    ib_libs+=(libcxgb3-rdmav*.so)
    ib_libs+=(libmthca-rdmav*.so)
    ib_libs+=(librdmacm.so)
    ib_libs+=(libibacmp.so)
    ib_libs+=(librspreload.so)


    local ib_libs_search_path=(/usr/lib64/  /usr/local/lib64/)
#   local ib_libs_search_path=(/usr/lib/ /usr/lib64/ /usr/local/lib/  /usr/local/lib64/)
#   local ib_libs_search_path=(/usr/lib/ /usr/lib64/ /usr/local/lib/  /usr/local/lib64/ /lib /lib64/)

    local delete_app=
    local lib=
    local backup=""
    local -a backup_libs=();

    if [ -n ${1} ] ; then
        if [ "${1}" == "-d" ] ; then
            read -p "delete ib libs [N/y]: " ans;

            if [ "$ans" != "y" ] ; then
                return;
            fi
            delete_app="-delete";
        elif [ "${1}" == "-b" ] ; then
            backup=yes;
        else
            lib=$1;
        fi
    fi

    count=0;
    for i in ${ib_libs[@]} ; do
#         sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f -ls ${delete_app} 2>/dev/null

        if [ -n "${backup}" ] ; then 
            backup_libs+=( $(sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f  -printf "%h/%f\n" ) );
            ((count++));
            continue;
        fi

        if [ -z $lib ] ; then
            echo -e "\033[1;35m--- ${i} ----\033[0m"
#             sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" ${delete_app} 2>/dev/null
            sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" ${delete_app};
            sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}" -type l -ls ${delete_app} 2>/dev/null | awk '{print $11" --> " $13}'
#           sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}" -type l  -printf "%Ad/%Am/%AY %AH:%AM %h/%f %Y\n" ${delete_app} 2>/dev/null
        else
            sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" \(-type f -o -type l\) -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" | grep ${lib} 2>/dev/null
        fi
        ((count++));
    done

    if [ -n "${backup}" ]  ; then 
        echo "backup IB libs to ib_libs_backup.bz2"
        tar cjvf ib_libs_backup.bz2 ${backup_libs[@]};
    fi
}

manageibapps ()
{

#     ib_apps=(cmpost cmtime ib_acme ibacm ibv_asyncwatch ibv_devices );
#     ib_apps+=(ibv_devinfo ibv_rc_pingpong ibv_srq_pingpong ibv_uc_pingpong ibv_ud_pingpong);
#     ib_apps+=(ibv_xsrq_pingpong iwpmd mckey rcopy rdma-ndd rdma_client rdma_server rdma_xclient);
#     ib_apps+=(rdma_xserver riostream rping rstream srp_daemon ucmatose udaddy udpong umad_reg2 umad_register2);

    ib_apps=( cmpost              )
    ib_apps+=( cmtime              )
    ib_apps+=( ib_acme             )
    ib_apps+=( ibacm               )
    ib_apps+=( ibv_asyncwatch      )
    ib_apps+=( ibv_devices         )
    ib_apps+=( ibv_devinfo         )
    ib_apps+=( ibv_rc_pingpong     )
    ib_apps+=( ibv_srq_pingpong    )
    ib_apps+=( ibv_uc_pingpong     )
    ib_apps+=( ibv_ud_pingpong     )
    ib_apps+=( ibv_xsrq_pingpong   )
    ib_apps+=( iwpmd               )
    ib_apps+=( mckey               )
    ib_apps+=( rcopy               )
    ib_apps+=( rdma-ndd            )
    ib_apps+=( rdma_client         )
    ib_apps+=( rdma_server         )
    ib_apps+=( rdma_xclient        )
    ib_apps+=( rdma_xserver        )
    ib_apps+=( riostream           )
    ib_apps+=( rping               )
    ib_apps+=( rstream             )
    ib_apps+=( srp_daemon          )
    ib_apps+=( ucmatose            )
    ib_apps+=( udaddy              )
    ib_apps+=( udpong              )
    ib_apps+=( umad_reg2           )
    ib_apps+=( umad_register2      )

    local ib_apps_search_path=(/usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/);

    local delete_app=
    local backup=""
    local -a backup_apps=();

    if [ -n ${1} ] ; then
        if [ "${1}" == "-d" ] ; then
            read -p "delete ib apps [N/y]: " ans;

            if [ "$ans" != "y" ] ; then
                return;
            fi
            delete_app="-delete";
        elif [ "${1}" == "-b" ] ; then
            backup=yes;
        fi
    fi

    count=0;
    for i in ${ib_apps[@]} ; do

        if [ -n "${backup}" ] ; then 
            backup_apps+=( $(sudo find ${ib_apps_search_path[@]} -name "${ib_apps[${count}]}" -type f -printf "%h/%f\n") );
            ((count++));
            continue;
        fi

        echo -e "\033[1;35m--- ${i} ----\033[0m"

#       sudo find ${ib_apps_search_path[@]} -name "${ib_apps[${count}]}" -type f -ls ${delete_app} 2>/dev/null
        sudo find ${ib_apps_search_path[@]} -name "${ib_apps[${count}]}" -type f -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" ${delete_app} 2>/dev/null
        ((count++));
    done

    if [ -n "${backup}" ]  ; then 
        echo "backup IB apps to ib_apps_backup.bz2"
        tar cjvf ib_apps_backup.bz2 ${backup_apps[@]};
    fi
}

cleanibheaders ()
{
    echo "sudo rm -rf /usr/include/infiniband";
    echo "sudo rm -rf /usr/include/rdma";
    echo "sudo rm -rf /usr/local/include/infiniband";
    echo "sudo rm -rf /usr/local/include/rdma "

    read -p "are you sure ? [y/N] : " answer;
    if [ "$answer" != "y" ] ; then
       return;
    fi

    set -x
    sudo rm -rf /usr/include/infiniband
    sudo rm -rf /usr/include/rdma
    sudo rm -rf /usr/local/include/infiniband
    sudo rm -rf /usr/local/include/rdma
    set +x
}

cleanibconfiguration ()
{
    echo "sudo rm -rf /etc/libibverbs.d/";
    echo "sudo rm -rf /usr/local/etc/libibverbs.d/";

    read -p "are you sure ? [y/N] : " answer;
    if [ "$answer" != "y" ] ; then
       return;
    fi

    set -x
    sudo rm -rf /etc/libibverbs.d/
    sudo rm -rf /usr/local/etc/libibverbs.d/
    set +x
}

alias sp='showprettygids.sh'

rxecounters ()
{
    for i in  `find   /sys/class/infiniband/rxe0/ports/1/hw_counters/ -type f` ; do echo "$(basename $i) = $(cat $i)" ; done|column -t
}


howCleanIsMyHome ()
{
    du -sch $(find . -maxdepth 1 | grep -vP ".snapshot|^.$")|grep -P "M\s|G\s"
}

csfilesPaths=(include/)
csfilesPaths+=(drivers/infiniband/hw/rxe/)
csfilesPaths+=(drivers/infiniband/core/)

csfiles ()
{
    find  ${csfilesPaths[@]} -name "*.[ch]" -type f -print  > cscope.files
    cscope -bqk
    echo "run cscope -d to use the data base youve just created"
}

ismoduleup ()
{
    local module=$1;
    if [ $(lsmod |grep -w ${module} | wc  -l ) -gt 0 ] ; then
        echo yes;
    else
        echo no;
    fi
}

loadmoduleifnotloaded ()
{
    local module=$1
    if [ "$(ismoduleup ${module})"  == "no" ] ; then
        sudo modprobe ${module} ;
        echo "load ${module}"
    fi
}

removemoduleifloaded ()
{
    local module=$1
    if [ "$(ismoduleup ${module})"  == "yes" ] ; then
#       sudo modprobe -r ${module} ;
        if [ $(sudo rmmod ${module}  | grep ERROR  |wc -l) -eq 0 ] ; then
            echo "removed ${module}"
        else
            echo "failed to remove ${module}"
        fi

    fi
}

reloadmodule ()
{
    local module=$1;
    removemoduleifloaded ${module};
    loadmoduleifnotloaded ${module};
}

complete -W "$(ibmod print)" reloadmodule ismoduleup loadmoduleifnotloaded removemoduleifloaded

mlx4start ()
{
    loadmoduleifnotloaded ib_core
    loadmoduleifnotloaded mlx4_ib
    loadmoduleifnotloaded mlx4_en
    loadmoduleifnotloaded ib_uverbs
}

mlx4stop ()
{
    removemoduleifloaded mlx4_ib
    removemoduleifloaded mlx4_en
    removemoduleifloaded mlx4_core
}

alias mlx4restart='mlx4stop; mlx4start'
alias mlx5restart='mlx5stop; mlx5start'

mlx5start ()
{
    loadmoduleifnotloaded ib_core
    loadmoduleifnotloaded mlx5_core
    loadmoduleifnotloaded mlx5_ib
    loadmoduleifnotloaded ib_uverbs
}


mlx5stop ()
{
    removemoduleifloaded mlx5_ib
    removemoduleifloaded mlx5_core
}
alias mlx5restart='mlx5stop; mlx5start'

mlxstart ()
{
    mlx4start;
    mlx5start;

    loadmoduleifnotloaded ib_core
    loadmoduleifnotloaded rdma_cm
    loadmoduleifnotloaded ib_cm
    loadmoduleifnotloaded ib_ucm
    loadmoduleifnotloaded ib_umad
    loadmoduleifnotloaded ib_uverbs
    loadmoduleifnotloaded rdma_cm
    loadmoduleifnotloaded ib_ucm
#     loadmoduleifnotloaded ib_iser
#     loadmoduleifnotloaded ib_isert
#     loadmoduleifnotloaded mlx5_fpga_tools
}

mlxstop ()
{
    removemoduleifloaded mlx5_fpga_tools

    mlx4stop
    mlx5stop

    removemoduleifloaded ib_iser
    removemoduleifloaded ib_isert
    removemoduleifloaded ib_srp
    removemoduleifloaded ib_srpt

    removemoduleifloaded rpcrdma
    removemoduleifloaded rdma_ucm
    removemoduleifloaded rdma_cm
    removemoduleifloaded ib_ucm
    removemoduleifloaded ib_ipoib

    removemoduleifloaded ib_cm
    removemoduleifloaded iw_cm
    removemoduleifloaded ib_umad
    removemoduleifloaded ib_uverbs
    removemoduleifloaded mlx5_core
    removemoduleifloaded ib_sa
    removemoduleifloaded ib_mad
    removemoduleifloaded ib_core
    removemoduleifloaded mlx_compat
    removemoduleifloaded mlxfw
}

alias mlxrestart='mlxstop ; mlxstart'

rxe ()        { sudo rxe_cfg ;      }
rxestart ()
{
    [ $(lsmod |grep mlx5_ib | wc -l ) -ne 0  ] && ( set -x ; sudo rmmod mlx5_ib);
    [ $(lsmod |grep mlx4_ib | wc -l ) -ne 0 ] &&  ( set -x ; sudo rmmod mlx4_ib);
    ( set -x ; sudo rxe_cfg start);
}
rxestop ()
{
    ( set -x ; sudo rxe_cfg stop);
}
rxerestart ()
{
    if [ $(lsmod | grep rdma_rxe | wc -l ) -ne 0 ] ; then
        rxestop ;
    fi
    rxestart;
}

iserstart ()
{
    sudo modprobe ib_iser
    sudo modprobe ib_isert debug_level=3
}

alias isertargetstart='sudo modprobe ib_isert'
alias iserinitiatorstart='sudo modprobe ib_iser'
# alias isertargetstart='sudo insmod /lib/modules/$(uname -r)/kernel/drivers/infiniband/ulp/isert/ib_isert.ko debug_level=3 ; sleep 1 ; sudo rmmod ib_iser'
# alias iserinitiatorstart='sudo insmod /lib/modules/$(uname -r)/kernel/drivers/infiniband/ulp/iser/ib_iser.ko debug_level=3 ; sleep 1 ; sudo rmmod ib_isert'
alias iserstop='sudo modprobe -r ib_isert ib_iser'

mkrxelib ()
{
    local ans;
    echo "Did you install kernel headers ?";
    echo "---> make headers_install INSTALL_HDR_PATH=/usr"

    read -p "[N/y]: " ans;

    if [ "$ans" != "y" ] ; then
        return;
    fi

    \make clean
    ./configure --libdir=/usr/lib64/ --prefix=
    make
    sudo make install
}

mkupstreamlib1sttime ()
{
    \make clean 2>/dev/null;
    ./autogen.sh
    ./configure --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib64 CFLAGS="-g -O0"
    make CFLAGS="-g -O0" AM_DEFAULT_VERBOSITY=1
    # sudo make install
}

alias mkupstreamlib='make CFLAGS="-g -O0" AM_DEFAULT_VERBOSITY=1'
alias mkupstreamlibagain='find -name "*.[c,h]" -exec touch {} \; ; mkupstreamlib'

alias rdmacoreversion='grep Version redhat/rdma-core.spec'
# alias mkrdmacore='\make -C build -j ${ncoresformake} -s 1>/dev/null'
rdmacorebuild ()
{
    local target=$1
    complete -W "$(make -C build help |awk '{print $2}')" rdmacorebuild
    if [ -z ${target} ] ; then 
        make -C build $target -j ${ncoresformake} -s 1>/dev/null 
    else
        make -C build $target -j ${ncoresformake}  -s
    fi

}
alias rdmacorebuildagain='find libibverbs providers -name "*.c" -exec touch {} \; ;  make -C build -j ${ncoresformake} -s 1>/dev/null'
alias rdmacorebuild1sttime='rdma-core_build.sh 1>/dev/null'
alias rdmacoreinstall='sudo make -C build install > /dev/null'
alias rdmacorebuildibverbs='\make -C build ibverbs -j ${ncoresformake} -s 1>/dev/null'
alias rdmacorebuildmlx4='\make -C build mlx4 -j ${ncoresformake} -s 1>/dev/null'
alias rdmacorebuildmlx5='\make -C build mlx5 -j ${ncoresformake} -s 1>/dev/null'
alias rdmacorebuildrcping='\make -C build ibv_rc_pingpong -j ${ncoresformake} -s 1>/dev/null'
rdmacorebuildapps ()
{
    \make -C build ibv_rc_pingpong -j ${ncoresformake} -s;
#   make -C build ibv_ud_pingpong -j ${ncoresformake} -s;
#   make -C build ibv_uc_pingpong -j ${ncoresformake} -s;
#   make -C build ibv_srq_pingpong -j ${ncoresformake} -s;
#   make -C build ibv_xsrq_pingpong -j ${ncoresformake} -s;
}

alias ofedinstallupstream='sudo build=latest-upstream /mswg/release/ofed/ofed_install --all --force'
ofedinstallupstreamlib ()
{
    echo "sudo build=ofed-upstream_last_stable /mswg/release/ofed/ofed_install --all --force --disable-kmp --without-valgrind";
    sudo build=ofed-upstream_last_stable /mswg/release/ofed/ofed_install --all --force --disable-kmp --without-valgrind
}

ofeduninstall ()
{
    are_you_sure_default_no;
    [ $? -eq 0 ] && return;
    sudo mft_uninstall.sh --force; 
    sudo ofed_uninstall.sh --force;
}

ofedlistversions ()
{
    local ver=$1;
    local tmpfile=/tmp/ofedversionlist.txt; 
    if [ -z $ver ] ; then 
        find /.autodirect/mswg/release/MLNX_OFED/ -maxdepth 1  -name "*MLNX_OFED_LINUX*" -type d -printf "%h %f\n";
    else
        find /.autodirect/mswg/release/MLNX_OFED/ -maxdepth 1  -name "*MLNX_OFED_LINUX*" -type d -printf "%h %f\n" | grep $ver  | tee ${tmpfile};
        complete -W "$(cat ${tmpfile})" ofedinstallversion;
    fi

}

ofedlistinternalversions ()
{
    local version=${1:-4.7};
    find /mswg/release/ofed/ -maxdepth 1 -type d  -name "*OFED-internal-${version}*"
}

ofed_list_os=( "rhel7.0")
ofed_list_os+=( "rhel7.1" )
ofed_list_os+=( "rhel7.2" )
ofed_list_os+=( "rhel7.3" )
ofed_list_os+=( "rhel7.4" )
ofed_list_os+=( "rhel7.5" )
ofed_list_os+=( "rhel7.6" )
ofed_list_os+=( "fc27" )
ofed_list_os+=( "fc29" )

complete -W "$( echo ${ofed_list_os[@]} x86_64 )" ofedlistversionforos

ofedlistversionforos ()
{
    local os=${1:-rhel7.0};
    local arch=${2:-x86_64};
    local ver=${3:-4.7};

    for i in $(ls -t -d /.autodirect/mswg/release/MLNX_OFED/MLNX_OFED_LINUX-${ver}* ) ; do 
#   for i in $(find /.autodirect/mswg/release/MLNX_OFED/ -maxdepth 1 -type d -name "*MLNX_OFED_LINUX-*" ) ; do 
        if [ $(ls -l $i | grep ${os} | wc -l ) -gt 0 ] ; then 
            sudo find ${i} -maxdepth 1 -type d -name "*${os}*${arch}*" -printf "${i}\n\t|--%f\n";
# ls -l $i | grep ${os} | grep ^d;
#             echo $i;
#             ls -l $i | grep ${os} | grep ^d  | while read d ; do 
#                 echo "|--$(basename $d)";
#             done 
            continue; 
        fi
    done; 
}

complete -W "4.6 4.7 rhel" ofedlistosforversion;
ofedlistosforversion ()
{
    local ver=${1:-4.7};
    local os=${2:-rhel};
    echo "OS list for ofed /.autodirect/mswg/release/MLNX_OFED/MLNX_OFED_LINUX-${ver}";
#   ls -t -d /.autodirect/mswg/release/MLNX_OFED/MLNX_OFED_LINUX-${ver}*/ | xargs -n 1 basename | sed -e 's/.*MLNX_OFED_LINUX-//g' | grep ".*iso$";
    ls -t -d /.autodirect/mswg/release/MLNX_OFED/MLNX_OFED_LINUX-${ver}*/ | while read v ; do 
#       basename $v 
        ls $v | grep ".*${os}.*iso$";
    done |less
   
}

# ofedbuildversion ()
# {
#     local version=${1};
#     if [ -z ${version} ] ; then
#         echo "missing version, use ofedlistversions to get your version" ;
#         return ;
#     fi;
#     echo "sudo build=${version} /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install --add-kernel-support"
# }

ofedinstallversion ()
{
    local ans;
    local rebuild_drivers=
    local user_space_libs=
    local version=${1};

    if [ -z ${version} ] ; then echo -e "missing version, use \"ofedlistversions\"" ; return ; fi;
    echo "about to install ofed ${version} for your $(cat /etc/redhat-release) and the kernel that comes with it";

    read -p "Do you need mellanox's drivers rebuilt ? [y/N]" ans;
    if [ "$ans" == "y" ] ; then
        rebuild_drivers="--add-kernel-support";
    fi

    user_space_libs="--upstream-libs --dpdk --with-opensm";
    read -p "Do you need rdma-core user space ? [Y/n]" ans;
    if [ "$ans" == "n" ] ; then
        user_space_libs="";
    fi

    echo "sudo build=${version} /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install ${rebuild_drivers} ${user_space_libs}";
    read -p "continue [y/N]: " ans;
    if [ "$ans" == "y" ] ; then
        sudo build=${version} /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install ${rebuild_drivers} ${user_space_libs};
    fi
}

#
# build user space libs and kernel modules
# of a specified ofed version
# and then install them
#
ofedbuildandinstallinternalversion ()
{
    local version=${1};
    local install_source_path=/mswg/release/ofed/OFED-internal-${version}/;
    local install_dest_path=/tmp/OFED-internal-${version}/;
    if [ -z ${version} ] ; then echo -e "missing version, use \"ofedlistversions\"" ; return ; fi;

    if ! [ -d ${install_source_path} ] ; then
        echo "There is NO !! : ${install_source_path}";
        return;
    fi;

    if [ -d ${install_dest_path} ] ; then
        echo "dest path already exists: ${install_dest_path}";
        echo "you must remove it to proceed";
        return;
    fi;

    /usr/bin/cp -a -v ${install_source_path} /tmp/;
    cd ${install_dest_path};
    echo "Enter root password to proceed with installation";
    su -c "./install.pl --all";

}

ofedkernelversion ()
{
    awk '/KVERSION/{print $0}' configure.mk.kernel;
}

ofedfindindexforpackage ()
{
    local pkg=$1;
    if [ -z ${pkg} ] ; then echo "ofedfindindexforpackage <pkg>" ; return ; fi
    ofed_info |grep -m2 -B2 -A3 ${pkg} | sort -u | grep "${pkg}\|commit"
#     ofed_info |grep -m2  -A1 ${pkg}
}

ofedquerybuildidforversion ()
{
    local ver=${1};
    [ -z $ver ] && return;
    less /mswg/release/ofed/OFED-internal-${ver}/BUILD_ID;
    echo /mswg/release/ofed/OFED-internal-${ver}/;

}

alias ofedfindindexforofakernel='ofedfindindexforpackage ofa_kernel:'
alias ofedfindindexforlibmlx5='ofedfindindexforpackage libmlx5:'
alias ofedfindindexforlibmlx4='ofedfindindexforpackage libmlx4:'
alias ofedfindindexforlibibverbs='ofedfindindexforpackage libibverbs'
alias ofedfindindexforrdma-core='ofedfindindexforpackage rdma-core'

ofedkernelinstall ()
{
    local ibcore_install_path=$(/sbin/modinfo ib_core|grep "filename:" | sed 's/.*filename://g' |sed 's/\ //g');
    local mlx5ib_install_path=$(/sbin/modinfo mlx5_ib|grep "filename:" | sed 's/.*filename://g' |sed 's/\ //g');
    local dst=${1:-"extra/mlnx-ofa_kernel"};
    local installed_ibcore="/lib/modules/$(uname -r)/${dst}/drivers/infiniband/core/ib_core.ko"

    echo "About to install ofa-kernel to /lib/modules/$(uname -r)/$dst";

    if ! [ "${installed_ibcore}" = "${ibcore_install_path}" ] ; then 
        echo "Pay attention that ofed installed kernel drivers to a different path";
        echo -e "\t${ibcore_install_path}";
        echo -e "\t${mlx5ib_install_path}";
    fi

    echo "sudo make install INSTALL_MOD_DIR=${dst}";
    are_you_sure_default_no;
    [ $? -eq 0 ] && return;
    sudo make install INSTALL_MOD_DIR=${dst};
}

complete -W "updates kernel extra extra/mlnx-ofa_kernel" ofedkernelinstall

ofedfindpathofversion () 
{
    local version=$1;
    if [ -z ${version} ] ; then
        if [ $( ofedversion | grep internal | wc -l ) -gt 0 ] ; then 
            version=$(ofedversion | awk -F '-' '{ print $3 "-" $4}');
        else
            version=$(ofedversion | awk -F '-' '{ print $2 "-" $3}');
        fi
    fi
    echo -e "find /.autodirect/mswg/release/MLNX_OFED/ -maxdepth 1 -type d -name \"*${version}*\"";
    echo "---------------------------"
    find /.autodirect/mswg/release/MLNX_OFED/ -maxdepth 1 -type d -name "*${version}*" 
}

ofedmkbackport ()
{
    local configure_options=;
    local possible_backport_branch=;
    configure_options=$(/etc/infiniband/info |grep Configure\ options | sed 's/.*://g');
    
    
    # make sure there is no other backport branch
    possible_backport_branch=$(git b | grep ^[[:space:]]*backport | awk '{print $1}');
    if [ -n "${possible_backport_branch}"  ] ; then 
        echo "You 1st need to delete!!! ${possible_backport_branch}!!!";
        return;
    fi

    # make sure that ofed kernel links were created
    if  [ ! -L configure ] || [ ! -L makefile ] || [ ! -L Makefile ]  ; then
        echo "You 1st need to create ofa links - use ofedmklinks";
        return;
    fi

    echo "./configure -j ${ncoresformake} ${configure_options}"
    read -p "Continue [Y/n]: " ans;
    if [ "$ans" == "n" ] ; then
        return;
    fi
    echo             "================================================";
    if [ -x /usr/bin/time ] ; then
        /usr/bin/time -f "=======================\n--->elapsed time %E" ./configure -j ${ncoresformake} ${configure_options}
    else
        ./configure -j ${ncoresformake} ${configure_options}
    fi
    echo             "=======================";

    make distclean;
}

# if [ -d ~yonatanc/devel ] ; then
# cddevel () {
#     cd ~yonatanc/devel/         ; [ -n "$1" ] && cd $1;
# }
# complete -W "$(find ~yonatanc/devel/ -maxdepth 1 -type d  -exec basename {} \;     )" cddevel

# cdupstream () {
#     cd ~yonatanc/devel/upstream ; [ -n "$1" ] && cd $1;
# }
# complete -W "$(find ~yonatanc/devel/upstream -maxdepth 1 -type d  -exec basename {} \;     )" cdupstream
source ${yonienv}/upstream_complete_dir.sh

source ${yonienv}/ofed_complete_dir.sh
# cdofed  () {
#     cd ~yonatanc/devel/ofed     ; [ -n "$1" ] && cd $1;
# }
# complete -W "$(find ~yonatanc/devel/ofed -maxdepth 1 -type d  -exec basename {} \;     )" cdofed
# fi

alias cdmarsdirecttest='cd /tmp/mars_tests/SW_NET_VERIFICATION-directtest_db.xml/directtests/'

mkcoverletterusage ()
{
    echo "give num-of-commits and version. e.g. ";
    echo "create 3 patches and plave V12 in the subject";
    echo "mkcoverletterkernel 3 12"
}

mkcoverletter ()
{
    local index_range=${1:-~1};
    local version=${2:-0};
    local subject=${3:-rdma-next};

    if ! [ -d coverletter ] ; then mkdir coverletter ; fi;
    echo "~/devel/upstream/tools/scripts/git-upstream format-patch -p coverletter -b ${subject} -v ${version} -- HEAD~${index_range};";
    ~/devel/upstream/tools/scripts/git-upstream format-patch -p coverletter -b ${subject} -v ${version} -- HEAD~${index_range};
}

mkcoverletterrdmacore ()
{ 
    if [ $# -ne 2 ] ; then mkcoverletterusage ; return ; fi;
    mkcoverletter $1 $2 rdma-core;
}
mkcoverletterrdma-next ()
{
    if [ $# -ne 2 ] ; then mkcoverletterusage ; return ; fi;
    mkcoverletter $1 $2 rdma-next; 
}
mkcoverletternet-next ()  
{
    if [ $# -ne 2 ] ; then mkcoverletterusage ; return ; fi;
    mkcoverletter $1 $2 net-next;  
}

kernelbuildmlx5ib ()
{
    local again="${1}";
    echo "make ${again} -j${ncoresformake} M=drivers/infiniband/hw/mlx5/";
    \make ${again} -j${ncoresformake} M=drivers/infiniband/hw/mlx5/;
}
kernelbuildmlx5core ()
{
    local again="${1}";
    echo  "make ${again} -j${ncoresformake} M=drivers/net/ethernet/mellanox/mlx5/core/";
    \make ${again} -j${ncoresformake} M=drivers/net/ethernet/mellanox/mlx5/core/;
}

kernelbuildmlx4ib ()
{
    echo "make -j${ncoresformake} M=drivers/infiniband/hw/mlx4/";
    \make -j${ncoresformake} M=drivers/infiniband/hw/mlx4/;
}
kernelbuildmlx4core ()
{
   echo  "make -j${ncoresformake} M=drivers/net/ethernet/mellanox/mlx4/core/"
   \make -j${ncoresformake} M=drivers/net/ethernet/mellanox/mlx4/;
}

alias kernelbuildmlx4='kernelbuildmlx4ib; kernelbuildmlx4core'
alias kernelbuildmlx5='kernelbuildmlx5ib; kernelbuildmlx5core'
alias kernelbuildmlx5again='kernelbuildmlx5ib -B; kernelbuildmlx5core -B'
alias kernelbuildmlx='kernelbuildmlx5; kernelbuildmlx4'

alias touchmlx5ib='find drivers/infiniband/hw/mlx5/ -name "*.c" -exec touch {} \;'
alias touchmlx5core='find drivers/net/ethernet/mellanox/mlx5/ -name "*.c" -exec touch {} \;'
alias touchmlx5='touchmlx5ib ; touchmlx5core'

alias clipboard='cat ~/share/clipboard.txt'

tagmeofakernel ()
{
    echo "#!/bin/bash" > tagme.sh;
    echo 'source ${yonienv}/bashrc_tags.sh' >> tagme.sh;
    cat ${yonienv}/bin/tagmeofakernel.sh >> tagme.sh
    cat  ${yonienv}/bin/tagme.sh >> tagme.sh ;
    chmod +x tagme.sh;
    ./tagme.sh 1;
}
tagmeupstreamkernel ()
{
    echo "#!/bin/bash" > tagme.sh;
    echo 'source ${yonienv}/bashrc_tags.sh' >> tagme.sh;
    cat ${yonienv}/bin/tagmeupstreamkernel.sh >> tagme.sh
    cat  ${yonienv}/bin/tagme.sh >> tagme.sh ;
    chmod +x tagme.sh;
    ./tagme.sh 1;
}

tagmerdmacore () 
{
    echo "#!/bin/bash" > tagme.sh;
    echo 'source ${yonienv}/bashrc_tags.sh' >> tagme.sh;
    cat ${yonienv}/bin/tagmerdmacore.sh >> tagme.sh
    cat  ${yonienv}/bin/tagme.sh >> tagme.sh ;
    chmod +x tagme.sh;
}

tagmeofedlibs ()
{
    echo "#!/bin/bash" > tagme.sh;
    echo 'source ${yonienv}/bashrc_tags.sh' >> tagme.sh;
    cat ${yonienv}/bin/tagmeofedlibs.sh >> tagme.sh
    cat  ${yonienv}/bin/tagme.sh >> tagme.sh ;
    chmod +x tagme.sh;
}

md2man ()
{
#   convert markdown format to man with pandoc tool
    local mdfile=$1;
    local manpage=$(basename ${mdfile} );
    manpage=$(echo $manpage | sed 's/.md//g');
    mkdir -p tmp;
    pandoc -s -t man ${mdfile}  -o tmp/${manpage} ; man tmp/${manpage}
}

opensmmlx ()
{
    local device=${1};
    local guid;

    if ! [ -e /usr/sbin/ibstat ] ; then
        echo "missing ibstat. install infiniband-diags and try again";
        return;
    fi;

    guid=$(/usr/sbin/ibstat -d ${device} | awk '/Port GUID/{print $3}');

    if [ -z "${device}" ] ; then 
        pgrep -l opensm;
        return;         
    fi   

    echo "sudo opensm -g ${guid}"
    sudo /usr/sbin/opensm -B -g ${guid} ;
    sleep 3
    ibv_devinfo -d ${device} | grep state;
    ibv_devinfo -d ${device} | grep "state\|link_layer";
}
alias opensmmlx5_0='opensmmlx mlx5_0'
alias opensmmlx5_1='opensmmlx mlx5_1'
alias opensmmlx4_0='opensmmlx mlx4_0'
alias opensmmlx4_1='opensmmlx mlx4_1'


syndrome_to_english () 
{ 
    if [ $# != 1 ]; then
        echo "usage: syndrome_to_english <syndrome>";
        echo "e.g. syndrome_to_english 0x429d76";
        return;
    fi;
    cd /swgwork/noaos/dev/golan_fw/;
    git grep -i $1 src;
    cd - &>/dev/null


    # more possible places to look for syndroms
    # /mswg/release/fw-4119/ 
    # /mswg/release/fw-4119/fw-4119-rel-16_25_8016/../etc/syndrome_list.log 
}


mlx ()
{
    if [ -x /usr/sbin/ibstat ] ; then
        echo "===================================="
        echo "        ibstat                      "
        echo "       --------                     "
        /usr/sbin/ibstat | grep "CA\|Number of ports";
        echo "===================================="
    fi
    if [ -x /usr/bin/ibv_devinfo ] ; then
        echo "        ibv_devinfo                 "
        echo "       -------------                "
        ibv_devinfo | grep "state\|hca_id\|\<port\>\|phys_port_cnt\|link_layer" |
        column -t | sed -e 's/hca_id:/\n/' \
            -e 's/^phys_port/\ \ phys_port/' \
            -e 's/^port/\ \ port/' \
            -e 's/^state/\ \ state/' \
            -e 's/^link_layer/\ \ link_layer/';
        echo "===================================="
    fi;

    if [ -x /usr/bin/ibdev2netdev ] ; then
        echo "   ibdev2netdev                     "
        echo "  --------------                    "
        ibdev2netdev;
        echo "===================================="
    fi;


#     mftstatus;
}

listdevelservers ()
{
    # server locations are listed in the windows app : disconet
    # only LAB IT members have access to it

    local servername=${1};
    if [ -z "${servername}" ] ; then
        cat /.autodirect/LIT/SCRIPTS/DHCPD/list;
    else
        cat /.autodirect/LIT/SCRIPTS/DHCPD/list |grep -i ${servername};
    fi
}

listbuildservers () { less /auto/integration/builders.txt ; }

remotereboot ()
{
    host="${1}";
#   /swgwork/yogevg/tools/virtualization/special_rreboot.py -H clx-cratus-[11-15]
    /swgwork/yogevg/tools/virtualization/special_rreboot.py -H ${host}
}

ofedhelp ()
{
    echo "ofedmkmetadata - create Metadata"
    echo "ofeddeletebackport - delete backport branch"
    echo "ofedbuildidforversion - show git indexs used for a specific ofed version"
}



###############
# get_fw_path 
################
#usage: get_fw_path X.Y.Z (e.g 16.26.0260) 
fw_get_path() {
    local fw_ver=`echo $1 | sed  's/\./ /g'`
    local major=`echo $fw_ver | awk {'print $1'}`
    local minor=`echo $fw_ver | awk {'print $2'}`
    local subminor=`echo $fw_ver | awk {'print $3'}`
    local version="${major}_${minor}_${subminor}"
    
    project_id=0
    project=""
    case "$major" in
        10)	project_id=4113 ; project="golan"   ;;
        12)	project_id=4115 ; project="shomron" ;;
        14)	project_id=4117 ; project="dotan"   ;;
        16)	project_id=4119 ; project="galil"   ;;
        18)	project_id=41682 ; project="bluefield"   ;;
        20)	project_id=4123 ; project="negev"   ;;
        22)	project_id=4125 ; project="arava"   ;;
    esac
    
    echo "/mswg/release/host_fw/fw-${project_id}/fw-${project_id}-rel-${version}/"
    echo "/mswg/release/host_fw/fw-${project_id}/fw-${project_id}-rel-${version}/../etc/${project}_basic_debug.sh"
    echo
}

alias cdmlxkernelsources='cd /mswg/work/kernel.org/x86_64'
