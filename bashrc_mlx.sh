#!/bin/bash

########################################################################
# mellanox stuff
########################################################################


alias editbashmlx='g ${yonienv}/bashrc_mlx.sh'

alias 8='ssh     r-ole08'
alias 9='ssh     r-ole09'
alias 10='ssh    r-ole10'
alias 11='ssh    r-ole11'

alias 145='ssh   dev-l-vrt-145'
alias 145root='ssh   root@dev-l-vrt-145'
alias 145ping='ping   dev-l-vrt-145'

alias 1455='ssh  dev-l-vrt-145-005'
alias 1455root='ssh  root@dev-l-vrt-145-005'
alias 1455ping='ping  dev-l-vrt-145-005'

alias 1456='ssh  dev-l-vrt-145-006'
alias 1456root='ssh  root@dev-l-vrt-145-006'
alias 1456ping='ping  dev-l-vrt-145-006'

alias 1457='ssh  dev-l-vrt-145-007'
alias 1457root='ssh  root@dev-l-vrt-145-007'
alias 1457ping='ping  dev-l-vrt-145-007'

alias 1458='ssh  dev-l-vrt-145-008'
alias 1458root='ssh  root@dev-l-vrt-145-008'
alias 1458ping='ping  dev-l-vrt-145-008'

alias 1459='ssh  dev-l-vrt-145-009'
alias 1459root='ssh  root@dev-l-vrt-145-009'
alias 1459ping='ping  dev-l-vrt-145-009'

alias 146='ssh   dev-l-vrt-146'
alias 146root='ssh   root@dev-l-vrt-146'
alias 146ping='ping  dev-l-vrt-146'

alias 1465='ssh  dev-l-vrt-146-005'
alias 1465root='ssh  root@dev-l-vrt-146-005'
alias 1465ping='ping  dev-l-vrt-146-005'

alias 1466='ssh  dev-l-vrt-146-006'
alias 1466root='ssh  root@dev-l-vrt-146-006'
alias 1466ping='ping  dev-l-vrt-146-006'

alias 1467='ssh  dev-l-vrt-146-007'
alias 1467root='ssh  root@dev-l-vrt-146-007'
alias 1467ping='ping  dev-l-vrt-146-007'

alias 1468='ssh  dev-l-vrt-146-008'
alias 1468root='ssh  root@dev-l-vrt-146-008'
alias 1468ping='ping  dev-l-vrt-146-008'

alias 149='ssh  dev-l-vrt-149'
alias 149root='ssh  root@dev-l-vrt-149'
alias 149ping='ping  dev-l-vrt-149'

# stm server to run regression
alias stm88ping='ping mtl-stm-88'
alias stm88root='ssh root@mtl-stm-88'
alias stm88='ssh mtl-stm-88'

alias stmaz88='ssh mtl-stm-az-088'
alias stmaz88root='ssh root@mtl-stm-az-088'
alias stmaz88ping='ping mtl-stm-az-088'

# performance setup
alias 94='ssh  dev-l-vrt-094'
alias 97='ssh  dev-l-vrt-097'

# rxe regression setup
alias 5180='ssh reg-l-vrt-5180'
alias 5181='ssh reg-l-vrt-5181'
alias 51806='ssh reg-l-vrt-5180-006'
alias 51816='ssh reg-l-vrt-5181-006'

# guy levi setup
alias 212='ssh dev-l-vrt-212'
alias 213='ssh dev-l-vrt-213'

# parav
alias parav='ssh sw-mtx-036'




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

