#!/bin/bash
# time the network takes to recover after the link r1-r6 goes down
SCENARIO=$1
REPS=${2:-3}
OUT=results/$SCENARIO
mkdir -p $OUT

HOST=h1
DEST=192.168.5.10
LINK=r1-r6
MAXWAIT=300

echo "run,seconds" > $OUT/convergence.csv

for i in $(seq 1 $REPS); do
    ip netns exec r1 ip link set $LINK up
    echo "run $i: waiting for the network to settle"
    sleep 60

    ip netns exec r1 ip link set $LINK down
    t0=$(date +%s)

    ok=0
    while [ $ok -eq 0 ]; do
        if ip netns exec $HOST ping -c 1 -W 1 $DEST >/dev/null 2>&1; then
            ok=1
        fi
        # without the pause the ping loop starves the routing daemons
        sleep 0.5
        now=$(date +%s)
        if [ $(( now - t0 )) -ge $MAXWAIT ]; then
            break
        fi
    done

    t1=$(date +%s)
    if [ $ok -eq 1 ]; then
        secs=$(( t1 - t0 ))
    else
        secs="timeout"
    fi
    echo "$i,$secs" >> $OUT/convergence.csv
    echo "run $i: $secs"
done

ip netns exec r1 ip link set $LINK up
cat $OUT/convergence.csv