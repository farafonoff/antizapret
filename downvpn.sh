#!/bin/bash

#FREE THE DNS
#ip route add 8.8.8.8 dev $1  proto kernel  scope link  src $4
#ip route add 8.8.4.4 dev $1  proto kernel  scope link  src $4

ip rule del prio 666
ip route flush table 666
ip route del default dev $1 table 666
ip rule del from all fwmark 666 lookup 666 prio 666
iptables -D OUTPUT -t mangle -m set --match-set rkn dst -j MARK --set-mark 666
iptables -t nat -D POSTROUTING -o $1 -j MASQUERADE
iptables -D PREROUTING -t mangle -m set --match-set rkn dst -j MARK --set-mark 666

