#!/bin/bash
MY_PATH="`dirname \"$0\"`"
echo $MY_PATH
pushd $MY_PATH

#wget "http://www.vpngate.net/api/iphone/" -O vpns.csv
wget "https://api.antizapret.info/group.php" -O groups
#wget -4 "http://antizapret.prostovpn.org/proxy.pac" -O /tmp/rkn.pac
#egrep -o "([0-9]+\.){3}[0-9]+" /tmp/rkn.pac > /tmp/blackips_pac
echo "create rkn hash:ip family inet hashsize 2048 maxelem 65536" > rkn.set

IFS=","
while read blockline
do
	for ip in $blockline; do
		echo "add rkn $ip" >> rkn.set
	done;
done < groups

echo "add rkn 91.198.22.70" >> rkn.set

ipset flush
ipset restore -exist < rkn.set