alias mkgerrithook='gitdir=$(git rev-parse --git-dir); scp -p -P 29418 yonatanc@l-gerrit.mtl.labs.mlnx:hooks/commit-msg ${gitdir}/hooks/'
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
        complete -W "$(git remote)" gitpushtogerrit
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
    read -p "are you sure ? [y/N] : " answer;
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
        complete -W "$(cat .gitpush.log | cat .gitpush.log |sed -e 's/.*for\///' -e 's/\//\n/' |sort -u |xargs)"  gitpushtogerrit
    fi
}
gitpushtogerritcomplete;

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
    echo "mellanox ofed.4 kernel       : ${prefix}/mlnx_ofed/mlnx-ofa_kernel-4.0";
    echo "mellanox ofed.4 libibverbs   : ${prefix}/mlnx_ofed_2_0/libibverbs";
    echo "mellanox ofed.4 libmlx4      : ${prefix}/mlnx_ofed_2_0/libmlx4";
    echo "mellanox ofed.4 libmlx5      : ${prefix}/connect-ib/libmlx5";

    echo;
    echo "mellanox regression vrtsdk      : ${prefix}/vrtsdk";
    echo "mellanox regression network     : ${prefix}/Linux_drivers_verification/networking";
    echo "mellanox regression core        : ${prefix}/Linux_drivers_verification/core";
    echo "mellanox regression directtests : ${prefix}/Linux_drivers_verification/directtests";

    echo;
    echo "mellanox github/devx            : https://github.com/Mellanox/devx.git";
}


ibmod ()
{
# lsmod |grep "^ib_\|^mlx\|^rdma" | awk '{print $1" "$3}' | column -t |grep "ib\|mlx\|rdma";
    local modules_path=;
    local modules_base_path=;
    local module_grep=${1};

    if [ -d /usr/lib/modules/$(uname -r) ] ; then
        modules_base_path="/usr/lib/modules/$(uname -r)";
    elif  [ -d /lib/modules/$(uname -r) ]  ; then
        modules_base_path="/lib/modules/$(uname -r)";
    else
        echo "no /lib/modules or /usr/lib/modules/ found";
    fi

    modules_path="${modules_base_path}/kernel/drivers/infiniband"
    modules_path+=" ${modules_base_path}/kernel/drivers/net/ethernet/mellanox"

    # ofed libs are usually under extra
    if [ -d ${modules_base_path}/extra ] ; then
        modules_path+=" ${modules_base_path}/extra";
    fi

    find ${modules_path}  -type f -exec basename {} \; | sed -e 's/\.ko$//g' -e 's/\.ko\.xz$//g' | sort -u |
        while read m ; do
            lsmod | awk '{print $1" "$3" " }' | \grep $m ;
#             lsmod | cut -d' ' -f1  | \grep $m | \grep "ib\|mlx\|rxe";
    done | column -t | if [ -n "${module_grep}" ] ; then
                          tee | sort -h -k2 | grep ${module_grep} ;
                       else
                           tee | sort -h -k2 ;
                       fi
}
alias nox='lspci | grep nox'
alias cdregression='cd ~/devel/regression'
alias cdregressioncore='cd ~/devel/regression/core'
alias cdregressionnet='cd ~/devel/regression/networking'
alias cdregressionrxe='cd ~/devel/rxe_regression'
alias cdshare="cd ${HOME}/share/"


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

[ -e ${yonienv}/cdlinux.bkp ] && source ${yonienv}/cdlinux.bkp
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
        echo "there is no /images, use mkkernelmountdir to create";
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
alias mkkernelmountdir='sudo install -o yonatanc -g mtl -d /images/'

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
}

ofedmklinks ()
{
    ln -snf ofed_scripts/Makefile Makefile
    ln -snf ofed_scripts/makefile makefile
    ln -snf ofed_scripts/configure configure
}

alias ofedapplybackports='./configure -j ${ncoresformake} --kernel-version 2.6.16 --skip-autoconf'
alias ofedconfigurewithcore='./configure -j ${ncoresformake} --with-core-mod'
alias ofedconfigurewithrxe='./configure -j ${ncoresformake} --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx4-mod --with-mlx4_en-mod --with-mlx5-mod --with-rxe-mod'

ofedconfigureforkernel ()
{
    local kernel_version=$1;
    local kernel_headers=/mswg2/work/kernel.org/x86_64

    if ! [ -d ${kernel_headers}/linux-${} ]  ; then
        ./configure -j {ncoresformake}  --with-core-mod --kernel-version=${kernel_version} --kernel-sources=${kernel_headers}/linux-${kernel_version}
    fi
}

