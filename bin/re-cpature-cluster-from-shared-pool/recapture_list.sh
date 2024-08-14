#!/bin/bash



for c in clusters/* ; do 

    cluster_list=${c};

    user=$(head -1 ${cluster_list});

    num_of_users=$(( $(wc -l ${cluster_list} | cut -f 1 -d ' ') - 1 ));

    user_name=$(sed -n "${user}p" ${cluster_list});
    cluster=$(basename ${cluster_list});

    current_user=$(2>/dev/null /home/build/xscripts/xxutil.py labjungle cluster "name:${cluster}" | jq -r ".objects[].lease.expires_on , .objects[].lease.user.username" | xargs);
    echo "${cluster} : ${current_user} -> ${user_name}";

done;
