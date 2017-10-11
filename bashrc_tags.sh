#!/bin/bash

tagcompleteme () 
{
    name_spec=$1;
    # complete -W "$(awk -v n=$name_spec '/${n}/{print $1}' tags )" gt 
    complete -W "$(grep ${name_spec} tags | awk '{print $1}')" gt 
}

alias tagme='cp ~yonatanc/share/ipteam_env/bin/tagme.sh .'
alias cpptags='ctags -R --sort=yes --c++-kinds=+p --fields=+niaS --extra=+q --extra=+f $(find -regex ".*\.c\|.*\.cpp\|.*\.h\|.*\.hpp")' 

tagcscope () 
{
    source_path=${1-=.};
    find ${source_path} -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -b;
}

tagcscopekernel () 
{
    find drivers/infiniband/  include/ -regex ".*\.c\|.*\.h"  -type f > cscope.files;
    cscope -b;
}
