#!/bin/bash
MONPATH=/home/thermobot/Monitor
echo "Uh Oh \${PERSON_NAME},">$MONPATH/MBEGIN
echo " ">>$MONPATH/MBEGIN
echo "INCUBATOR NAME: $1">>$MONPATH/MBEGIN
echo "INCUBATOR SENSOR IP: $2">>$MONPATH/MBEGIN
echo " ">>$MONPATH/MBEGIN
echo " ">$MONPATH/MEND
echo "Sincerely,">>$MONPATH/MEND
echo "Schmidtbot 2000">>$MONPATH/MEND

TEMP=`grep "Real Time Temp" LastRead.html | awk '{print $5}'`
HUM=`grep "Real Time Hum" LastRead.html | awk '{print $5}'`

CONTROLT=`cat $MONPATH/ERRORCODET`
CONTROLH=`cat $MONPATH/ERRORCODEH`

if [[ "$CONTROLT" == "0"  && "$CONTROLH" == "0" ]]
then
	ERRORMESSAGE="No known errors at the moment! If you get this email please kill Ozan and blame hir forcing you to make you do so!" 
	SUBJECT="No Errors, Contact Ozan if you get this e-mail"

elif [[ "$CONTROLT" == "0" ]]
then
	case  $CONTROLH  in
		2)
			SUBJECT="Humidity high in incubator $INCNOM"
			ERRORMESSAGE="Humidity is higher than the set parameters. Humidity: $HUM"
			;;
                3)
			SUBJECT="Humidity low in incubator $INCNOM"
			ERRORMESSAGE="Humidity is lower than the set parameters. Humidity: $HUM"
			;;
                *)
			SUBJECT="Something Wrong! Contact Ozan"
			ERRORMESSAGE="This shouldn't be happening, contact Ozan ASAP!"
          esac

elif [[ "$CONTROLT" == "1" ]]
then
	case  $CONTROLH  in
		1)
			SUBJECT="Temperature and Humidity cannot be read in incubator $INCNOM"
			ERRORMESSAGE="Unable to read the temperature and the humidity! Check sensor unit and network connecton!"
			;;
                *)
			SUBJECT="Something Wrong! Contact Ozan"
			ERRORMESSAGE="This shouldn't be happening, contact Ozan ASAP!"
          esac

elif [[ "$CONTROLT" == "2" ]]
then
	case  $CONTROLH  in
		0)
			SUBJECT="High Temperature in incubator $INCNOM"
			ERRORMESSAGE="Temperature is higher than the set parameters. Temperature: $TEMP   Humidity: $HUM"
			;;
		2)
			SUBJECT="High Temperature and High Humidity in incubator $INCNOM"
			ERRORMESSAGE="Temperature and humidity are higher than the set parameters. Temperature: $TEMP   Humidity: $HUM"
			;;
                3)
			SUBJECT="High Temperature and Low Humidity in incubator $INCNOM"
			ERRORMESSAGE="Temperature is higher and humidity is lower than the set parameters. Temperature: $TEMP   Humidity: $HUM"
			;;
                *)
			SUBJECT="Something Wrong! Contact Ozan"
			ERRORMESSAGE="This shouldn't be happening, contact Ozan ASAP!"
          esac

elif [[ "$CONTROLT" == "3" ]]
then
	case  $CONTROLH  in
		0)
			SUBJECT="Low Temperature in incubator $INCNOM"
			ERRORMESSAGE="Temperature is lower than the set parameters. Temperature: $TEMP   Humidity: $HUM"
			;;
		2)
			SUBJECT="Low Temperature and High Humidity in incubator $INCNOM"
			ERRORMESSAGE="Temperature is lower and humidity is higher than the set parameters. Temperature: $TEMP   Humidity: $HUM"
			;;
                3)
			SUBJECT="Low Temperature and Low Humidity in incubator $INCNOM"
			ERRORMESSAGE="Temperature and humidity are lower than the set parameters. Temperature: $TEMP   Humidity: $HUM"
			;;
                *)
			SUBJECT="Something Wrong! Contact Ozan"
			ERRORMESSAGE="This shouldn't be happening, contact Ozan ASAP!"
          esac
else
	SUBJECT="Something Wrong! Contact Ozan"
	ERRORMESSAGE="This shouldn't be happening, contact Ozan ASAP!"
fi

echo $ERRORMESSAGE > $MONPATH/ERRORMESSAGE
echo $SUBJECT > $MONPATH/SUBJECT


cat $MONPATH/MBEGIN $MONPATH/ERRORMESSAGE $MONPATH/MEND > $MONPATH/MESSAGE
rm -f $MONPATH/MBEGIN $MONPATH/MEND
