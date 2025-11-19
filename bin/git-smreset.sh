#!/bin/bash
source ${yonienv}/bashrc_common.sh
source ${yonienv}/bashrc_fs.sh

#RED="\033[1;31m"
#REDBLINK="\033[1;5;31m"
#REDITALIC="\033[1;3;31m"
#REDREVERSE="\033[1;7;31m"
#BLUE="\033[0;34m"
#GREEN="\033[0;32m"
#CYAN="\033[0;36m"
#PURPLE="\033[0;35m"
#BROWN="\033[0;33m"
#YELLOW="\033[1;33m"
#NC="\033[0m"

pdr_branch=$(git bb)
submodules=( "nt-nvmeof-frontend" "cyc_core" "third_party" );

ask_user_default_no "reset all submodules to ${pdr_branch}"
if [ $? -eq 0 ] ; then

    for s in ${submodules[@]}; do
        ss=source/$s;
        echo -e "${PURPLE}------[$s] ${RED}reset modified content${NC}------";
        cd $ss ; git reset  HEAD ; git c -f . ;
        cd - 2>&1 1>/dev/null ;
        echo -e "${PURPLE}------[$s] ${RED}reset new commits${NC}-----------";
        git smupdate $ss;
    done; 

    exit;
 
fi;

for s in source/* ; do
    echo -e "${PURPLE}------[$s] ${RED}reset modified content${NC}------";
    cd $s ; git reset  HEAD ; git c -f . ;
    cd - 2>&1 1>/dev/null ;
    echo -e "${PURPLE}------[$s] ${RED}reset new commits${NC}-----------";
    git smupdate $s;
done;
BLUE=""
