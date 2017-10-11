#!/bin/bash

usage ()
{

    echo "============================================================";
    echo "Usage : valgrind_execute.sh -e <executable name> [-g] [-p]";
    echo "        -g - Freeze valgrind till you open gdb and send";
    echo "             target remote|vgdb from gdb command line";  
    echo "             memcheck output in valgrind.out.<pid>";
    echo "             just open it with any text editor";
    echo;
    echo "        -p - perform profiling with callgrind";
    echo "             otherwise run memcheck";
    echo "             profiling output in callgrind.out.<pid>";
    echo "             use it with";
    echo "                     kcachgrind callgrind.out.<pid>";
    echo "             or with";
    echo "                     callgrind_annotate callgrind.out.<pid>";
    echo "============================================================";

    exit -1; 

}

sanityCheck () 
{
    local exeName=${1};        
    local waitForGdb=${2}; 

    if [ "${exeName}" = "none" ] ; then
        usage;
    fi

}

startValgrindMemCheck () 
{
    local exeName=${1};        
    local waitForGdb=${2}; 

    valg_opts="  --tool=memcheck --leak-check=full --malloc-fill=1 --free-fill=2";
    valg_opts+=" --track-origins=yes";
    valg_opts+=" --read-var-info=yes";
    valg_opts+=" --log-file=valgrind.out.$$";

    if [ "${waitForGdb}" = "true" ] ; then 
        valg_opts+=" --vgdb-error=0";
    fi                    

    set -x                
    valgrind  ${valg_opts} ./${exeName}
    set +x                
}

startValgrindProfile () 
{
    local exeName=${1};        

    valg_opts="  --tool=callgrind";
    valg_opts+="  --dump-instr=yes";
#   valg_opts+="  --dump-before=RegExParser::work";

    set -x                
    valgrind  ${valg_opts} ./${exeName}
    set +x                
}

main () 
{
    local exeName="none";        
    local waitForGdb="false";
    local profile="false";

    # get params from user.  
	OPTIND=0;
	while getopts "hpge:" opt; do
		case $opt in 
            e)
                exeName=${OPTARG};
                ;;
            g)
                waitForGdb=true;
                ;;
            p)
                profile=true;                
                ;;
			h)
				usage;
				;;
			*)
                usage
				;;
		esac;
	done;

    sanityCheck ${exeName} ${waitForGdb} ${profile};

    if [ ${profile} = false ] ; then  
        startValgrindMemCheck ${exeName} ${waitForGdb};
    elif [ ${profile} = true ] ; then 
        startValgrindProfile ${exeName};
    else
        usage;
    fi    

} 

main $@

