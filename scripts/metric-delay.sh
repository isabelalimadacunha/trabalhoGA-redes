#!/bin/bash
# average round trip time from host h1 to every other host
SCENARIO=$1
OUT=results/$SCENARIO
mkdir -p $OUT

echo "source,destination,avg_rtt_ms" > $OUT/delay.csv
for d in 2 3 4 5 6; do
    avg=$(ip netns exec h1 ping -c 10 -i 0.2 -q 192.168.$d.10 | tail -1 | cut -d/ -f5)
    echo "h1,h$d,$avg" >> $OUT/delay.csv
done
cat $OUT/delay.csv
