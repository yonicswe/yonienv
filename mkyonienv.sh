#!/bin/bash 
export yonienv=$(readlink -f .)
source commonyonienv.sh
main $@;
