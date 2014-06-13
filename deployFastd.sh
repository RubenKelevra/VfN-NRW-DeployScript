#!/bin/bash

if [ -z "$1" ]; then
        echo "Please enter an Hardware-ID as first and the expected community as second argument."
        exit 1
fi

if [ -z "$2" ]; then
	echo "Please enter an Hardware-ID as first and the expected community as second argument."
        exit 1
fi

HWID=$1
COMMUNITY_EXPECTED=$2

#Fetch from Server
RESPONSE=$(curl -sS http://freifunk.liztv.net/api/fastd-key.php?hwid=$HWID)

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

KEY="key \"$KEY\";"

if [ -f $DIR$HWID ]; then
	if [ "$(cat $DIR$HWID)" == "$KEY" ]; then
		echo "Keyfile with current Hash allready exist, exiting."
		exit 0
	else
		REPLY="00000"
		while [ "$REPLY" != 'yes' ]; do
			if [ "$REPLY" != '00000' ]; then
				echo "type 'yes' or 'no'!"
			fi
			echo "This Hardware-ID got already a keyfile for this town with different hash, overwrite? (yes/no)"
			read -p "Are you sure? " -n 4 -r ; echo
			if [ "$REPLY" == 'no' ]; then
				exit 0
			fi
		done
	fi
fi

echo $KEY > $DIR$HWID

kill -HUP $(ps aux | grep fastd | grep $COMMUNITY | awk '{print $2}')
