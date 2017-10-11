#!/bin/bash


backup_dest=${1:-/media/backup};
backup_src=${2:-${HOME}}; 
backup_exclude="--exclude=*.cache*"
backup_exclude+=" --exclude=*.mozilla*"

verifyBackupDest ()
{
    if ! [ -d ${backup_dest} ] ; then 
        echo "mkdir -p ${backup_dest}";
        echo "Give root "
        su -c "mkdir -p ${backup_dest}";
    fi        

    if [ `mount | grep $(basename ${backup_dest}) | wc -l ` -eq 0 ] ; then 

        echo -n -e "mounting ${backup_dest}\nroot "
        su -c "mount /dev/sdb1 ${backup_dest}" 
    fi


}

startBackup ()
{ 
    echo -e "=========> rsync -azv --progress --exclude=${backup_exclude} ${backup_src} ${backup_dest}"
#     if ! [ -d ${backup_dest}${backup_src} ] ; then
#         mkdir -p ${backup_dest}${backup_src}
#     fi
#     rsync -azv --progress ${backup_src} ${backup_dest}${backup_src}
    rsync -azv --progress ${backup_exclude} ${backup_src} ${backup_dest}


    # backup_dest=${1:-kuser@10.248.30.158};
    # backup_src=${1:-/home/kuser/backup}; 
    # 
    # echo -e "=========> rsync -azv --progress /home/yonic/docs/ ${backup_dest}:${backup_src}/dana/docs/"
    # rsync -azv --progress /home/yonic/docs/        ${backup_dest}:${backup_src}/dana/docs/
    # 
    # echo -e "=========> rsync -azv --progress /home/yonic/work/tasks/ ${backup_dest}:${backup_src}/dana/work/tasks/"
    # rsync -azv --progress /home/yonic/work/tasks/  ${backup_dest}:${backup_src}/dana/work/tasks/
    # 
    # echo -e "=========> rsync -azv --progress /home/yonic/codeWriting/ ${backup_dest}:${backup_src}/dana/codeWriting/"
    # rsync -azv --progress /home/yonic/codeWriting/ ${backup_dest}:${backup_src}/dana/codeWriting/
    # 
    # echo -e "=========> rsync -azv --progress /home/yonic/.vim ${backup_dest}:${backup_src}/dana/"
    # rsync -azv --progress /home/yonic/.vim         ${backup_dest}:${backup_src}/dana/
    # 
    # echo -e "=========> rsync -azv --progress /home/yonic/bin ${backup_dest}:${backup_src}/dana/"
    # rsync -azv --progress /home/yonic/bin          ${backup_dest}:${backup_src}/dana/
    # rsync -azv --progress /home/yonic/.vimrc       ${backup_dest}:${backup_src}/dana/
    # rsync -azv --progress /home/yonic/.gvimrc      ${backup_dest}:${backup_src}/dana/
    # rsync -azv --progress /home/yonic/.bashrc*     ${backup_dest}:${backup_src}/dana/
    # rsync -azv --progress /home/yonic/.dir_colors  ${backup_dest}:${backup_src}/dana/
}

hello () 
{
    echo "we just backed up your stuff to ${backup_dest}";
    echo "to restore : use rsync replacing <src> and <dst>";
    echo "rsync -avz --progress ${backup_dest} ${backup_src}";
}

main ()
{
    verifyBackupDest
    startBackup; 
    hello
}

main "$@"
