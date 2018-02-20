#!/bin/bash
MY_PATH="`dirname \"$0\"`"
echo $MY_PATH
pushd $MY_PATH

/sbin/ipset -exist destroy rkn_update
/sbin/ipset -exist create rkn hash:ip
/sbin/ipset -exist create rkn_update hash:ip
/sbin/ipset flush rkn_update

rm /tmp/rkn.pac
#wget "http://www.vpngate.net/api/iphone/" -O vpns.csv

wget -4 "http://antizapret.prostovpn.org/proxy.pac" -O /tmp/rkn.pac

egrep -o "([0-9]+\.){3}[0-9]+" /tmp/rkn.pac > /tmp/blackips_pac

while read iphost
do
	for ip in $iphost; do
		/sbin/ipset -exist add rkn_update $ip
	done;
done < /tmp/blackips_pac

/sbin/ipset swap rkn rkn_update
/sbin/ipset save rkn > /etc/rkn_blocked
/sbin/ipset -exist destroy rkn_update

