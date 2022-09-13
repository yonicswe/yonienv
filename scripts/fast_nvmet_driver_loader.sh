#!/bin/sh

. ./cyc_helpers_common.sh

read -p "copy to both nodes [N|y]" ans
if [[ "${ans}" == "y" ]] ; then 
    echo -e "\t\t\tdoing both nodes";
    echo -e "\t\t\t----------------";
else
    echo -e "\t\t\tdoing only node a";
    echo -e "\t\t\t-----------------";
fi;

echo -e "\033[1;35m getting modules path from nodes\033[0m";
echo "./run_core_a.sh find /cyc_software_0/ /cyc_software_1/ -name modules"
drivers_a=`./run_core_a.sh find /cyc_software_0/ /cyc_software_1/ -name modules`

if [[ "${ans}" == "y" ]] ; then
    echo "./run_core_b.sh find /cyc_software_0/ /cyc_software_1/ -name modules"
    drivers_b=`./run_core_b.sh find /cyc_software_0/ /cyc_software_1/ -name modules`
fi;

new_driver=`find ../../../$CYC_OBJ_DIR/ -name PNVMeT | tail -1`
echo -e "new_driver=\"${new_driver}\"";

# echo "drivers_a: ${drivers_a}";
# echo "drivers_b: ${drivers_b}";

# echo "Old driver on node A"
# ./run_core_a.sh ls -ltr $drivers_a/nvmet*
# echo "Old driver on node B"
# ./run_core_b.sh ls -ltr $drivers_a/nvmet*
# echo "New driver in $new_driver"
# ls -ltr $new_driver/drivers/nvme/target/nvmet*.ko

# read -p "About to copy the driver from $new_driver to the nodes. Press enter to continue"
echo "copy driver from $new_driver to the nodes."

echo "find $new_driver/drivers/nvme/target/nvmet*.ko"
files=`find $new_driver/drivers/nvme/target/nvmet*.ko`
# echo "files : {${files[@]}}";


for i in ${files} ; do
    filename=`echo $i | rev | cut -f1 -d '/' | rev`;
    echo -e "\033[0;30m./scp_core_to_a.sh $i\033[0m";
    ./scp_core_to_a.sh $i;
    for drv in $drivers_a ; do
        echo -e "\033[1;30m./run_core_a.sh sudo cp $filename $drv/\033[0m";
        ./run_core_a.sh sudo cp $filename $drv/;
    done;
    if [[ "${ans}" == "y" ]] ; then
        echo -e "\033[1;30m./scp_core_to_b.sh $i\033[0m";
        ./scp_core_to_b.sh $i;
        for drv in ${drivers_b} ; do
            echo -e "\033[1;30m./run_core_b.sh sudo cp $filename $drv/\033[0m";
            ./run_core_b.sh sudo cp $filename $drv/;
        done;
    fi;
done
echo "Reboot both nodes."
./reboot_core.sh

# read -p "About to reboot the nodes. Press enter to continue"
#./test_ha/test_ha_ndu.sh
