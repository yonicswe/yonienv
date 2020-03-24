export PRJ_NAME="OFED kernel"

includeTagdir+=(./include/)
includeTagdir+=(./drivers/net/ethernet/mellanox/)
includeTagdir+=(./drivers/infiniband/core)
includeTagdir+=(./drivers/infiniband/debug)
includeTagdir+=(./drivers/infiniband/sw)
includeTagdir+=(./drivers/infiniband/ulp)
# includeTagdir+=(./drivers/infiniband/net)
# includeTagdir+=(./drivers/infiniband/nvme)
# includeTagdir+=(./drivers/infiniband/scsi)
# includeTagdir+=(./drivers/infiniband/vfio)
includeTagdir+=(./drivers/infiniband/hw/mlx4)
includeTagdir+=(./drivers/infiniband/hw/mlx5)
includeTagdir+=(/lib/modules/`uname -r`/build)

excludeTagdir+=(./drivers/infiniband/ulp/ipoib_* )
# excludeTagdir+=(+++ ./buildlib);
# excludeTagdir+=(+++ ./someotherdir);
