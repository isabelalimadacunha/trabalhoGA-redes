#!/bin/bash
# count routes held by each router
SCENARIO=$1
OUT=results/$SCENARIO
mkdir -p $OUT

echo "router,routes" > $OUT/table-size.csv
for r in r1 r2 r3 r4 r5 r6; do
    n=$(ip netns exec $r ip route | wc -l)
    echo "$r,$n" >> $OUT/table-size.csv
done

cat $OUT/table-size.csv
