#!/bin/bash
# kill frr daemons if running
pkill -f "/usr/lib/frr/"
sleep 2
rm -rf /run/frr/r?
echo "frr stopped"