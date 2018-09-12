main ()
{
    echo ${PRJ_NAME}
    if [ $# -gt 0 ]  ; then 
        echo "re-tagging...";
        rm -f cscope.files;    
    fi

    tagme_base includeTagdir[@] excludeTagdir[@]
}

main $@
