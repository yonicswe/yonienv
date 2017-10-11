#!/bin/bash

namedscreen () 
{ 
	local screen_list;
	local i;
	local opt;
	local reattach;
    local logging="";

	screen_list=$(screen -ls | awk '/(Detached)|(Attached)/{print $1}' | sed 's/.*\.//g' |xargs);
	complete -W "${screen_list}" namedscreen screen;
	
	if [ -z "$*" ]; then
        screen -ls | awk '/(Detached)|(Attached)/{print $0}';
        [ "${TERM}" == "screen" ] && echo "BTW your inside a screen"
		return;
	fi;

	OPTIND=0;
	while getopts "lr:" opt; do
		case $opt in 
            l)
                logging="-L";
                shift;
                ;;
			r)
				reattach=$OPTARG
				;;
			*)
				shift
				;;
		esac;
	done;

	if [ -z "${reattach}" ]; then
		screen_name=$1;
        echo "logfile ${screen_name}.screenlog" > ~/.screenrc
		screen -t ${screen_name} -S ${screen_name} ${logging};
	else
		screen -r ${reattach};
	fi;

	screen_list=$(screen -ls | awk '/(Detached)/{print $1}' |xargs);
	complete -W "${screen_list}" namedscreen screen 
}

if [ $(rpm -q screen | wc -l ) -ne 0 ] ; then 
    namedscreen > /dev/null;
fi 

complete -W "$(screen -ls | awk '/Attached|Detached/{gsub(/.*\./,"",$1); print $1}')" screen sr 
sl () 
{
    screen -ls
# complete -W "$(screen -ls | awk '/Attached|Detached/{gsub(/.*\./,"",$1); print $1}')" screen sr 
    complete -W "$(screen -ls | awk '/Attached|Detached/{print $1}')" screen sr 
}
alias sr='screen -dr'
alias sd='echo $TERM'
