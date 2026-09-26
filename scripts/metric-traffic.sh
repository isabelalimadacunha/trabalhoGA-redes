#!/bin/bash
# capture routing packets on r1 and measure rate
SCENARIO=$1
DUR=${2:-60}
OUT=results/$SCENARIO
mkdir -p $OUT

case $SCENARIO in
    rip)  FILTER="udp port 520" ;;
    ospf) FILTER="proto ospf" ;;
    bgp)  FILTER="tcp port 179" ;;
    *)    echo "invalid scenario: $SCENARIO"; exit 1 ;;
esac

echo "capturing $DUR seconds on r1, filter: $FILTER"
ip netns exec r1 timeout $DUR tcpdump -i any -s 0 -n -w $OUT/control.pcap $FILTER 2>/dev/null

# pcap has a 24 byte header plus 16 bytes per packet
PKTS=$(tcpdump -r $OUT/control.pcap 2>/dev/null | wc -l)
SIZE=$(stat -c %s $OUT/control.pcap)
BYTES=$(( SIZE - 24 - 16 * PKTS ))
RATE=$(( BYTES * 8 / DUR ))

echo "scenario,seconds,packets,bytes,bits_per_second" > $OUT/traffic.csv
echo "$SCENARIO,$DUR,$PKTS,$BYTES,$RATE" >> $OUT/traffic.csv
cat $OUT/traffic.csv
