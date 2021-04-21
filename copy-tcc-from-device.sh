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

echo "Retrieving TCC db from iOS device"
TCC_PATH="/private/var/mobile/Library/TCC/TCC.db"

sshpass -p $PASSWORD scp $USER@$IP:$TCC_PATH .
