#!/bin/bash
yonienv=$(awk 'BEGIN{FS="="}/yonienv=/{  print $2}' ~/.bashrc | sed 's/;//');
source ${yonienv}/bashrc_tags.sh

includeTagdir=(./libibverbs/)
includeTagdir+=(./libmlx5/)
includeTagdir+=(./rdma-core/)

# excludeTagdir+=(./build);
# excludeTagdir+=(+++ ./someotherdir);
tagme_base includeTagdir[@] excludeTagdir[@]
