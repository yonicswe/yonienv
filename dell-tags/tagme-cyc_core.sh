#!/bin/bash
source ${yonienv}/bashrc_tags.sh
includeTagdir+=(cyc_platform/src/mbe_r/)
includeTagdir+=(cyc_platform/src/module_r/)
includeTagdir+=(cyc_platform/src/st/)


main ()
{
    echo ${PRJ_NAME}
    if [ $# -gt 0 ]  ; then 
        rm -f cscope.*;    
        rm -f tags;
    fi

    tagme_base includeTagdir[@] excludeTagdir[@]
}

main $@
