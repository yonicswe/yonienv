#!/bin/bash
# Script to extract base OCS code and apply patches without building
# Usage: ./apply_patches.sh <output_dir>

set -e

OUTPUT_DIR=${1:-./ocs_patched}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_DIR="${SCRIPT_DIR}/patches"
OCS_ARCHIVE="/home/cyc/devel/cyclone/source/third_party/binaries/key_val/ocs/ocs_sdk_pkg_14.4.792.0.tgz"

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
