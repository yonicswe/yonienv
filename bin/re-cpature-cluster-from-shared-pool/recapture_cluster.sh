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

dellclusterleaseReRelease ()
{
    local user=${1};
    local cluster=${2}
    local new_owner=;
    local cluster_owner=;

    cluster_owner=$(/home/build/xscripts/xxutil.py labjungle cluster "name:${cluster}" | jq -r ".objects[].lease.user.username");
    if [[ "${cluster_owner}" == "null" ]] ; then
        # cluster is free lets just take it
        /home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster};
        return;
    fi;

    if [[ "${cluster_owner}" != "y_cohen" ]] ; then
        echo -e "${YELLOW}y_cohen is not owner of ${cluster}. lets change that${NC}";
        #dellclusterleaseUpdateUser y_cohen ${cluster};
        /home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster};
    fi;

    echo -e "${YELLOW} y_cohen release ${cluster} ${NC}";
    #dellclusterleaseRelease ${cluster};
    /home/public/scripts/xpool_trident/prd/xpool release ${cluster};

    sleep 2;

    new_owner=$(/home/build/xscripts/xxutil.py labjungle cluster "name:${cluster}" | jq -r ".objects[].lease.user.username");
    # hippo sometimes takes released clusters
    # in which case update the user back to y_cohen
    if [[ "${new_owner}" == "null" ]] ; then
        echo -e "${YELLOW}${cluster} is owned by no one. lets take it${NC}"
        #_dellclusterlease 3d ${cluster};
        /home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster};
    else
        echo -e "${YELLOW}${new_owner} : got the cluster. lets take it back ;-)${NC}";
        #dellclusterleaseUpdateUser y_cohen ${cluster};
        /home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster};
        echo -e "${YELLOW}y_cohen : extend ${cluster} for 3 days${NC}";
        #dellclusterleaseextend ${cluster} 3;
        /home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster};
    fi;

    if [[ ${user} != "y_cohen" ]] ; then
        echo -e "${YELLOW}update ${cluster} to user to : ${user}${NC}";
        #dellclusterleaseUpdateUser ${user} ${cluster};
        /home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster};
    fi;

}

cluster_list=${1};

user=$(head -1 ${cluster_list});

num_of_users=$(( $(wc -l ${cluster_list} | cut -f 1 -d ' ') - 1 ));

user_name=$(sed -n "${user}p" ${cluster_list});
cluster=$(basename ${cluster_list});

echo "dellclusterleaseReRelease ${user_name} ${cluster}";
dellclusterleaseReRelease ${user_name} ${cluster};


user=$(( ${user} + 1))

user=$(( ( (${user} - 2) % ${num_of_users} ) + 2 ));
sed -i "1s/.*/${user}/" ${cluster_list};


