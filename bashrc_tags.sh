#!/bin/bash

tagcompleteme () 
{
    name_spec=$1;
    # complete -W "$(awk -v n=$name_spec '/${n}/{print $1}' tags )" gt 
    if [ -z ${name_spec}] ; then 
        complete -W "$(cat tags |               awk '{print $1}')" gt 
    else
        complete -W "$(grep ${name_spec} tags | awk '{print $1}')" gt 
    fi
}

alias tagme='cp ${yonienv}/bin/tagme.sh .'
alias cpptags='ctags -R --sort=yes --c++-kinds=+p --fields=+niaS --extra=+q --extra=+f $(find -regex ".*\.c\|.*\.cpp\|.*\.h\|.*\.hpp")' 

tagcscope () 
{
    source_path=${1:-.};
    find ${source_path} -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    ls cscope.*
    cscope -vb;
    ls cscope.*
}

tagcscopekernel () 
{
    find drivers/infiniband/  include/ -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -b;
}
