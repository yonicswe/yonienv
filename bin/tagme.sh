#!/bin/bash

includeTagdir=(./include/)
includeTagdir+=(./usr/include/rdma/)
includeTagdir+=(./drivers/infiniband/)
# includeTagdir+=(./drivers/infiniband/ulp/iser)
# includeTagdir+=(./drivers/infiniband/hw/mlx5/)
# includeTagdir+=(./drivers/infiniband/hw/rxe/)
# includeTagdir+=(./drivers/infiniband/core/)
# includeTagdir+=(./drivers/net/ethernet/mellanox/mlx5/core/)
includeTagdir+=(./drivers/net/ethernet/mellanox/)
includeTagdir+=(./net/ipv4/)

excludeTagdir=(./build);
# excludeTagdir+=(and ./buildlib);
# excludeTagdir+=(and ./someotherdir);

printf "tag     : %s\n" ${includeTagdir[@]}
if [ ${#excludeTagdir[@]} -eq  0 ] ; then
    ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $( find ${includeTagdir[@]} -type f -regex ".*\.c\|.*\.h")
else 
    printf "exclude : %s\n" ${excludeTagdir[@]/and/}
    prune="-path ${excludeTagdir[@]/and/-o -path}";
    ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $( find ${includeTagdir[@]} \( $(echo $prune) \) -prune -o -type f -regex ".*\.c\|.*\.h")
fi    
exit

#==========================================================================
# all this code below is a bit stupid

# for (( i=0 ; i< ${#tagdir[@]} ; i++ )) ; do 
#     echo "${i} -> ${tagdir[${i}]}"
#     pushd ${tagdir[${i}]} > /dev/null
#     ctags -R --sort=yes --fields=+niaS --extra=+q --extra=+f $(find -regex ".*\.c\|.*\.h")
#     popd > /dev/null
#     
#     d=$(readlink -f ${tagdir[$i]})
# 
#     vimTagfile+="${d}/tags," 
# 
# done 
# 
# echo ${vimTagfile} > tags



