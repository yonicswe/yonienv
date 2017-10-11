#!/bin/bash
echo "----------------------------------------------------------"
echo "sudo NTI_CONFIG_PATH=${NTI_CONFIG_PATH} LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${LD_LIBRARY_PATH}/Analyzer" 
echo "----------------------------------------------------------"
sudo NTI_CONFIG_PATH=${NTI_CONFIG_PATH} LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${LD_LIBRARY_PATH}/Analyzer 
