#!/bin/bash

# Default username = root ($USER)
# IP should be provided as an argument
#
# Usage: ./copy-tcc-from-device.sh <ip>

if [ $# -eq 0 ]; then
    	echo "No arguments supplied. Usage: ./copy-tcc-from-device.sh <ip>"
	exit 0
fi

IP="$1"
USER="root"
PASSWORD="alpine"

echo "Retrieving location db from iOS device"
LOCATIOND_PATH="/private/var/root/Library/Caches/locationd/clients.plist"

sshpass -p $PASSWORD scp $USER@$IP:$LOCATIOND_PATH .

plutil -convert xml1 clients.plist
