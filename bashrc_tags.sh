#!/bin/bash

tagcompleteme ()
{
    name_spec=$1;
    # complete -W "$(awk -v n=$name_spec '/${n}/{print $1}' tags )" gt
    if [ -z "${name_spec}" ] ; then
        complete -W "$( awk '{print $1}' tags )" gt vt
    else
        complete -W "$(awk '{print $1}' tags | /bin/grep -i ${name_spec} )" gt vt
    fi
}

alias tagcpp='ctags -uR --sort=yes --c++-kinds=+p --fields=+niaS --extra=+q --extra=+f $(find -regex ".*\.c\|.*\.cpp\|.*\.h\|.*\.hpp")'
alias tagpython='ctags -R --python-kinds=-i'
alias tagbash='ctags --language-force=sh *sh'

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
        echo "cscope.files has $(wc -l cscope.files|cut -f 1 -d ' ') files (size: $(ls -sh cscope.files|cut -f 1 -d ' '))"
        echo -e "\033[0;33mRe-Tagging ctags...\033[0m";
#       ctags -uR --sort=yes --fields=+niaS --c-kinds=+p --c++-kinds=+p --extra=+q --extra=+f $(cat cscope.files) &
            set -x
        ctags -u --fields=+niaS --c-kinds=+cdefglmpstuvx --c++-kinds=+p --extra=+q --extra=+f -L cscope.files
            set +x
        echo -e "\033[0;33mRe-Tagging cscope...\033[0m";
#       echo "cscope -vkqb 2>/dev/null";
        cscope -vkqb 2>/dev/null;
        exit
    fi

    echo -e "\033[0;31mTagging\033[0m   : ${includeTagdir[@]}"; 
    echo -e "\033[0;31mGenerating file list\033[0m";
    echo ""

    if [ ${#excludeTagdir[@]} -eq  0 ] ; then
#       source_files=($( find ${includeTagdir[@]} -type f -regex ".*\.c\|.*\.h" -exec readlink -f {} \; ) ) 
#       source_files=($( find ${includeTagdir[@]} -type f -regex ${filetypes} -exec readlink -f {} \; ) )

#       echo "find ${includeTagdir[@]} -type f -regex ${filetypes} -exec readlink -f {} \; > cscope.files" 
        find ${includeTagdir[@]} -type f -regex ${filetypes} -exec readlink -f {} \; > cscope.files &

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
#       printf "exclude : %s\n" ${excludeTagdir[@]/+++/}
        prune="-path ${excludeTagdir[@]/+++/-o -path}";
#       source_files=($( find ${includeTagdir[@]} \( $(echo $prune) \) -prune -o -type f -regex ".*\.c\|.*\.h"))

#       echo "find ${includeTagdir[@]} \( $(echo $prune) \) -prune -o -type f -regex ".*\.c\|.*\.h" > cscope.files;"
        find ${includeTagdir[@]} \( $(echo $prune) \) -prune -o -type f -regex ".*\.c\|.*\.h" > cscope.files & 

#=================================================================================================
#         echo "Building ctags file...";
#         ctags --sort=yes --fields=+niaS --c-kinds=+p --extra=+q --extra=+f $(echo ${source_files[@]})
#         echo > cscope.files
#         for f in ${source_files[@]} ; do echo $f  >> cscope.files ; done 
#         cscope -P$(pwd) -vkqb 2>/dev/null
#=================================================================================================
    fi    

    file=cscope.files;

    while true ; do 
        sleep 0.2
        if [ ! -f ${file} ] ; then 
            continue;
        fi;
        break;
    done;

    size=$(ls -s $file | cut -f 1 -d ' ');
    while true ; do 

        if [ "$(ls -s $file | cut -f 1 -d ' ')" -eq "$size" ] ; then 
            break;
        fi 

        echo -ne "$(tail -1 $file)                                ";
        echo -ne "\r"
        size=$(ls -s $file | cut -f 1 -d ' ');
    done

    echo -e "\ncscope.files has $(wc -l cscope.files|cut -f 1 -d ' ') files (size: $(ls -sh cscope.files|cut -f 1 -d ' '))"
    echo -e "\033[0;31mTagging ctags...\033[0m";
#   echo "ctags -u --sort=yes --fields=+niaS --c-kinds=+p --c++-kinds=+p --extra=+q --extra=+f -L cscope.files"
    ctags -u --sort=yes --fields=+niaS --c-kinds=+p --c++-kinds=+p --extra=+q --extra=+f -L cscope.files

#   ctags -uR --sort=yes --fields=+niaS --c-kinds=+p --c++-kinds=+p --extra=+q --extra=+f $(echo ${source_files[@]})
#   echo > cscope.files
#   for f in ${source_files[@]} ; do echo $f  >> cscope.files ; done 

    echo -e "\033[0;31mTagging cscope...\033[0m"
#   echo "cscope -vkqb 2>/dev/null"
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
