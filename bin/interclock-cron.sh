#!/bin/bash

. /etc/interclock/config


TODAY=`date "+%Y%m%d"`;
HMSTIME=`date "+%H%M%S"`;
if [ ! -f /etc/interclock/users ] ; then 
	echo "you must create a file named /etc/interclock/users with a username per line";
	exit 1
fi
for INTERCLOCKUSERNAME in `cat /etc/interclock/users`; do 
	minused=`ls $INTERCLOCKBASE/$INTERCLOCKUSERNAME/history/ 2>/dev/null | grep $TODAY | wc -l` 
	allowance=0
	if [ -f $INTERCLOCKBASE/$INTERCLOCKUSERNAME/allow/ance.txt ] ; then 
		allowance=`cat $INTERCLOCKBASE/$INTERCLOCKUSERNAME/allow/ance.txt`
	fi
	blockcount=`$INTERCLOCKCTL status $INTERCLOCKUSERNAME| tail -1`
	if [ $minused -ge $allowance ]; then 
		# make sure user is blocked
		if [ $blockcount -eq 0  ] ; then 
			$INTERCLOCKCTL  deny $INTERCLOCKUSERNAME
		fi
		if [ -f $INTERCLOCKBASE/$INTERCLOCKUSERNAME/punch/card.txt ] ; then
			su -c "rm -f $INTERCLOCKBASE/$INTERCLOCKUSERNAME/punch/card.txt" $INTERCLOCKUSERNAME ;
		fi
	else
		if [ -f $INTERCLOCKBASE/$INTERCLOCKUSERNAME/punch/card.txt ] ; then 
			#make sure user can browse
			if [ $blockcount -gt 0  ] ; then 
				$INTERCLOCKCTL  allow $INTERCLOCKUSERNAME
			fi
		else
			if [ $blockcount -eq 0  ] ; then
				$INTERCLOCKCTL  deny $INTERCLOCKUSERNAME
			fi
		fi
	fi
done
