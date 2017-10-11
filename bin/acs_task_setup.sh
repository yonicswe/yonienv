#!/bin/bash


TRUNK_SVN_URL="svn://snt.nice.com/NiceTrackMC/RnD/MonitoringCenter/MC5/branches/Developers/IPTeam/IPS/6.0/"

checkout_config () 
{
	local svn_url=$1;
	local task_name=$2;

    if [ -d ${HOME}/work/${task_name}/config ] ; then 
        echo "svn up ${HOME}/work/${task_name}/config";
        svn up ${HOME}/work/${task_name}/config;
    else        
        svn co ${svn_url}/NiceTrackI/config ${HOME}/work/${task_name}/config > /dev/null
    fi
	svn export ${svn_url}/NiceTrackI/Applications/HTTPWebEngine/resources/config ${HOME}/work/${task_name}/config --force  > /dev/null

}

build_task_env () 
{
	local svn_url=$1;
	local task_name=$2;
	local check_out_3d_party=$3;

	# create the development working environment
	mkdir -p ${HOME}/work/${task_name}/logs
	mkdir -p ${HOME}/work/${task_name}/bundle
	mkdir -p ${HOME}/work/${task_name}/files

    svn co ${svn_url} ${HOME}/work/${task_name}/ > /dev/null

#     checkout_config ${svn_url} ${task_name} 
#     /bin/bash ${HOME}/work/regression/scripts/config_setup.sh
}

usage () 
{
    echo -e "====================================================";
    echo -e "task_setup.sh [-h] -t <task name > -u <svn url>";
    echo -e "\t-t : <task name|trunk>";
    echo -e "\t     with trunk no url is needed";
    echo -e "\t-u : the svn url to check out the branch from";
    echo -e "\t-h : show this help";
    echo -e "====================================================";
    exit 0;
}

create_trunk () 
{
	local check_out_3d_party=1;
	local task_name=trunk;


	build_task_env ${TRUNK_SVN_URL} ${task_name} ${check_out_3d_party}; 
}

verify_url () 
{
	local url=$1; 
	local r=0;

	(svn info ${url}) 2>/dev/null 1> /dev/null;
	r=$?;

	if (( $r != 0 )) ; then 
		echo -e "Non Valid URL : \"${url}\"";
	fi 

	return $r; 
}

main () 
{
	local r=0;
	local opt;
	local answer;
	local task_name="acs";
	local svn_url="snt.nice.com/ACSRepo/ACS/trunk";

    OPTIND="";
    while getopts "hu:t:" opt ; do 
        case $opt in
        h)
            usage;
            ;;    
        t)
            task_name=${OPTARG};
            ;;
        u)  
            svn_url=${OPTARG};
            ;;
        esac
    done

	# verify parameters
	if [ -z "$task_name" ] ; then 
		usage;
		return;
	fi

	if [ "${task_name}" == "acs" ] ; then 
		create_trunk;
		return;
	fi	

	if [ -z "${svn_url}" ] ; then 			
		usage;
		return;
	fi

	# test if this task already exist
	if [ -e ${HOME}/work/${task_name} ] ; then 
		echo -e "a task named \"${task_name}\" already exist, please Enter a new task name";
		return;
	fi		

    svn_url=svn://${svn_url};

	# make sure the check out step will finish successfully.		
	verify_url ${svn_url};
	r=$?;
	if (( $r != 0 )) ; then 
		return $r;
	fi

	verify_url ${svn_url}/NiceTrackI;
	r=$?;
	if (( $r != 0 )) ; then 
		return $r;
	fi

	verify_url ${svn_url}/WebEngineP;
	r=$?;
	if (( $r != 0 )) ; then 
		return $r;
	fi

	echo "URL : ${svn_url}";
	echo "task : ${task_name}";
	read -p "Are you sure [N|yes] : " answer;
	if [  "$answer" = "yes" ] ; then 
        build_task_env ${svn_url} ${task_name};
	fi 
}

main "$@";

