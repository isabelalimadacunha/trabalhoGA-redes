#!/bin/bash
# average round trip time from the LAN of r1 to every other LAN
SCENARIO=$1
OUT=results/$SCENARIO
mkdir -p $OUT

echo "source,destination,avg_rtt_ms" > $OUT/delay.csv
for d in 2 3 4 5 6; do
    avg=$(ip netns exec r1 ping -c 10 -i 0.2 -q -I 192.168.1.1 192.168.$d.1 | tail -1 | cut -d/ -f5)
    echo "r1,r$d,$avg" >> $OUT/delay.csv
done
cat $OUT/delay.csv