ofedorigindir ()
{
    cd /.autodirect/mswg/release/MLNX_OFED/$(ofed_info -s | sed 's/://g')
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
    echo -e "\033[1;33;7mmake sure that you sudo mst start \033[0m"
    sudo mst status -vv
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
}

mftgetlinktype ()
{
    for d in /dev/mst/* ; do
        echo ${d};
        sudo mlxconfig -d ${d} q | \grep LINK_TYPE;
    done
}

_checkpatchcomplete ()
{
    ls *.patch | tr ' ' '\n';
    complete -W "$(ls *.patch)" checkpatch;
    return;
}

checkpatchkernel ()
{
    if  [ $# -eq 0 ] ; then _checkpatchcomplete ; return ; fi
    ./scripts/checkpatch.pl --strict --ignore=GERRIT_CHANGE_ID $@
}

checkpatchuserpace ()
{
    if  [ $# -eq 0 ] ; then _checkpatchcomplete ; return ; fi
    ./scripts/checkpatch.pl --strict --ignore=GERRIT_CHANGE_ID,PREFER_KERNEL_TYPES $@
}

alias mkvmredhat74='/.autodirect/GLIT/SCRIPTS/AUTOINSTALL/VIRTUALIZATION/kvm_guest_builder -o linux -l RH_7.4_x86_64_virt_guest -c 16 -r 8192 -d 35'
alias mkvmls='sudo /.autodirect/GLIT/SCRIPTS/AUTOINSTALL/VIRTUALIZATION/kvm_guest_builder -o linux'
mkvmhelp()
{
    echo "su - ";
    echo -e "/.autodirect/GLIT/SCRIPTS/AUTOINSTALL/VIRTUALIZATION/kvm_guest_builder -o linux -l \033[1;31m<your choice of vm>\033[00m -c 16 -r 8192 -d 35";
}

findiblibs ()
{
#     ib_libs=(libmlx5-rdmav2.so libibacmp.so libibumad.so libibverbs.so)
#     ib_libs+=(libibcm.so libhns-rdmav2.so libcxgb3-rdmav2.so libcxgb4-rdmav2.so libi40iw-rdmav2.so)
#     ib_libs+=(librdmacm.so libnes-rdmav2.so libmlx4-rdmav2.so libmthca-rdmav2.so libmlx5.so)
#     ib_libs+=(libocrdma-rdmav2.so libhfi1verbs-rdmav2.so libipathverbs-rdmav2.so libqedr-rdmav2.so)
#     ib_libs+=(libvmw_pvrdma-rdmav2.so librxe-rdmav2.so librspreload.so libibacmp.so);

ib_libs=(libibverbs.so)
ib_libs+=(libmlx4.so)
ib_libs+=(libmlx4-rdmav*.so)
ib_libs+=(libmlx5.so)
ib_libs+=(librxe-rdmav*.so)
ib_libs+=(librxe-rdmav*.so)
ib_libs+=(libibumad.so)
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


    local ib_libs_search_path=(/usr/lib/ /usr/lib64/ /usr/local/lib/  /usr/local/lib64/)
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

    count=0;
    for i in ${ib_libs[@]} ; do
#         sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f -ls ${delete_app} 2>/dev/null
        if [ -z $lib ] ; then
            echo -e "\033[1;35m--- ${i} ----\033[0m"
            sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f  -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" ${delete_app} 2>/dev/null
        else
            sudo find ${ib_libs_search_path[@]} -name "${ib_libs[${count}]}*" -type f  -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" | grep ${lib} 2>/dev/null
        fi
        ((count++));
    done
}

findibapps ()
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

    if [ -n ${1} ] ; then
        if [ "${1}" == "-d" ] ; then
            read -p "delete ib apps [N/y]: " ans;

            if [ "$ans" != "y" ] ; then
                return;
            fi
            delete_app="-delete";
        fi
    fi

    count=0;
    for i in ${ib_apps[@]} ; do
        echo -e "\033[1;35m--- ${i} ----\033[0m"
#       sudo find ${ib_apps_search_path[@]} -name "${ib_apps[${count}]}" -type f -ls ${delete_app} 2>/dev/null
        sudo find ${ib_apps_search_path[@]} -name "${ib_apps[${count}]}" -type f -printf "%Ad/%Am/%AY %AH:%AM %h/%f\n" ${delete_app} 2>/dev/null
        ((count++));
    done
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
    if [ $(lsmod |grep ${module} | wc  -l ) -gt 0 ] ; then
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

ib4start ()
{
    loadmoduleifnotloaded ib_core
    loadmoduleifnotloaded mlx4_ib
    loadmoduleifnotloaded mlx4_en
    loadmoduleifnotloaded ib_uverbs
}

ib4stop ()
{
    removemoduleifloaded mlx4_ib
    removemoduleifloaded mlx4_en
    removemoduleifloaded mlx4_core
}

alias ib5restart='ib4stop; ib4start'

ib5start ()
{
    loadmoduleifnotloaded ib_core
    loadmoduleifnotloaded mlx5_core
    loadmoduleifnotloaded mlx5_ib
    loadmoduleifnotloaded ib_uverbs
}


ib5stop ()
{
    removemoduleifloaded mlx5_ib
    removemoduleifloaded mlx5_core
}
alias ib5restart='ib5stop; ib5start'

ibstart ()
{
    ib4start;
    ib5start;

    loadmoduleifnotloaded ib_core
    loadmoduleifnotloaded rdma_cm
    loadmoduleifnotloaded ib_cm
    loadmoduleifnotloaded ib_ucm
    loadmoduleifnotloaded ib_umad
    loadmoduleifnotloaded ib_uverbs
    loadmoduleifnotloaded rdma_cm
    loadmoduleifnotloaded ib_ucm
    loadmoduleifnotloaded ib_iser
    loadmoduleifnotloaded ib_isert
}

ibstop ()
{
    ib4stop
    ib5stop

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
    removemoduleifloaded ib_core
}

alias ibrestart='ibstop ; ibstart'

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
    \make clean
    ./autogen.sh
    ./configure --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib64 CFLAGS="-g -O0"
    make CFLAGS="-g -O0" AM_DEFAULT_VERBOSITY=1
    # sudo make install
}

alias mkupstreamlib='make CFLAGS="-g -O0" AM_DEFAULT_VERBOSITY=1'
alias mkupstreamlibagain='find -name "*.[c,h]" -exec touch {} \; ; mkupstreamlib'

alias rdmacoreversion='grep Version redhat/rdma-core.spec'
alias mkrdmacore='\make -C build -j ${ncoresformake} -s 1>/dev/null'
alias mkrdmacoreagain='find libibverbs providers -name "*.c" -exec touch {} \; ;  make -C build -j ${ncoresformake} -s 1>/dev/null'
alias mkrdmacore1sttime='rdma-core_build.sh 1>/dev/null'
alias mkrdmacoreinstall='sudo make -C build install > /dev/null'
alias mkrdmacoreibverbs='\make -C build ibverbs -j ${ncoresformake} -s 1>/dev/null'
alias mkrdmacoremlx4='\make -C build mlx4 -j ${ncoresformake} -s 1>/dev/null'
alias mkrdmacoremlx5='\make -C build mlx5 -j ${ncoresformake} -s 1>/dev/null'
alias mkrdmacorercping='\make -C build ibv_rc_pingpong -j ${ncoresformake} -s 1>/dev/null'
mkrdmacoreApps ()
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

ofedlistversions ()
{
    find /.autodirect/mswg/release/MLNX_OFED/ -maxdepth 1  -name "*MLNX_OFED_LINUX*" -type d -printf "%h %f\n";
}

ofedbuildversion ()
{
    local version=${1};
    if [ -z ${version} ] ; then
        echo "missing version, use ofedlistversions to get your version" ;
        return ;
    fi;
    echo "sudo build=${version} /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install --add-kernel-support"
}

ofedinstallversion ()
{
    local version=${1};
    if [ -z ${version} ] ; then echo "missing version" ; return ; fi;
    echo "about to install ofed ${version} for your $(cat /etc/redhat-release) and the kernel that comes with it"
    echo "sudo build=${version} /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install"
    read -p "continue [y/N]: " ans;
    if [ "$ans" == "y" ] ; then
        sudo build=${version} /.autodirect/mswg/release/MLNX_OFED/mlnx_ofed_install;
    fi
}

ofedfindindexforpackage ()
{
    local pkg=$1;
    if [ -z ${pkg} ] ; then echo "ofedfindindexforpackage <pkg>" ; return ; fi
    ofed_info |grep -m2  -A1 ${pkg} | sort -u | grep "${pkg}\|commit"
}

ofedmkbackport ()
{
    local configure_options=;
    configure_options=$(/etc/infiniband/info |grep Configure\ options | sed 's/.*://g');
    echo "./configure -j ${ncoresformake} ${configure_options}"
    read -p "continue [Y/n]: " ans;
    if [ "$ans" == "n" ] ; then
        return;
    fi
    ./configure -j ${ncoresformake} ${configure_options}
}

if [ -d ~yonatanc/devel ] ; then
cddevel () {
    cd ~yonatanc/devel/         ; [ -n "$1" ] && cd $1;
}
complete -W "$(find ~yonatanc/devel/ -maxdepth 1 -type d  -exec basename {} \;     )" cddevel
cdupstream () {
    cd ~yonatanc/devel/upstream ; [ -n "$1" ] && cd $1;
}
complete -W "$(find ~yonatanc/devel/upstream -maxdepth 1 -type d  -exec basename {} \;     )" cdupstream
cdofed  () {
    cd ~yonatanc/devel/ofed     ; [ -n "$1" ] && cd $1;
}
complete -W "$(find ~yonatanc/devel/ofed -maxdepth 1 -type d  -exec basename {} \;     )" cdofed
fi

mkcoverletterusage ()
{
    echo "give index range. e.g. HEAD~3"
}

mkcoverletterrdmacore ()
{ 
    if [ $# -eq 0 ] ; then mkcoverletterusage ; return ; fi;
    mkdir coverletter
    ~/devel/upstream/tools/scripts/git-upstream format-patch -p coverletter -b rdma-core -- $1
}

mkcoverletterkernel ()
{
    if [ $# -eq 0 ] ; then mkcoverletterusage ; return ; fi;
    mkdir coverletter
    ~/devel/upstream/tools/scripts/git-upstream format-patch -p coverletter -b rdma-next -- $1
}

mkkernelbuildinfiniband ()
{
    echo "make -j${ncoresformake} M=drivers/infiniband/";
    \make -j${ncoresformake} M=drivers/infiniband/;
}
 
mkkernelbuildmlx5ib ()
{
    echo "make -j${ncoresformake} M=drivers/infiniband/hw/mlx5/";
    \make -j${ncoresformake} M=drivers/infiniband/hw/mlx5/;
}
mkkernelbuildmlx5core ()
{
   echo  "make -j${ncoresformake} M=drivers/net/ethernet/mellanox/mlx5/core/"
   \make -j${ncoresformake} M=drivers/net/ethernet/mellanox/mlx5/core/;
}

alias mkkernelbuildmlx5='mkkernelbuildmlx5ib; mkkernelbuildmlx5core'

alias touchmlx5ib='find drivers/infiniband/hw/mlx5/ -name "*.c" -exec touch {} \;'
alias touchmlx5core='find drivers/net/ethernet/mellanox/mlx5/ -name "*.c" -exec touch {} \;'
alias touchmlx5='touchmlx5ib ; touchmlx5core'

alias clipboard='cat ~/share/clipboard.txt'

alias tagmeofakernel='cp ${yonienv}/bin/tagmeofakernel.sh .'
alias tagmeupstreamkernel='cp ${yonienv}/bin/tagmeupstreamkernel.sh .'
alias tagmerdmacore='cp ${yonienv}/bin/tagmerdmacore.sh .'
alias tagmeofedlibs='cp ${yonienv}/bin/tagmeofedlibs.sh .'
md2man ()
{
    local mdfile=$1;
    local manpage=$(basename ${mdfile} );
    manpage=$(echo $manpage | sed 's/.md//g');
    mkdir -p tmp;
    pandoc -s -t man ${mdfile}  -o tmp/${manpage} ; man tmp/${manpage}
}
