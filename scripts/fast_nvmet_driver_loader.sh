#!/bin/sh



. ./cyc_helpers_common.sh

VERBOSE=1;
verbose_log() {
	if [[ -v VERBOSE ]]; then
		echo $1
	fi
}

if [ -v TTT ]; then
    echo "V"
fi

if [ -z "$TTT" ]; then
    echo "N"
fi

if [ -z "$ONLY_B" ]; then
    echo "Working on node A"
    drivers_a=`./run_core_a.sh sudo find /cyc_software_0/ /cyc_software_1/ -name modules`
    verbose_log "Existing drivers on Node A are on $drivers_a"
fi

if [ -z "$ONLY_A" ]; then
    echo "Working on node B"
    drivers_b=`./run_core_b.sh sudo find /cyc_software_0/ /cyc_software_1/ -name modules`
    verbose_log "Existing drivers on Node A are on $drivers_b"
fi

new_driver="../../../$CYC_OBJ_DIR/package/final/top_host/cyc_host/cyc_common/modules"
#new_driver=`fin`d ../../../$CYC_OBJ_DIR/ -name PNVMeT | tail -1`
new_qla_driver="../../../$CYC_OBJ_DIR/package/final/top_host/cyc_host/cyc_common/modules/qla2xxx.ko"

if [[ -v VERBOSE ]]; then
	echo "Old driver on node A"

	./run_core_a.sh ls -ltr $drivers_a/nvmet*

	echo "Old driver on node B"

	./run_core_b.sh ls -ltr $drivers_a/nvmet*

	echo "New driver in $new_driver"

	ls -ltr $new_driver/nvmet*.ko

	read -p "About to copy the driver from $new_driver to the nodes. Press enter to continue"
fi;


files=`find $new_driver/nvmet*.ko`

if [ -z "$ONLY_B" ]; then
    echo "Copy QLA driver to node A"
	./scp_core_to_a.sh $new_qla_driver
	./run_core_a.sh sudo cp -v $drivers_a/qla2xxx.ko qla2xxx.ko.old
	./run_core_a.sh sudo cp -v qla2xxx.ko $drivers_a/
fi

if [ -z "$ONLY_A" ]; then
    echo "Copy QLA driver to node B"
    ./scp_core_to_b.sh $new_qla_driver
    ./run_core_b.sh sudo cp -v $drivers_b/qla2xxx.ko qla2xxx.ko.old
    ./run_core_b.sh sudo cp -v qla2xxx.ko $drivers_a/
fi

if [[ -v SKIP_NVMET ]]; then
	echo "Skipping nvmet drivers"
	exit 0
fi

for i in ${files} ; do

	filename=`echo $i | rev | cut -f1 -d '/' | rev`;
    echo "Copy $filename driver";

	if [ -z "$ONLY_B" ]; then
		./scp_core_to_a.sh $i
		./run_core_a.sh sudo cp -v $drivers_a/$filename $filename.old
		./run_core_a.sh sudo cp -v $filename $drivers_a/
	fi

	if [ -z "$ONLY_A" ]; then
		./scp_core_to_b.sh $i
		./run_core_b.sh sudo cp -v $drivers_b/$filename $filename.old
		./run_core_b.sh sudo cp -v $filename $drivers_b/
	fi
done

if [ -z "$RELOAD_DRIVERS" ]; then
	echo "Skip driver reload"
fi


echo "Reloading drivers on the cluster"

if [ -z "$ONLY_B" ]; then
	./stack_down_hard_only_a.sh
	./stack_up_only_a.sh
fi

if [ -z "$ONLY_A" ]; then
	./stack_down_hard_only_b.sh
	./stack_up_only_b.sh
fi

