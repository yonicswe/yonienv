PRJ_NAME="upstream kernel"

includeTagdir=(./include/)
includeTagdir+=(./drivers/infiniband/core/)
includeTagdir+=(./drivers/infiniband/hw/mlx4/)
includeTagdir+=(./drivers/infiniband/hw/mlx5/)
includeTagdir+=(./drivers/net/ethernet/mellanox/)
includeTagdir+=(./drivers/nvme)
includeTagdir+=(./fs)
# includeTagdir+=(./net/ipv4/)

# excludeTagdir=(./build);
# excludeTagdir+=(+++ ./buildlib);
# excludeTagdir+=(+++ ./someotherdir);
