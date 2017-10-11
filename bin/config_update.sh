#!/bin/bash

main () 
{

	local svn_url=$(svn info ${IPS_PATH} |grep URL |sed 's/.*\ //')	
            
    pushd ${NTI_CONFIG_PATH} 1>/dev/null;

    echo "$(pwd) svn up";
#     svn up;
    echo "$(pwd) svn export ${svn_url}/NiceTrackI/Applications/HTTPWebEngine/resources/config ${TASK_PATH}/config --force"
#     svn export ${svn_url}/NiceTrackI/Applications/HTTPWebEngine/resources/config ${TASK_PATH}/config --force;

    popd 1>/dev/null
}

main "$@";
