#!/bin/bash
MONPATH=/home/thermobot/Monitor

while read LINE
do
if [ ! -z "$LINE" ] ;then
	echo $LINE
	INCNOM=`echo $LINE | awk '{print $1}'`
	IP=`echo $LINE | awk '{print $2}'`
	NAMES=`echo $LINE | awk '{print $3}' | sed 's/\,/ /g'`
	TEMPS=`echo $LINE | awk '{print $4}' | sed 's/(/ /g' | sed 's/\-/ /g' | sed 's/)/ /g'`
	LOWT=`echo $TEMPS | awk '{print $2}'`
	HIGHT=`echo $TEMPS | awk '{print $3}'`
	HUMS=`echo $LINE | awk '{print $5}' | sed 's/(/ /g' | sed 's/\-/ /g' | sed 's/)/ /g'`
	LOWH=`echo $HUMS | awk '{print $2}'`
	HIGHH=`echo $HUMS | awk '{print $3}'`

	touch $MONPATH/CONTACTS
	for name in $NAMES
	do
		grep $name $MONPATH/EMAILLIST >> $MONPATH/CONTACTS
	done
	wget -q -T 5 -t 1 $IP -O $MONPATH/LastRead.html
	wait
	$MONPATH/checkTemp.sh $IP $INCNOM $LOWT $HIGHT
	wait
	$MONPATH/checkHum.sh $IP $INCNOM $LOWH $HIGHH
	wait
	CONTROLT=`cat $MONPATH/ERRORCODET`
	CONTROLH=`cat $MONPATH/ERRORCODEH`
	TEMP=`grep "Real Time Temp" $MONPATH/LastRead.html | awk '{print $5}'`
	HUM=`grep "Real Time Hum" $MONPATH/LastRead.html | awk '{print $5}'`

	if [[ "$CONTROLT" == "0" && "$CONTROLH" == "0" ]]
	then
		FILEN="$MONPATH/EMAIL_$INCNOM.tmp"
		if [ -a $FILEN ]
		then
			SUBJECT="System is back to normal in $INCNOM"
			ERRORMESSAGE="The system is back to normal in $INCNOM at $IP!... Temperature: $TEMP   Humidity: $HUM"
			echo $SUBJECT > $MONPATH/SUBJECT
			echo $ERRORMESSAGE > $MONPATH/ERRORMESSAGE
			$MONPATH/makeMessage.sh $INCNOM $IP
	                python $MONPATH/Email.py
			rm -f $FILEN
		fi
	else
		$MONPATH/makeMessage.sh $INCNOM $IP
		wait
		$MONPATH/sendEmail.sh $INCNOM
		wait
	fi
	wait
	rm -f $MONPATH/CONTACTS $MONPATH/ERRORCODE* $MONPATH/ERRORMESSAGE $MONPATH/MESSAGE $MONPATH/SUBJECT $MONPATH/LastRead.html
fi
done < $MONPATH/INCUBATORS
