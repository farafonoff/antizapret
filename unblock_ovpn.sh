#!/bin/bash

ip rule del prio 666
ip route flush table 666
ip route add default dev $1  proto kernel  scope link  src $4 table 666
ip rule add from all fwmark 666 lookup 666 prio 666

ipset -exist create rkn hash:ip
cat /etc/rkn_blocked | ipset -exist restore
ipset swap rkn_update rkn

iptables -A PREROUTING -t mangle -m set --match-set rkn dst -j MARK --set-mark 666
iptables -A OUTPUT -t mangle -m set --match-set rkn dst -j MARK --set-mark 666

