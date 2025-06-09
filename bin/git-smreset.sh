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

for s in source/* ; do
    echo -e "${PURPLE}------[$s] ${RED}reset modified content${NC}------";
    cd $s ; git c -f . ;
    cd - 2>&1 1>/dev/null ;
    echo -e "${PURPLE}------[$s] ${RED}reset new commits${NC}-----------";
    git smupdate $s;
done;
BLUE=""
