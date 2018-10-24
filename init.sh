#!/bin/bash

NEWPATH=`pwd`
ctOLDPATH=`grep "MONPATH=" checkTemp.sh`
sudo sed -i "s|$ctOLDPATH|$NEWPATH|g" checkTemp.sh
mnOLDPATH=`grep "MONPATH=" Monitor.sh`
sudo sed -i "s|$mnOLDPATH|$NEWPATH|g" Monitor.sh
mmOLDPATH=`grep "MONPATH=" makeMessage.sh`
sudo sed -i "s|$mmOLDPATH|$NEWPATH|g" makeMessage.sh
seOLDPATH=`grep "MONPATH=" sendEmail.sh`
sudo sed -i "s|$seOLDPATH|$NEWPATH|g" sendEmail.sh

