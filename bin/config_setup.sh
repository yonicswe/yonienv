#!/bin/bash
#
#  setup the config of the current task  
#  by changing values in the config files to match the 
#  consolidated environment, namely 
#  *  IPS_Analyzer.xml 
#	  +  bundle path : 	${HOME}/work/<task>/config/bundle
#	  +  webcatagory path : ${HOME}/work/<task>/config/
#	  +  webEngine config file  : ${HOME}/work/<task>/config/
#     +  etc..
#  *  analyzer_log.ini 
#	  +  paths of log files : ${HOME}/work/<task>/config/logs
#  *  AppConfig.xml 
#	  +  icid : 9 
#  *  WebEngineCfg.xml
#	  +  ${HOME}/work/<task>/config/top_level_domains.txt
#	  +  ${HOME}/work/<task>/config/date_templates.txt
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

analyzer_log_ini_setup () 
{
	local param;
	local val;
	local config_file;

	config_file=${NTI_CONFIG_PATH}/analyzer_log.ini

	param="log4j.category.analyzer";
	val="ERROR, rolling";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.category.analyzer.web_engine";
	val="DEBUG, rollingWebEngine";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.category.analyzer.web_engine.out";
	val="DEBUG, rolling, rootAppender, rollingWebEngineOut";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rolling.fileName";
	val="${LOG_DIR}/Analyzer.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingWebEngine.fileName";
	val="${LOG_DIR}/WebEngine.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingWebEngineOut.fileName";
	val="${LOG_DIR}/wbeout.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingWebEngineOut.layout.ConversionPattern";
	val="%m%n";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingWebEngineStartup.fileName";
	val="${LOG_DIR}/WebEngineStartup.log";
	change_param_value "${param}" "${val}" ${config_file};
    
	param="log4j.appender.rollingWebEngineHostnames.fileName";
	val="${LOG_DIR}/WebEngineHostnamesIn.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingProto.fileName";
	val="${LOG_DIR}/proto.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingProto.layout.ConversionPattern";
	val="%m%n";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingProtoSent.fileName";
	val="${LOG_DIR}/proto-sent.log";
	change_param_value "${param}" "${val}" ${config_file};
	
	param="log4j.appender.rollingSystemDiagnostics.fileName";
	val="${LOG_DIR}/SystemDiagnostics.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingUuid.fileName";
	val="${LOG_DIR}/uuid.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingDataAdaptor.fileName";
	val="${LOG_DIR}/data-adaptor.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingProvisioning.fileName";
	val="${LOG_DIR}/provisioning.log";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingFlowHandler.fileName";
	val="${LOG_DIR}/webEngineFlowHandler.log";
	echo -e "change_param_value \"${param}\" \"${val}\" ${config_file}";
	change_param_value "${param}" "${val}" ${config_file};

	param="log4j.appender.rollingVoipLog.fileName";
	val="${LOG_DIR}/Voip.log";
	change_param_value "${param}" "${val}" ${config_file};

}



AppConfig_xml_setup () 
{
	local open_tag;
	local close_tag;
	local config_file;

	config_file=${NTI_CONFIG_PATH}/AppConfig.xml

 	open_tag="<gt:provisioningType>";
 	close_tag="</gt:provisioningType>"; 
 	val="Dummy"; 
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

 	open_tag="<gt:icId>"; 
 	close_tag="</gt:icId>"; 
 	val="9";
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

 	open_tag="<gt:icFolder>"; 
 	close_tag="</gt:icFolder>"; 
 	val="$ICS_PATH";
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};
}

IPS_Analyzer_xml_setup ()
{
	local open_tag_find;
	local close_tag_find;
	local config_file;
	local start_section;
	local end_section;

	config_file=${NTI_CONFIG_PATH}/IPS_Analyzer.xml

 	open_tag="<BundleDataFile.*>";
 	close_tag="</BundleDataFile.*>";
	val="${BUNDLE_PATH}/Bundle.dat"
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

 	open_tag="<BundleIdxFile.*>"; 
 	close_tag="</BundleIdxFile.*> ";
	val="${BUNDLE_PATH}/Bundle.idx"
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

 	open_tag="<CategoryDataFile.*>"; 
 	close_tag="</CategoryDataFile.*>";
	val="${NTI_CONFIG_PATH}/CategoryList.csv"
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file}; 

 	open_tag="<WebEngineConfig.*>"; 
 	close_tag="</WebEngineConfig.*>";
	val="${NTI_CONFIG_PATH}/WebEngineCfg.xml"
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file}; 

 	open_tag="<DAdaptorType.*>"; 
 	close_tag="</DAdaptorType.*>";
	val="Dummy";
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file}; 

 	open_tag="<BaseStorage.*>"; 
 	close_tag="</BaseStorage.*>";
	val="${TASK_PATH}/storage"
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file}; 

 	open_tag="<Ports.*>"; 
 	close_tag="</Ports.*>";
	start_section="<HTTP.*>";
	end_section="</HTTP.*>";
	val="65505,80,8080,7777,2056,3005,8888"
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file} ${start_section} ${end_section}; 

 	open_tag="<BasePath.*>"; 
 	close_tag="</BasePath.*>";
	start_section="<IPDR.*>";
	end_section="</IPDR.*>";
	val="${IPDRS_DIR}"
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file} ${start_section} ${end_section}; 

	open_tag="<IsWatchThreads.*>"; 
 	close_tag="</IsWatchThreads.*>";
	val="0";
  	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file}; 

} 

WebEngineCfg_xml_setup ()
{
	local open_tag;
	local close_tag;
	local config_file;

	config_file=${NTI_CONFIG_PATH}/WebEngineCfg.xml

 	open_tag="<TopLevelDomainsFile.*>"; 
 	close_tag="</TopLevelDomainsFile.*>";
 	val="${NTI_CONFIG_PATH}/top_level_domains.txt"; 
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

 	open_tag="<DateFormatsTemplate.*>"; 
 	close_tag="</DateFormatsTemplate.*>";
 	val="${NTI_CONFIG_PATH}/date_templates.txt"; 
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

 	open_tag="<ActivitySubtypesFile.*>"; 
 	close_tag="</ActivitySubtypesFile.*>";
 	val="${NTI_CONFIG_PATH}/activity_subtypes.xml"; 
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

 	open_tag="<Root.*>"; 
 	close_tag="</Root.*>";
 	val="${WBEIN_DIR}"; 
 	change_xml_value "${open_tag}" "${close_tag}" "${val}" ${config_file};

}


Main () 
{
  	AppConfig_xml_setup;
  	IPS_Analyzer_xml_setup;
	analyzer_log_ini_setup;
	WebEngineCfg_xml_setup;
}

Main $*
