#!/bin/bash
MONPATH=/home/thermobot/Monitor
INCIP=$1
INCNOM=$2
LOWALARM=$3
HIGHALARM=$4

ERRORCODE=0
HUM=`grep "Real Time Hum" $MONPATH/LastRead.html | awk '{print $5}'`

if [ -z $HUM  ]
then
	ERRORCODE=1
	echo $ERRORCODE > $MONPATH/ERRORCODEH
	exit
else
	LOWCUTOFF="-1"
	if (( $(echo "$HUM < $LOWCUTOFF" | bc -l) ))
	then
		ERRORCODE=1
		echo $ERRORCODE > $MONPATH/ERRORCODEH
		exit
	fi
fi

if (( $(echo "$HUM > $HIGHALARM" | bc -l) ))
then
ERRORCODE=2
echo $ERRORCODE > $MONPATH/ERRORCODEH
exit
elif (( $(echo "$HUM < $LOWALARM" | bc -l) ))
then
ERRORCODE=3
echo $ERRORCODE > $MONPATH/ERRORCODEH
exit
else
echo $ERRORCODE > $MONPATH/ERRORCODEH
fi
