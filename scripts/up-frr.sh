#!/bin/bash
SCENARIO=$1

if [ -z "$SCENARIO" ]; then
    echo "usage: sudo bash scripts/up-frr.sh ospf|rip|bgp"
    exit 1
fi

case $SCENARIO in
    ospf) DAEMON=ospfd ;;
    rip)  DAEMON=ripd ;;
    bgp)  DAEMON=bgpd ;;
    *)    echo "invalid scenario: $SCENARIO"; exit 1 ;;
esac
# kill frr daemons if running

bash "$(dirname "$0")/down-frr.sh"

# routers

for r in r1 r2 r3 r4 r5 r6; do
    install -d -o frr -g frr -m 750 /etc/frr/$r
    rm -f /etc/frr/$r/ripd.conf /etc/frr/$r/ospfd.conf /etc/frr/$r/bgpd.conf /etc/frr/$r/daemons
    install -o frr -g frr -m 640 configs/$SCENARIO/$r.conf /etc/frr/$r/frr.conf
    echo "service integrated-vtysh-config" > /etc/frr/$r/vtysh.conf
    chown frr:frr /etc/frr/$r/vtysh.conf
    #daemons.
    ip netns exec $r /usr/lib/frr/mgmtd -d -N $r -A 127.0.0.1 -u frr -g frr
    sleep 1
    ip netns exec $r /usr/lib/frr/zebra -d -N $r -A 127.0.0.1 -s 90000000 -u frr -g frr
    sleep 1
    ip netns exec $r /usr/lib/frr/$DAEMON -d -N $r -A 127.0.0.1 -u frr -g frr
    sleep 1
    ip netns exec $r vtysh -N $r -f /etc/frr/$r/frr.conf
    echo "$r up"
done

echo "configs installed for scenario $SCENARIO"