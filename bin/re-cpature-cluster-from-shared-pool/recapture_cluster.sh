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

cluster_owner ()
{
    local cluster=${1};

    2>/dev/null /home/build/xscripts/xxutil.py labjungle  cluster "name:${cluster}" | jq -r ".objects[].lease.user.username"|sed 's/\ //g';
}

dellclusterleaseReRelease ()
{
    local user=${1};
    local cluster=${2}
    local new_owner=;
    local cluster_owner=;
    local retries=1;

    cluster_owner=$(cluster_owner ${cluster});

    if [[ -z "${cluster_owner}" ]] ; then
        echo -e "${RED}!!error!! could not get cluster owner${NC}";
        return -1;
    fi

    if [[ "${cluster_owner}" == "null" ]] ; then
        echo -e "${YELLOW}${cluster} is free lets just take it${NC}";
        echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster}${NC}";
        /home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster};
    else
        if [[ "${cluster_owner}" != "y_cohen" ]] ; then
            echo -e "${YELLOW}${cluster} owned by ${cluster_owner}. lets change that${NC}";
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster}${NC}";
            /home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster};
        fi;

        echo -e "${YELLOW}release ${cluster} from ${cluster_owner}${NC}";
        echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool release ${cluster}${NC}";
        /home/public/scripts/xpool_trident/prd/xpool release ${cluster};

        new_owner=$(cluster_owner ${cluster});
        while [[ "${new_owner}" == "y_cohen" ]] ; do
            echo -e "${RED}${cluster} still owned by ${new_owner}. lets wait 2 more seconds${NC}";
            sleep 2;
            new_owner=$(cluster_owner ${cluster});
            ((retries++));
            if [[ ${retries} > 5 ]] ; then
                echo -e "${RED}failed to release ${cluster}${NC}";
                return;
            fi;
        done;

        if [[ "${new_owner}" == "null" ]] ; then
            echo -e "${YELLOW}${cluster} is free. lets take it${NC}"
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster}${NC}";
            /home/public/scripts/xpool_trident/prd/xpool lease 3d -c ${cluster};
        else
            # hippo sometimes takes released clusters
            echo -e "${YELLOW}${new_owner}: got ${cluster}. lets take it back ;-)${NC}";
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster}${NC}";
            /home/public/scripts/xpool_trident/prd/xpool update --force -u y_cohen ${cluster};

            echo -e "${YELLOW}y_cohen : extend ${cluster} for 3 days${NC}";
            echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool extend ${cluster} 3d${NC}";
            /home/public/scripts/xpool_trident/prd/xpool extend ${cluster} 3d;
        fi;

    fi;

    if [[ ${user} != "y_cohen" ]] ; then
        echo -e "${YELLOW}update ${cluster} to user to : ${user}${NC}";
        echo -e "${BLUE}/home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster}${NC}";
        /home/public/scripts/xpool_trident/prd/xpool update --force -u ${user} ${cluster};
    fi;

}

loop_owner ()
{
    local cluster=${1};
    local new_owner=;
    local retries=0;

    new_owner=y_cohen;

    while [[ "${new_owner}" == "y_cohen" ]] ; do
        echo -e "${RED}${cluster} stil owned by ${new_owner}. lets wait 2 more seconds${NC} r=${retries}";
        sleep 2;

        ((retries++));

        if (( ${retries} == 3 )) ; then
            new_owner=new;
        else
            new_owner=y_cohen;
        fi;

        if [[ ${retries} > 5 ]] ; then
            echo -e "${RED}failed to release ${cluster}${NC} r=${retries}";
            return;
        fi;
    done;
}

cluster_user_list=${1};

user_number=$(head -1 ${cluster_user_list});

num_of_users=$(( $(wc -l ${cluster_user_list} | cut -f 1 -d ' ') - 1 ));

user_name=$(sed -n "${user_number}p" ${cluster_user_list});
cluster=$(basename ${cluster_user_list});

#loop_owner ${cluster};
#exit;

echo "dellclusterleaseReRelease ${user_name} ${cluster}";
dellclusterleaseReRelease ${user_name} ${cluster};


user_number=$(( ${user_number} + 1))

user_number=$(( ( (${user_number} - 2) % ${num_of_users} ) + 2 ));
sed -i "1s/.*/${user_number}/" ${cluster_user_list};
