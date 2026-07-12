#!/bin/sh

. ./cyc_helpers_common.sh

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

cyclone_folder=${1};

if [ -z ${cyclone_folder} ] ; then
    echo "cyclone folder not set"
    exit;
fi;

old_drivers_path=/cyc_software_0/cyc_host/cyc_common/modules/
new_drivers_release_path=${cyclone_folder}/source/cyc_core/cyc_platform/obj_Release/package/final/top_host/cyc_host/cyc_common/modules;
new_drivers_debug_path=${cyclone_folder}/source/cyc_core/cyc_platform/obj_Debug/package/final/top_host/cyc_host/cyc_common/modules;

found_release=false;
found_debug=false;
if [ -d ${new_drivers_release_path} ] ; then
    echo -e "${BLUE}found drivers in ${new_drivers_release_path}${NC}";
    found_release=true;
fi;

if [ -d ${new_drivers_debug_path} ] ; then
    echo -e "${BLUE}found drivers in ${new_drivers_debug_path}${NC}";
    found_debug=true;
fi;

if [[ ${found_release} == false && ${found_debug} == false ]] ; then
    echo -e "${RED}new drivers were not found${NC}";
    exit -1;
fi;

read -p "install (R)etail or (d)ebug [R/d]" ans;
if [[ ${ans} =~ d ]] ; then
    if [[ ${found_debug} == false ]] ; then
        echo -e "${RED}new debug drivers were not found${NC}";
        exit -1;
    fi;
    echo -e "${BLUE}you chose to install debug drivers${NC}";
    new_driver_path=${new_drivers_debug_path};
else
    if [[ ${found_release} == false ]] ; then
        echo -e "${RED}new release drivers were not found${NC}";
        exit -1;
    fi;
    echo -e "${BLUE}you chose to install Retail drivers${NC}";
    new_driver_path=${new_drivers_release_path};
fi;

echo -e "${GREEN}zipping new drivers${NC}";
find ${new_driver_path} -type f -name "*ko" -print0 | tar --null -T - -cf new_drivers.tar --transform='s|.*/||'

# backup original drivers on node-a
if [[ $(./run_core_a.sh ls /home/core/  | grep modules.orig | wc -l  ) == 0 ]] ; then
    echo -e "${RED}backup original drivers to node-a://home/core/modules.orig${NC}";
    ./run_core_a.sh mkdir /home/core/modules.orig
    ./run_core_a.sh cp ${old_drivers_path}/*.ko /home/core/modules.orig;
else
    echo -e "${BLUE}found backup of original drivers in node-a://home/core/modules.new ! skipping backup${NC}";
fi;

# backup original drivres on node-b
if [[ $(./run_core_b.sh ls /home/core/  | grep modules.orig | wc -l  ) == 0 ]] ; then
    echo -e "${RED}backup original drivers to node-b://home/core/modules.orig${NC}";
    ./run_core_b.sh mkdir /home/core/modules.orig
    ./run_core_b.sh cp ${old_drivers_path}/*.ko /home/core/modules.orig;
else
    echo -e "${BLUE}found backup of original drivers in node-b://core/modules.new ! skipping backup${NC}";
fi;

# install drivers to node-a
echo -e "${GREEN}./scp_core_to_a.sh new_drivers.tar${NC}";
./scp_core_to_a.sh new_drivers.tar

echo -e "${GREEN}./run_core_a.sh tar xvf new_drivers.tar -C ${old_drivers_path}${NC}";
./run_core_a.sh sudo tar xvf new_drivers.tar -C ${old_drivers_path};

# install drivers to node-b
echo -e "${GREEN}./scp_core_to_b.sh new_drivers.tar${NC}";
./scp_core_to_b.sh new_drivers.tar

echo -e "${GREEN}./run_core_b.sh tar xvf new_drivers.tar -C ${old_drivers_path}${NC}";
./run_core_b.sh sudo tar xvf new_drivers.tar -C ${old_drivers_path};

read -p  "about to restart both nodes [Enter]"

echo -e "${GREEN}Reloading drivers on the node-a${NC}";
./stack_down_hard_only_a.sh
./stack_up_only_a.sh

echo -e "${GREEN}Reloading drivers on the node-b${NC}";
./stack_down_hard_only_b.sh
./stack_up_only_b.sh

exit 0;
