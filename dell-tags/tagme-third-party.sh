#!/bin/bash
source ${yonienv}/bashrc_tags.sh
includeTagdir+=(cyc_platform/src/third_party/QLA/)
includeTagdir+=(cyc_platform/src/third_party/QLA/)
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
