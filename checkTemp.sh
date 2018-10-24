#!/bin/bash
MONPATH=/home/thermobot/Monitor
INCIP=$1
INCNOM=$2
LOWALARM=$3
HIGHALARM=$4

ERRORCODE=0
TEMP=`grep "Real Time Temp" $MONPATH/LastRead.html | awk '{print $5}'`

if [ -z $TEMP  ]
then
	ERRORCODE=1
	echo $ERRORCODE > $MONPATH/ERRORCODET
	exit
else
	LOWCUTOFF="-30"
	if (( $(echo "$TEMP < $LOWCUTOFF" | bc -l) ))
	then
		ERRORCODE=1
		echo $ERRORCODE > $MONPATH/ERRORCODET
		exit
	fi
fi

if (( $(echo "$TEMP > $HIGHALARM" | bc -l) ))
then
ERRORCODE=2
echo $ERRORCODE > $MONPATH/ERRORCODET
exit
elif (( $(echo "$TEMP < $LOWALARM" | bc -l) ))
then
ERRORCODE=3
echo $ERRORCODE > $MONPATH/ERRORCODET
exit
else
echo $ERRORCODE > $MONPATH/ERRORCODET
fi
