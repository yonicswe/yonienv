#!/bin/bash
yonienv=$(awk 'BEGIN{FS="="}/yonienv=/{  print $2}' ~/.bashrc | sed 's/;//');
source ${yonienv}/bashrc_tags.sh

includeTagdir=(./libibverbs)
includeTagdir+=(./librdmacm)
includeTagdir+=(./providers)
includeTagdir+=(./kernel-headers)
# includeTagdir+=(./providers/mlx5)
# includeTagdir+=(./providers/mlx4)
# includeTagdir+=(./providers/rxe)
includeTagdir+=(./ccan)
# excludeTagdir=(./build);
# excludeTagdir+=(+++ ./someotherdir);
tagme_base includeTagdir[@] excludeTagdir[@]
