#!/bin/bash

RED="\033[1;31m"
REDBLINK="\033[1;5;31m"
REDITALIC="\033[1;3;31m"
REDREVERSE="\033[1;7;31m"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
BROWN="\033[0;33m"
YELLOW="\033[1;33m"
NC="\033[0m"

#git sm foreach echo "$(git hh) $(git bb)"
for s in source/* ; do
    cd $s ;
        if [ $(ls |wc -l ) -eq 0 ] ; then
            echo -e "\033[0;34m-                                         $s\033[0m" ;
        else
            # echo -e "\033[0;32m+$(git hh) $s\033[0m" ;
            echo -e "\033[0;32m+$(git hh) $s (${PURPLE}$(git bb))${NC}" ;

        fi;
        cd - 2>&1 1>/dev/null ;
    done;
BLUE=""
