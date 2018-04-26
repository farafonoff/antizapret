#!/bin/bash
MY_PATH="`dirname \"$0\"`"
echo $MY_PATH
pushd $MY_PATH
FILE=rkn3.set
ISET=rkn_new
#wget "http://www.vpngate.net/api/iphone/" -O vpns.csv
#wget "https://api.antizapret.info/group.php" -O groups
#wget -4 "http://antizapret.prostovpn.org/proxy.pac" -O /tmp/rkn.pac
#egrep -o "([0-9]+\.){3}[0-9]+" /tmp/rkn.pac > /tmp/blackips_pac
echo update submodules..
git submodule update
echo "create $ISET hash:net family inet hashsize 2048 maxelem 100000000" > $FILE

IFS="|"
cut -d";" -f1 z-i/dump.csv | tail -n +2 | while read blockline
do
	for ip in $blockline; do
		echo "add $ISET $ip" >> $FILE
	done;
done 

echo "add $ISET 91.198.22.70" >> $FILE

echo set generated $ISET
wc -l $FILE
echo flush
ipset flush $ISET
echo destroy
ipset destroy $ISET
echo restore
ipset restore -exist < $FILE
echo swap
ipset swap rkn $ISET
echo flush
ipset flush $ISET
echo destroy
ipset destroy $ISET

