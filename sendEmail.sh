#!/bin/bash
MONPATH=/home/thermobot/Monitor
source $MONPATH/PARAMETERS
INCNUM=$1
FILEN="$MONPATH/EMAIL_$1.tmp"


# The control file structure should be as follows
# #IncubatorNumber #Email_Count #NumericTimeStamp

CHECKSENT=`cat $FILEN`
EMCOUNT=$((0))
if [ -z "$CHECKSENT" ]
then
	python $MONPATH/Email.py
	EMCOUNT=$((1))
	TMNOW=`date`
	TIME=$(date -u -d "$TMNOW" +"%s")
	echo "Email! $INCNUM $EMCOUNT $TIME"
	echo "$INCNUM $EMCOUNT $TIME" > $FILEN
else
	INC=`echo $CHECKSENT | awk '{print $1}'`
	INC=$((INC))
	EMCOUNT=`echo $CHECKSENT | awk '{print $2}'`
	TIME=`echo $CHECKSENT | awk '{print $3}'`
	TIME=$(($TIME))
	TMFN=`date`
	FTIME=$(date -u -d "$TMFN" +"%s")
	TIMEDIF=$(expr $FTIME - $TIME)
	#Time to email
	TTEM=$(expr 14400 \* $EMCOUNT)
	if [ $TIMEDIF -gt $TTEM ]
	then
		python $MONPATH/Email.py
		echo "Email! $INCNUM $EMCOUNT $TIME"
		EMCOUNT=$(expr $EMCOUNT + 1)
		echo "$INCNUM $EMCOUNT $TIME" > $FILEN
	fi
fi
