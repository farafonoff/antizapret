#!/bin/bash

ipset -exist create rkn_update hash:ip
ipset flush rkn_update

rm /tmp/rkn.pac
wget "http://www.vpngate.net/api/iphone/" -O vpns.csv

wget -4 "http://antizapret.prostovpn.org/proxy.pac" -O /tmp/rkn.pac

egrep -o "([0-9]+\.){3}[0-9]+" /tmp/rkn.pac > /tmp/blackips_pac

while read iphost
do
	for ip in $iphost; do
		ipset -exist add rkn_update $ip
	done;
done < /tmp/blackips_pac

ipset save rkn_update > /etc/rkn_blocked
ipset swap rkn rkn_update

