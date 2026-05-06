#!/bin/bash
#set -e

VALID_ARGS=$(getopt -o p:c:v --long num_ports:,num_ctrls:,verbose -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -p | --num_ports)
        NUM_PORTS=$2
        shift 2
        ;;
    -c | --num_ctrls)
        NUM_CTRLS=$2
        shift 2
        ;;
    -v | --verbose)
    	VERBOSE=1
	shift;
	;;
    --) shift; 
        break 
        ;;
  esac
done

echo "NUM_PORTS = ${NUM_PORTS}"
echo "NUM_CTRLS = ${NUM_CTRLS}"

if [ -z "$NUM_CTRLS" ]
then
      echo "Argument NUM_PORTS is missing"
      exit 1
fi

if [ -z "$NUM_CTRLS" ]
then
	echo "Argument NUM_CTRLS is missing"
        exit 1
fi

fail_on_signal=1
debug=1

NT_DEBUC=/xtremapp/debuc/127.0.0.1\:31010/commands/nt
if [ ! -e "$NT_DEBUC" ]; then
    NT_DEBUC=/xtremapp/debuc/127.0.0.1\:31011/commands/nt
fi
echo "NT_DEBUC: $NT_DEBUC"

handle_chld() {
	local tmp=()
	echo "signal handler started"
	for i in ${!pids[@]}; do
	if [ ! -d /proc/${pids[i]} ]; then
		#wait ${pids[i]}
		#unset pids[i]
		#if [ $debug -eq 1 ]; then
		#	tail /sys/module/nvmet/parameters/nr_*     
	#		debug=0
#		fi
		if [ $fail_on_signal -eq 1 ]; then
			echo "Stopped ${pids[i]}; exit code: $?"
			exit 
		fi
	fi
	echo "signal handler stoped"
	done
}

#set -o monitor
set +m
#trap "handle_chld" CHLD

if [ "$VERBOSE" == "1" ]; then
	echo "Cleanup former test"
fi

pkill -9 a.out
echo "set active" > "$NT_DEBUC"

NUM_IPS=$NUM_PORTS
CTRLS_PER_IP=$(($NUM_CTRLS / NUM_PORTS))

echo "Preparing test configuration"
for (( i = 0; i < $NUM_IPS; i++ ))
do
        ip="192.168.$(($i / 255)).$(($i % 255))"
        ip addr add $ip/20 dev lo > /dev/null 2>/dev/null
        echo "add port address=$ip type=tcp is_local" > "$NT_DEBUC"
done

echo "CTRLS_PER_IP = ${CTRLS_PER_IP}"

SUBSYS=`ls /sys/kernel/config/nvmet/subsystems`
echo "SUBSYS = $SUBSYS"

./nvme_tcp_prevent_ndu_starvation.sh 

#echo "Running test $0 step 1"
for c in $(eval echo "{1..$CTRLS_PER_IP}")
do
	for (( i = 0; i < $NUM_IPS; i++ )) 
	do
		ip="192.168.$(($i / 255)).$(($i % 255))"

		taskset 0x00010000 ./a.out --ip $ip --local_ip $ip --portnum 4420 --hostnqn nqn.2014-08.org.nvmexpress:uuid:nc9127122 --subsysnqn $SUBSYS --test_type idle --num_queues 21 --ignore_connection_reset true > /dev/null 2>&1 &
		pids+=($!)
	done
done

echo "All hostapp instances are up"


EXPECTED_SQS=$(($NUM_IPS * $CTRLS_PER_IP * 21))

while [ "$(cat /sys/module/nvmet/parameters/nr_sqs)" != "$EXPECTED_SQS" ]; 
do : 
	sleep 1
	CUR_SQS=`cat /sys/module/nvmet/parameters/nr_sqs`
	echo "CUR_SQS $CUR_SQS EXPECTED_SQS $EXPECTED_SQS"
done

echo "All queues are connect"

NUM_CTRLS=`cat /sys/module/nvmet/parameters/nr_ctrls`
NUM_SQS=`cat /sys/module/nvmet/parameters/nr_sqs`

# stop watching CHLD SIG before set inactive
fail_on_signal=0

#journalctl -kaf | grep nvmet > test_scale_journal.txt &
#journal_pid=($!)
#journalctl -af SUB_COMPONENT=nt > test_scale_nt_logs.txt &
#nt_logs_pid=($!)

journalctl -kf --grep=nvmet > test_scale_journal.txt &
journal_pid=$!

journalctl -f SUB_COMPONENT=nt > test_scale_nt_logs.txt &
nt_logs_pid=$!

#echo "Running test $0 step 2"
TEARDOWN_TIME=$( TIMEFORMAT="%R"; { time ./set_inactive_wait.sh; } 2>&1 )
echo "set inactive done"

echo "NUM_CTRLS $NUM_CTRLS NUM_SQS $NUM_SQS TEARDOWN_TIME $TEARDOWN_TIME"

trap "" CHLD

echo "Cleanup test"
#kill $journal_pid 2>/dev/null
#kill $nt_logs_pid 2>/dev/null

kill $journal_pid 2>/dev/null
wait $journal_pid 2>/dev/null
kill $nt_logs_pid 2>/dev/null
wait $nt_logs_pid 2>/dev/null

wc -l test_scale_nt_logs.txt test_scale_journal.txt
grep -a "remove_all_ports done" test_scale_nt_logs.txt 

for i in ${!pids[@]}; do
	kill ${pids[i]} 2>/dev/null
done

for i in ${!pids[@]}; do
        wait ${pids[i]} 2>/dev/null
done

echo "Cleanup test configuration"
for (( i = 0; i < $NUM_IPS; i++ ))
do
        ip="192.168.$(($i / 255)).$(($i % 255))"
        # ip addr del $ip/20 dev lo
        echo "del port address=$ip type=tcp is_local" > "$NT_DEBUC"
done

echo "set active" > "$NT_DEBUC"

