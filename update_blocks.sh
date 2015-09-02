#!/bin/bash

ipset -exist create rkn_update hash:ip
ipset flush rkn_update

rm /tmp/rkn.csv
wget https://api.antizapret.info/all.php -O /tmp/rkn.csv

csvtool -t ";" col 4 /tmp/rkn.csv|tr -d \"|tr "," " " > /tmp/blackips

while read iphost
do
	for ip in $iphost; do
		ipset -exist add rkn_update $ip
	done;
done < /tmp/blackips

ipset save rkn_update > /etc/rkn_blocked
ipset swap rkn rkn_update

