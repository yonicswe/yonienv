#!/bin/bash

yonienv=$(awk 'BEGIN{FS="="}/yonienv=/{  print $2}' ~/.bashrc | sed 's/;//');
source ${yonienv}/bashrc_tags.sh

includeTagdir+=(.) 
# excludeTagdir+=(./build);
# excludeTagdir+=(+++ ./buildlib);
# excludeTagdir+=(+++ ./someotherdir);

tagme_base includeTagdir[@] excludeTagdir[@]

exit
#=================================================================================================
# all this has moved to bashrc_tags.sh
# leaving it here for prosperity

# if [ -e cscope.files ] ; then 
#     cscope -vkqb;
#     echo "Building ctags file...";
#     ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $(cat cscope.files)
#     exit
# fi
# 
# printf "tag     : %s\n" ${includeTagdir[@]}
# if [ ${#excludeTagdir[@]} -eq  0 ] ; then
#     source_files=($( find ${includeTagdir[@]} -type f -regex ".*\.c\|.*\.h"))
#     ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $(echo ${source_files[@]})
#     echo > cscope.files
#     for f in ${source_files[@]} ; do echo $f  >> cscope.files ; done 
#     cscope -vkqb
# else 
#     printf "exclude : %s\n" ${excludeTagdir[@]/and/}
#     prune="-path ${excludeTagdir[@]/+++/-o -path}";
#     source_files=($( find ${includeTagdir[@]} \( $(echo $prune) \) -prune -o -type f -regex ".*\.c\|.*\.h"))
#     ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $(echo ${source_files[@]})
#     echo > cscope.files
#     for f in ${source_files[@]} ; do echo $f  >> cscope.files ; done 
#     cscope -vkqb
# fi    
# exit

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



