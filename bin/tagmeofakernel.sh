export PRJ_NAME="OFED kernel"

includeTagdir+=(./include/)
includeTagdir+=(./drivers/)

excludeTagdir+=(./drivers/infiniband/ulp/ipoib_* )
# excludeTagdir+=(+++ ./buildlib);
# excludeTagdir+=(+++ ./someotherdir);
