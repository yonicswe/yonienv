#!/bin/bash

tagcompleteme ()
{
    name_spec=$1;
    # complete -W "$(awk -v n=$name_spec '/${n}/{print $1}' tags )" gt
    if [ -z "${name_spec}" ] ; then
        complete -W "$( awk '{print $1}' tags )" gt vt
    else
        complete -W "$(awk '{print $1}' tags | /usr/bin/grep -i ${name_spec} )" gt vt
    fi
}

alias cpptags='ctags -uR --sort=yes --c++-kinds=+p --fields=+niaS --extra=+q --extra=+f $(find -regex ".*\.c\|.*\.cpp\|.*\.h\|.*\.hpp")'
alias pythontags='ctags -R --python-kinds=-i'

tagcscope ()
{
    source_path=${1:-.};
    find ${source_path} -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -vqb;
}

tagcscopekernel ()
{
    source_path=${1:-.};
    find ${source_path} -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -vqbk;
}

tagcscopeinfiniband ()
{
    source_path=${1:-.};
    find ${source_path}/drivers/infiniband/ ${source_path}/drivers/net/ethernet/mellanox/ ${source_path}/include/ -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -vkqb;
}

tagcscopemlx5 ()
{
    source_path=${1:-.};
    find ${source_path}/drivers/infiniband/hw/mlx5/ ${source_path}/drivers/net/ethernet/mellanox/mlx5/ ${source_path}/include/ -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -vkqb;
}

alias tagyonienv='ctags --language-force=sh *sh'

tagme_base ()
{
#   declare -a includeTagdir=("${!1}");
#   declare -a excludeTagdir=("${!2}");
    local extra_filetypes=$3;
    local filetypes=".*\.c\|.*\.h\|.*\.hh\|.*\.cc\|.*\.cpp";
#   local filetypes=".*\.hh\|.*\.cc\|.*\.cpp";

    filetypes+=${extra_filetypes};

#   echo  includeTagdir: ${includeTagdir[@]}
#   echo  excludeTagdir: ${excludeTagdir[@]}

#     rpm -q cscope > /dev/null;
#     if [ $? -ne 0 ] ; then echo "yum install cscope" ; return ; fi ; 
#     rpm -q ctags > /dev/null;
#     if [ $? -ne 0 ] ; then echo "yum install ctags" ; return ; fi ; 

    if [ -e cscope.files ] ; then 
        cscope -vkqb 2>/dev/null;
        echo "re-building ctags...";
        ctags -uR --sort=yes --fields=+niaS --c-kinds=+p --c++-kinds=+p --extra=+q --extra=+f $(cat cscope.files) &
        exit
    fi

    printf "tag     : %s\n" ${includeTagdir[@]}
    if [ ${#excludeTagdir[@]} -eq  0 ] ; then
#       source_files=($( find ${includeTagdir[@]} -type f -regex ".*\.c\|.*\.h" -exec readlink -f {} \; ) )

        source_files=($( find ${includeTagdir[@]} -type f -regex ${filetypes} -exec readlink -f {} \; ) )

#=================================================================================================
#       echo "Building ctags file...";
#       ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $(echo ${source_files[@]})
#       echo > cscope.files
#       for f in ${source_files[@]} ; do echo $f  >> cscope.files ; done 
#       cscope -vkqb 2>/dev/null
#       -P$(pwd)  creates cscope.out with full path
#         cscope -P$(pwd) -vkqb 2>/dev/null 
#=================================================================================================

    else 
        printf "exclude : %s\n" ${excludeTagdir[@]/+++/}
        prune="-path ${excludeTagdir[@]/+++/-o -path}";
        source_files=($( find ${includeTagdir[@]} \( $(echo $prune) \) -prune -o -type f -regex ".*\.c\|.*\.h"))
#=================================================================================================
#         echo "Building ctags file...";
#         ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $(echo ${source_files[@]})
#         echo > cscope.files
#         for f in ${source_files[@]} ; do echo $f  >> cscope.files ; done 
#         cscope -P$(pwd) -vkqb 2>/dev/null
#=================================================================================================
    fi    

    echo "Building ctags file...";
    ctags -uR --sort=yes --fields=+niaS --c-kinds=+p --c++-kinds=+p --extra=+q --extra=+f $(echo ${source_files[@]})
    echo > cscope.files
    for f in ${source_files[@]} ; do echo $f  >> cscope.files ; done 
    cscope -vkqb 2>/dev/null
}

tagme ()
{
    echo "#!/bin/bash" > tagme.sh;
    echo 'source ${yonienv}/bashrc_tags.sh' >> tagme.sh;
    echo 'includeTagdir+=(.)' >> tagme.sh
    cat  ${yonienv}/bin/tagme.sh >> tagme.sh ;
    chmod +x tagme.sh;
}
alias ttt='./tagme.sh'
alias tttt='./tagme.sh 1'
