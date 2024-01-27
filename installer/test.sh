#!/bin/bash

UNIT_VERSION="1.30.0-1~lunar"

UNATTENDED=0
INTERACTIVE=0

while [ $# -gt 0 ]; do
  OPTION=$(echo $1 | tr '[a-z]' '[A-Z]')
  case $OPTION in 
    "-U" | "--UNATTENDED" )
       UNATTENDED=1
       shift
       ;;
    "-I" | "--INTERACTIVE" )
       INTERACTIVE=1
       shift
       ;;
    *) echo "Catch all detected"
       shift 
       ;;
  esac
done

if [ $UNATTENDED -eq 1 ] && [ $INTERACTIVE -eq 1 ]; then
	echo "You cannot perform both an Interactive and Unattended installation at the same time."
fi


#FILE=/tmp/firstrun.log
#if [ ! -e $FILE ]
#then
# touch $FILE
# nohup $0 0<&- &>/dev/null &
# exit
#fi
#
#exec 1<&-
#exec 2<&-
#exec 1<>$FILE
#exec 2>&1
#echo "firstrun debug: starting-config"
#sleep 10
#echo "testing"
