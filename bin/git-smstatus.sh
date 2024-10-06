#!/bin/bash

#git sm foreach echo "$(git hh) $(git bb)"
for s in source/* ; do
    cd $s ;
        if [ $(ls |wc -l ) -eq 0 ] ; then
            echo -e "\033[0;34m-                                         $s\033[0m" ;
        else
            echo -e "\033[0;32m+$(git hh) $s\033[0m" ;
        fi;
        cd - 2>&1 1>/dev/null ;
    done;
BLUE=""
