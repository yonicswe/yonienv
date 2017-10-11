#!/bin/bash
#
#  setup the config of the current task  
#  by changing values in the config files to match the 
#  consolidated environment, namely 
#  *  Icm.xml 
#	  +  ICs path : 	${HOME}/work/<task>/ics
#  *  log4cpp.category.icm 
#	  +  paths of log files : ${HOME}/work/<task>/logs
#
#

backslash_fix () 
{
	local v=${1};
	local vv;
	
	vv=$(echo $v | sed 's/\//\\\//g');
	echo $vv;					
}

change_xml_value () 
{
	local open_tag="${1}";
	local close_tag="${2}";
	local val="${3}";
	local file=${4}; 
	local start_section=${5}; 
	local end_section=${6}; 

	open_tag="$(backslash_fix ${open_tag})";
	close_tag="$(backslash_fix ${close_tag})";
	val="$(backslash_fix ${val})";

	if [ -z "${start_section}" -o -z "${end_section}" ] ; then 

#  	 	echo -e "sed -e \"s/${open_tag}.*${close_tag}/${open_tag} ${val} ${close_tag}/g\" ${file}";
		sed -i -e "s/\(${open_tag}\).*\(${close_tag}\)/\1 ${val} \2/" ${file};

	else
		start_section="$(backslash_fix ${start_section})";
		end_section="$(backslash_fix ${end_section})";
#  		echo -e "sed -e \"/${start_section}/,/${end_section}/{s/\(${open_tag}\).*\(${close_tag}\)/\1 ${val} \2/g}\" ${file}";
 		sed -i -e "/${start_section}/,/${end_section}/{s/\(${open_tag}\).*\(${close_tag}\)/\1 ${val} \2/}" ${file};
	fi
}

change_param_value () 
{
	local param=${1};
	local val="${2}";
	local file=${3};

	val="$(backslash_fix "${val}")";

# 	echo -e "sed -e \"s/\(${param}[[:space:]]*=\).*/\1${val}/\" ${file}";
  	sed -i -e "s/\(${param}[[:space:]]*=\).*/\1${val}/" ${file};
}

delete_param () 
{
	local param=${1};
	local file=${2}; 

  	sed -i -e "/${param}[[:space:]]*=.*/d" ${file}; 
}

Icm_config_xml_setup () 
{
	local open_tag;
	local close_tag;
	local config_file;

	config_file=${ICM_CONFIG_PATH}/icm_config.xml

 	open_tag="<IcFolderLocation>";
 	close_tag="</IcFolderLocation>"; 
 	val="$ICS_PATH";
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};
}

analyzer_log_ini_setup () 
{
	local param;
	local val;
	local config_file;

	config_file=${ICM_CONFIG_PATH}/icm_log4cpp.properties

	param="log4cpp.category.icm";
	val="DEBUG, rollingIcmLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.unitTests";
	val="DEBUG, rollingIcmUnitTestsLog";
	change_param_value "${param}" "${val}" ${config_file};
    
	param="log4cpp.category.icm.connectionManager";
	val="DEBUG, rollingIcmConnectionManagerLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.filterManager";
	val="DEBUG, rollingIcmFilterManagerLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.provisioningManager";
	val="DEBUG, rollingIcmProvisioningManagerLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.feisHandler";
	val="DEBUG, rollingIcmFeisHandlerLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.ipsClientHandler";
	val="DEBUG, rollingIcmIpsClientHandlerLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.ipsServerHandler";
	val="DEBUG, rollingIcmIpsServerHandlerLog";
	change_param_value "${param}" "${val}" ${config_file};

    param="log4cpp.category.icm.fileSystemManager";
	val="DEBUG, rollingIcmFileSystemManagerLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.niagaraHandler";
	val="DEBUG, rollingIcmNiagaraHandlerLog";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.category.icm.preformanceManager";
	val="DEBUG, rollingIcmPreformanceManagerLog";
	change_param_value "${param}" "${val}" ${config_file};
	    
	param="log4cpp.appender.rollingIcmLog.fileName";
	val="${LOG_DIR}/icm.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmUnitTestsLog.fileName";
	val="${LOG_DIR}/icm_unit_tests.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmConnectionManagerLog.fileName";
	val="${LOG_DIR}/icm_connection_manager.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmFilterManagerLog.fileName";
	val="${LOG_DIR}/icm_filter_manager.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmProvisioningManagerLog.fileName";
	val="${LOG_DIR}/icm_provisioning_manager.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmFeisHandlerLog.fileName";
	val="${LOG_DIR}/icm_feis_handler.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmIpsClientHandlerLog.fileName";
	val="${LOG_DIR}/icm_ips_client_handler.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmIpsServerHandlerLog.fileName";
	val="${LOG_DIR}/icm_ips_server_handler.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmFileSystemManagerLog.fileName";
	val="${LOG_DIR}/icm_file_system_manager.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmNiagaraHandlerLog.fileName";
	val="${LOG_DIR}/icm_niagara_handler.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4cpp.appender.rollingIcmPreformanceManagerLog.fileName";
	val="${LOG_DIR}/icm_preformance_manager.log";
	change_param_value "${param}" "${val}" ${config_file};
}


Main () 
{
	analyzer_log_ini_setup;
  	Icm_config_xml_setup;
}

Main $*
