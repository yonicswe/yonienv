#!/bin/bash
yonienv=$(awk 'BEGIN{FS="="}/yonienv=/{  print $2}' ~/.bashrc | sed 's/;//');
source ${yonienv}/bashrc_tags.sh

includeTagdir=(./include/)
includeTagdir+=(./drivers/infiniband/)
# includeTagdir+=(./drivers/infiniband/ulp/iser)
# includeTagdir+=(./drivers/infiniband/hw/mlx5/)
# includeTagdir+=(./drivers/infiniband/sw/rxe/)
# includeTagdir+=(./drivers/infiniband/core/)
# includeTagdir+=(./drivers/net/ethernet/mellanox/mlx5/core/)
includeTagdir+=(./drivers/net/ethernet/mellanox/)
includeTagdir+=(./net/ipv4/)

# excludeTagdir=(./build);
# excludeTagdir+=(+++ ./buildlib);
# excludeTagdir+=(+++ ./someotherdir);


tagme_base includeTagdir[@] excludeTagdir[@]
