#!/bin/bash

KVER=$(uname -r)
INSTALL_TARGET=/lib/modules/$KVER/kernel


INSTALL_SOURCE=
# INSTALL_SOURCE=(drivers/infiniband/core)
# INSTALL_SOURCE+=(drivers/infiniband/ulp/iser)
# INSTALL_SOURCE+=(drivers/infiniband/ulp/isert)
# INSTALL_SOURCE+=(drivers/infiniband/sw/rxe)
# INSTALL_SOURCE+=(drivers/net/ethernet/mellanox/mlx4)

cp_modules_to_lib_modules ()
{
    for d in ${INSTALL_SOURCE[@]} ; do
        for m in $(find $d -name *.ko)  ; do
            echo "sudo cp -f $m $INSTALL_TARGET/$m"
            sudo cp -f $m $INSTALL_TARGET/$m
        done
    done | column -t

    set -x
    sudo depmod -aA
    set +x 
}

main ()
{
    local mod=${1:-rxe};

    if [ "${mod}" == "rxe" ] ; then 
        INSTALL_SOURCE=(drivers/infiniband/sw/rxe)
    elif [ "${mod}" == "core" ]  ; then             
        INSTALL_SOURCE=(drivers/infiniband/core)
    elif [ "${mod}" == "mlx5ib" ]  ; then             
        INSTALL_SOURCE=(drivers/infiniband/hw/mlx5)
    elif [ "${mod}" == "mlx5core" ]  ; then             
        INSTALL_SOURCE=(drivers/net/ethernet/mellanox/mlx5/core)
    elif [ "${mod}" == "mlx5" ]  ; then             
        INSTALL_SOURCE=(drivers/infiniband/hw/mlx5)
        INSTALL_SOURCE+=(drivers/net/ethernet/mellanox/mlx5/core)
    elif [ "${mod}" == "mlx4" ]  ; then             
        INSTALL_SOURCE=(drivers/infiniband/hw/mlx4)
        INSTALL_SOURCE+=(drivers/net/ethernet/mellanox/mlx4)
    elif [ "${mod}" == "mlx" ]  ; then             
        INSTALL_SOURCE=(drivers/infiniband/core)
        INSTALL_SOURCE+=(drivers/infiniband/hw/mlx4)
        INSTALL_SOURCE+=(drivers/net/ethernet/mellanox/mlx4)
        INSTALL_SOURCE+=(drivers/infiniband/hw/mlx5)
        INSTALL_SOURCE+=(drivers/net/ethernet/mellanox/mlx5/core)
    else
        echo "no module specified for install"
        return;
    fi

    cp_modules_to_lib_modules;
}

main $@
