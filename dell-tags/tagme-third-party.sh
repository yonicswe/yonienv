#!/bin/bash
source ${yonienv}/bashrc_tags.sh
includeTagdir+=(cyc_platform/src/third_party/QLA/)
includeTagdir+=(cyc_platform/obj_Release/third_party/BRCM_OCS/src/BRCM_OCS/)
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
