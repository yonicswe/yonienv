#!/bin/bash
# Script to extract base OCS code, apply patches, and optionally build the driver
# Usage: ./apply_patches.sh <output_dir> [--build]
#
# For building, these environment variables can be set:
#   KERNEL_BUILD_DIR - path to kernel headers (default: auto-detect from obj_Release)
#   SCST_BASE_DIR - path to SCST installation (default: auto-detect from obj_Release)
#   PNVMET_TARGET_DIR - path to PNVMeT target (default: auto-detect from obj_Release)

set -e

OUTPUT_DIR=${1:-./ocs_patched}
BUILD_DRIVER=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_DIR="${SCRIPT_DIR}/patches"
OCS_ARCHIVE="/home/cyc/devel/cyclone/source/third_party/binaries/key_val/ocs/ocs_sdk_pkg_14.4.792.0.tgz"

# Parse arguments
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD_DRIVER=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 <output_dir> [--build]"
            exit 1
            ;;
    esac
done

# Auto-detect paths if not provided
if [ "${BUILD_DRIVER}" = "1" ]; then
    CYC_PLATFORM="${SCRIPT_DIR}/../../../../../../../obj_Release/third_party"
    
    KERNEL_BUILD_DIR=${KERNEL_BUILD_DIR:-"/home/cyc/devel/cyclone/source/linux"}
    SCST_BASE_DIR=${SCST_BASE_DIR:-"${CYC_PLATFORM}/scst"}
    PNVMET_TARGET_DIR=${PNVMET_TARGET_DIR:-"${CYC_PLATFORM}/PNVMeT/src/PNVMeT/drivers/nvme/target"}

    echo "Build configuration:"
    echo "  KERNEL_BUILD_DIR: ${KERNEL_BUILD_DIR}"
    echo "  SCST_BASE_DIR: ${SCST_BASE_DIR}"
    echo "  PNVMET_TARGET_DIR: ${PNVMET_TARGET_DIR}"
    echo ""

    # Verify paths exist
    if [ ! -d "${KERNEL_BUILD_DIR}" ]; then
        echo "Error: KERNEL_BUILD_DIR not found: ${KERNEL_BUILD_DIR}"
        exit 1
    fi
    if [ ! -d "${SCST_BASE_DIR}" ]; then
        echo "Error: SCST_BASE_DIR not found: ${SCST_BASE_DIR}"
        exit 1
    fi
    if [ ! -d "${PNVMET_TARGET_DIR}" ]; then
        echo "Error: PNVMET_TARGET_DIR not found: ${PNVMET_TARGET_DIR}"
        exit 1
    fi
fi

echo "Extracting base OCS code to ${OUTPUT_DIR}..."
mkdir -p "${OUTPUT_DIR}"
tar -xzf "${OCS_ARCHIVE}" -C "${OUTPUT_DIR}"

cd "${OUTPUT_DIR}"
# The archive extracts files directly, not into a subdirectory
OCS_SRC_DIR="."
echo "Applying patches to ${OUTPUT_DIR}..."

# Apply patches in the same order as CMakeLists.txt
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__build-env.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__build-params.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__enable_fw_upgrade.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__sfp.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__fw_dump.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__nvme_targetport2.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__nvmet_fc_rcv_ls_req_ext.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__multithreaded_init_done.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__ocs_cq_limits.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__trigger-dump-on-failure.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__ocs-nvme-ls-fix.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__max_sectors.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__add_node_cnt.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__debugfs_on_all_sports.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__fpin_rcv_api_compat.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Dell__sync_thread_affinity-v3.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__cpu_mask_string_param.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__loglevel_parameter_writeable.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__lun-trunk-fix_pssldf-57228.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__no_sleep_on_panic.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Dell__PSSL14I-269.patch"
patch -F0 -E -p1 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__ocs_sport_logo_fix.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__ocs_nvme_wait_bcknd_rport_rel.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__ocs_nvme_release_xri.patch"
patch -F0 -E -p0 --backup-if-mismatch -i "${PATCH_DIR}/Broadcom__ocs-gffid-whitelist-bypass.patch"

echo "Done! Patched code is in ${OUTPUT_DIR}"

if [ "${BUILD_DRIVER}" = "1" ]; then
    echo ""
    echo "Building OCS driver..."
    cd driver/linux/ocs_fc_scst
    make -C . KDIR=${KERNEL_BUILD_DIR} DESTDIR=${SCST_BASE_DIR}/install PNVMET_TARGET_DIR=${PNVMET_TARGET_DIR} EMC_DRIVER=1 NVME_MODULE=kernel
    echo "Build complete! Driver module is in driver/linux/ocs_fc_scst/ocs_fc_scst.ko"
fi
