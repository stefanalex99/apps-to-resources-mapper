IP=$1
USER=root
PASSWORD="alpine"

echo "Retrieving UUIDs from iOS device"
UUID_PATH="/var/containers/Bundle/Application"
UUIDS="$(sshpass -p $PASSWORD ssh $USER@$IP "ls $UUID_PATH")"

# Workaround to transform the string $UUIDS into an array of UUIDs.
echo "Creating array of UUIDs"
TMP="tmp.txt"
echo $UUIDS | tr " " "\n" > $TMP
uuids=()
while IFS= read -r line; do
	uuids+=("$line")
done < "$TMP"
rm $TMP

rm -f udid_list.list
rm -f phone_number.list
rm -f wifi.list

echo "Inspecting binaries for device id, phone number and wifi"


for uuid in "${uuids[@]}"; do
        APP_ID=$(sshpass -p $PASSWORD ssh $USER@$IP cat "$UUID_PATH/$uuid/"*.app/Info.plist | grep CFBundleIdentifier -A1 | tail -1 | cut -d "<" -f2 | cut -d ">" -f2)
        EXECUTABLE_NAME=$(sshpass -p $PASSWORD ssh $USER@$IP cat "$UUID_PATH/$uuid/"*.app/Info.plist | grep CFBundleExecutable -A1 | tail -1 | cut -d "<" -f2 | cut -d ">" -f2)

        if [ "$APP_ID" != "Binary file (standard input) matches" ] && [ "$EXECUTABLE_NAME" != "" ]; then
                LOCATION=$(sshpass -p $PASSWORD ssh $USER@$IP ls -d "$UUID_PATH/$uuid/"*.app)

                FOUND_UDID=$(sshpass -p $PASSWORD ssh $USER@$IP nm "$LOCATION/$EXECUTABLE_NAME" | grep "UIDevice")

                if [ "$FOUND_UDID" != "" ]; then
                        echo "$APP_ID" > udid_list.list
                fi

                FOUND_PHONE_NUMBER=$(sshpass -p $PASSWORD ssh $USER@$IP strings "$LOCATION/$EXECUTABLE_NAME" | grep "standardUserDefaults")

                if [ "$FOUND_PHONE_NUMBER" != "" ]; then
                        echo "$APP_ID" > phone_number.list
                fi


                FOUND_WIFI=$(sshpass -p $PASSWORD ssh $USER@$IP strings "$LOCATION/$EXECUTABLE_NAME" | grep -x "wifi")

                if [ "$FOUND_WIFI" != "" ]; then
                        echo "$APP_ID" > wifi.list
                fi
        fi
done
