#!/bin/bash
#remember to allow local network
# iptables -I OUTPUT --dst 192.168.2.0/24 -j ACCEPT

VERSION="13.09.27.1";
IPTABLES=/sbin/iptables
. /etc/interclock/config

TODAY=`date "+%Y%m%d"`
#commands
ethX=`/usr/local/bin/iface $ETH`;

function allowuser(){
	 $IPTABLES -A INTERCLOCK -m owner --uid-owner $1 -j ACCEPT
}

function blockuser(){
	$IPTABLES -D INTERCLOCK  -m owner --uid-owner $1 -j ACCEPT
}

function checkuser(){
	KUID=`id -u $1`;
	$IPTABLES -L  INTERCLOCK -n | grep $KUID | wc -l 
}

function printbanner(){
	echo "$0 version $VERSION";
	echo "	by Meir Michanie - meirm@riunx.com"
	echo
}

function usage(){
	echo "$0 [allow|deny|status] <user>";
	echo "$0 show [usage|allowance] <user>";
	echo "$0 set allowance <minutes> <user>"
	echo "$0 reset <user>";
}

function showallowance(){
	echo "Allowance for user $1"
	min=`cat $INTERCLOCKBASE/$1/allow/ance.txt`
	echo "$min minutes"
}

function showusage(){
	echo "Usage for user $1"
	kiuser=$1
	min=`ls $INTERCLOCKBASE/$kiuser/history | grep $TODAY | wc -l`
	echo "$min minutes"
}

function resetusage(){
	kiuser=$1
	rm $INTERCLOCKBASE/$kiuser/history/$TODAY*
	echo "usage reset done"
}

function setallowance(){
	echo $1 > $INTERCLOCKBASE/$2/allow/ance.txt
	echo "New allowance for user $2"
	echo "$1 minutes"
}

function main(){
	if [ "X$1" == "X" ]; then 
		usage
	else
		if [ "$1" == "allow" ]; then 
			allowuser $2
		elif [ "$1" == "deny" ]; then
			blockuser $2
		elif [ "$1" == "status" ]; then
			checkuser $2
		elif [ "$1" == "reset" ]; then
			resetusage  $2 
		elif [ "$1" == "set" ]; then
                        if [ "X$2" == "Xallowance" ] ; then 
				setallowance $3 $4
			fi
		elif [ "$1" == "show" ]; then
			if [ "X$2" == "Xallowance" ]; then 
				showallowance  $3 
			elif [ "X$2" == "Xusage" ]; then
				showusage $3
			fi
		else
			usage
		fi
	fi
}

printbanner;
main $@;
