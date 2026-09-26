#!/bin/bash

for r in r1 r2 r3 r4 r5 r6; do
    ip netns del $r 2>/dev/null
done

# Add routers

for i in 1 2 3 4 5 6; do
    ip netns add r$i
    ip netns exec r$i sysctl -qw net.ipv4.ip_forward=1
    ip netns exec r$i ip link set lo up
    ip netns exec r$i ip addr add 172.16.0.$i/32 dev lo
    ip netns exec r$i ip link add lan1 type dummy
    ip netns exec r$i ip addr add 192.168.$i.1/24 dev lan1
    ip netns exec r$i ip link set lan1 up
done

# Add cable R1-R2

ip link add r1-r2 type veth peer name r2-r1
ip link set r1-r2 netns r1
ip link set r2-r1 netns r2
ip netns exec r1 ip addr add 10.0.12.1/30 dev r1-r2
ip netns exec r1 ip link set r1-r2 up
ip netns exec r2 ip addr add 10.0.12.2/30 dev r2-r1
ip netns exec r2 ip link set r2-r1 up
ip netns exec r1 tc qdisc add dev r1-r2 root netem delay 10ms
ip netns exec r2 tc qdisc add dev r2-r1 root netem delay 10ms

# Add cable R2-R3

ip link add r2-r3 type veth peer name r3-r2
ip link set r2-r3 netns r2
ip link set r3-r2 netns r3
ip netns exec r2 ip addr add 10.0.23.1/30 dev r2-r3
ip netns exec r2 ip link set r2-r3 up
ip netns exec r3 ip addr add 10.0.23.2/30 dev r3-r2
ip netns exec r3 ip link set r3-r2 up
ip netns exec r2 tc qdisc add dev r2-r3 root netem delay 10ms
ip netns exec r3 tc qdisc add dev r3-r2 root netem delay 10ms


# Add cable R1-R3

ip link add r1-r3 type veth peer name r3-r1
ip link set r1-r3 netns r1
ip link set r3-r1 netns r3
ip netns exec r1 ip addr add 10.0.13.1/30 dev r1-r3
ip netns exec r1 ip link set r1-r3 up
ip netns exec r3 ip addr add 10.0.13.2/30 dev r3-r1
ip netns exec r3 ip link set r3-r1 up
ip netns exec r1 tc qdisc add dev r1-r3 root netem delay 30ms
ip netns exec r3 tc qdisc add dev r3-r1 root netem delay 30ms


# Add cable R3-R4

ip link add r3-r4 type veth peer name r4-r3
ip link set r3-r4 netns r3
ip link set r4-r3 netns r4
ip netns exec r3 ip addr add 10.0.34.1/30 dev r3-r4
ip netns exec r3 ip link set r3-r4 up
ip netns exec r4 ip addr add 10.0.34.2/30 dev r4-r3
ip netns exec r4 ip link set r4-r3 up
ip netns exec r3 tc qdisc add dev r3-r4 root netem delay 10ms
ip netns exec r4 tc qdisc add dev r4-r3 root netem delay 10ms


# Add cable R4-R5

ip link add r4-r5 type veth peer name r5-r4
ip link set r4-r5 netns r4
ip link set r5-r4 netns r5
ip netns exec r4 ip addr add 10.0.45.1/30 dev r4-r5
ip netns exec r4 ip link set r4-r5 up
ip netns exec r5 ip addr add 10.0.45.2/30 dev r5-r4
ip netns exec r5 ip link set r5-r4 up
ip netns exec r4 tc qdisc add dev r4-r5 root netem delay 10ms
ip netns exec r5 tc qdisc add dev r5-r4 root netem delay 10ms

# Add cable R5-R6

ip link add r5-r6 type veth peer name r6-r5
ip link set r5-r6 netns r5
ip link set r6-r5 netns r6
ip netns exec r5 ip addr add 10.0.56.1/30 dev r5-r6
ip netns exec r5 ip link set r5-r6 up
ip netns exec r6 ip addr add 10.0.56.2/30 dev r6-r5
ip netns exec r6 ip link set r6-r5 up
ip netns exec r5 tc qdisc add dev r5-r6 root netem delay 10ms
ip netns exec r6 tc qdisc add dev r6-r5 root netem delay 10ms


# Add cable R1-R6

ip link add r1-r6 type veth peer name r6-r1
ip link set r1-r6 netns r1
ip link set r6-r1 netns r6
ip netns exec r1 ip addr add 10.0.16.1/30 dev r1-r6
ip netns exec r1 ip link set r1-r6 up
ip netns exec r6 ip addr add 10.0.16.2/30 dev r6-r1
ip netns exec r6 ip link set r6-r1 up
ip netns exec r1 tc qdisc add dev r1-r6 root netem delay 40ms
ip netns exec r6 tc qdisc add dev r6-r1 root netem delay 40ms