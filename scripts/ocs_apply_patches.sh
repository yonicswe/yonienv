#!/bin/bash
# Script to extract base OCS code and apply patches without building
# Usage: ./ocs_apply_patches.sh <output_dir> [patches_dir] [cmakelists_path]
#
# Parameters:
#   output_dir      - Directory where patched code will be extracted (default: ./ocs_patched)
#   patches_dir     - Directory containing patch files (default: derived from CMakeLists.txt location)
#   cmakelists_path - Path to CMakeLists.txt to read patches from (default: /home/cyc/devel/cyclone/source/third_party/cyc_platform/src/third_party/BRCM_OCS/CMakeLists.txt)

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
set -e

OUTPUT_DIR=${1:-./ocs_patched}
if ! [[ -v CYC_FOLDER ]] ; then
    echo "cyclone_folder not set !! use rd or dellclusterruntimeenvset and try again";
    exit -1;
fi;

cyclone_folder=${CYC_FOLDER};

CMAKELISTS_PATH=${3:-${cyclone_folder}/source/third_party/cyc_platform/src/third_party/BRCM_OCS/CMakeLists.txt}

# If patches_dir is provided, use it; otherwise derive it from CMakeLists.txt location
if [ -n "$2" ]; then
    PATCH_DIR="$2"
else
    # Derive patches directory from CMakeLists.txt location
    CMAKELISTS_DIR="$(dirname "$CMAKELISTS_PATH")"
    PATCH_DIR="${CMAKELISTS_DIR}/patches"
fi

OCS_ARCHIVE=${4};

#if [[ -v OCS_ARCHIVE ]] ; then
    #echo "OCS_ARCHIVE defined";
    #exit -1;
#fi;
 
#if [ -z "${OCS_ARCHIVE}" ] ; then
    #echo "did not find sdk!! use dellbroadcomsdk and retry";
    #exit -1;
#fi;

#OCS_ARCHIVE="${cyclone_folder}/source/third_party/binaries/key_val/ocs/ocs_sdk_pkg_14.4.792.0.tgz"
OUTPUT_DIR=$(readlink -f ${OUTPUT_DIR})

echo "usage : dellbroadcombuilddriversourcetree <output_dir> <patch_dir> <cmakefile>";
echo "==============================================================================";
echo "Using CMakeLists.txt from: ${CMAKELISTS_PATH}"
echo "Using patches directory: ${PATCH_DIR}"
echo "Using sdk : ${OCS_ARCHIVE}"
echo "Extracting base OCS code to ${OUTPUT_DIR}"

read -p "continue ? " ans;

mkdir -p "${OUTPUT_DIR}"
tar -xzf "${OCS_ARCHIVE}" -C "${OUTPUT_DIR}"

cd "${OUTPUT_DIR}"
# The archive extracts files directly, not into a subdirectory
OCS_SRC_DIR="."
echo "Applying patches to ${OUTPUT_DIR}..."

# Extract and apply patches from CMakeLists.txt
# Parse the PATCH_COMMAND lines and execute them
PATCH_COMMANDS=$(sed -n '/PATCH_COMMAND patch/,/CONFIGURE_COMMAND/p' "$CMAKELISTS_PATH" | grep 'patch' | sed 's/^[ \t]*//' | sed 's/^PATCH_COMMAND //' | tr '\n' ' ')

if [ -z "$PATCH_COMMANDS" ]; then
    echo "Error: No patch commands found in CMakeLists.txt"
    exit 1
fi

# Split by '&&' and apply each patch command
IFS='&&' read -ra PATCH_ARRAY <<< "$PATCH_COMMANDS"
for patch_cmd in "${PATCH_ARRAY[@]}"; do
    # Trim whitespace
    cmd=$(echo "$patch_cmd" | sed 's/^[ \t]*//' | sed 's/[ \t]*$//')
    
    # Skip empty commands
    if [ -z "$cmd" ]; then
        continue
    fi
    
    # Replace ${PATCH_DIR} with actual patches directory
    cmd=$(echo "$cmd" | sed "s|\${PATCH_DIR}|${PATCH_DIR}|g")
    
    echo -e "${RED}Executing: $cmd${NC}"
    eval $cmd
done

echo "Done! Patched code is in ${OUTPUT_DIR}"
