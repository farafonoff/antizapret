#!/bin/bash
MY_PATH="`dirname \"$0\"`"
echo $MY_PATH
pushd $MY_PATH
FILE=rkn3.set
ISET=rkn_new
echo update submodules..
git submodule update --recursive --remote
echo "create $ISET hash:net family inet hashsize 2048 maxelem 100000000" > $FILE

IFS="|"
cut -d";" -f1 z-i/dump.csv | tail -n +2 | while read blockline
do
	for ip in $blockline; do
		echo "add $ISET $ip"
	done;
done | egrep -v '[0-9]:' >> $FILE
echo "add $ISET 91.198.22.70" >> $FILE

echo set generated $ISET
wc -l $FILE
echo flush
ipset flush -exist $ISET
echo destroy
ipset destroy -exist $ISET
echo restore
ipset restore -exist < $FILE
echo swap
ipset swap rkn $ISET
echo flush
ipset flush $ISET
echo destroy
ipset destroy $ISET

