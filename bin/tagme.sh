main ()
{
    echo ${PRJ_NAME}
    if [ $# -gt 0 ]  ; then 
        echo "re-tagging...";
        rm -f cscope.*;    
        rm -f tags;
    fi

    tagme_base includeTagdir[@] excludeTagdir[@]
}

main $@
