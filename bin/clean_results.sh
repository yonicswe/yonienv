#!/bin/bash

clean_value () 
{
    local key=${1};
    local file=${2};

    echo -e "sed -i \"s/${key}.*/${key}/g\" ${file}";
    sed -i "s/${key}.*/${key}/g" ${file};
    
}   

clean_exprssion () 
{
    local expression="${1}";
    local file=${2};

#     echo -e "${expression} ${file}" ;
    set -x
    sed -i  "${expression}"  ${file};
    set +x

}

main () 
{
    local file=${1};
    declare -a keys;
    declare -a expressions;
    
    if [ -z ${file} ] ; then 
       return;
    fi 

    keys=("HTTP_CONTENT_FILE_ID");
    keys+=("MAIL_ATTACHMENT_FILE_ID")
    keys+=("MAIL_BODY")
    keys+=("FeCorrelation")
    keys+=("FileID")
#     keys+=("PartyId")
    keys+=("AbstractionId")
    keys+=("StartTime")
    keys+=("HttpContentFileId") 

    expressions=("s/\(\[WebEngine\][^(]*\)([^)]*)/\[WebEngine\] /g");
    expressions+=("/^[A-Z][a-z]\{2\}\s[A-z][a-z]\{2\}/d");

    for (( i=0; i<${#keys[@]} ; i++)) ; do 
        clean_value ${keys[${i}]} ${file};
    done;        

    for (( i=0; i<${#expressions[@]} ; i++)) ; do 
        clean_exprssion "${expressions[${i}]}" ${file};
    done;        
}

main $@


        
        
        
        
        
        
        
        
        
