#!/bin/bash

if [ -z "$1" ]; then
        echo "Please enter an Hardware-ID as first argument and a Member-ID as second and the expected community as third."
        exit 1
fi

if [ -z "$2" ]; then
	echo "Please enter an Hardware-ID as first argument and a Member-ID as second and the expected community as third."
        exit 1
fi

if [ -z "$3" ]; then
        echo "Please enter an Hardware-ID as first argument and a Member-ID as second and the expected community as third."
        exit 1
fi


HWID=$1
MemberID=$2
COMMUNITY_EXPECTED=$3

#Format MemberID
MemberID=$(echo $MemberID | tr ' ' '_')

#Fetch from Server
RESPONSE=$(curl http://freifunk.liztv.net/api/fastd-key.php?hwid=$HWID)

if [ -z "$RESPONSE" ]; then
	echo "No such HWID found in Database"
	exit 1
fi

COMMUNITY=$(echo $RESPONSE | cut -d'|' -f 1)
KEY=$(echo $RESPONSE | cut -d'|' -f 2)

if [ -z "$COMMUNITY" ]; then
        echo "Error: Community-string fetched from server was empty"
        exit 1
fi

if [ -z "$KEY" ]; then
        echo "Error: Fastd-public-key fetched from server was empty"
        exit 1
fi

if [ "$COMMUNITY" != "$COMMUNITY_EXPECTED" ]; then
	echo "Error: Server said community is $COMMUNITY, you entered $COMMUNITY_EXPECTED, you have to fix the database."
	exit 1
fi

DIR="/etc/fastd/$COMMUNITY/nodes/"

if [ ! -d "$DIR" ]; then
	echo "Error: we can't locate the folder for the keyfiles"
	exit 1
fi

echo key \"$KEY\"\; > $DIR$MemberID_$HWID

kill -HUP $(ps aux | grep fastd | grep $COMMUNITY | awk '{print $2}')
