#!/bin/bash
yonienv=$(awk 'BEGIN{FS="="}/yonienv=/{  print $2}' ~/.bashrc | sed 's/;//');
source ${yonienv}/bashrc_tags.sh

includeTagdir+=(./include/)
includeTagdir+=(./drivers/)

excludeTagdir+=(./drivers/infiniband/ulp/ipoib_* )
# excludeTagdir+=(+++ ./buildlib);
# excludeTagdir+=(+++ ./someotherdir);
tagme_base includeTagdir[@] excludeTagdir[@]
