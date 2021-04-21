#! /bin/bash

IP=$1

./copy-locationd-from-device.sh $IP
./copy-tcc-from-device.sh $IP
./check_udid.sh $IP 2> /dev/null
python3 extract_services.py
./clean.sh
