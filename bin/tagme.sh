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
