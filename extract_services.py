import csv
import sqlite3
import xml.etree.ElementTree as ET


conn = sqlite3.connect('TCC.db')

c = conn.cursor()

c.execute("SELECT client, service FROM access WHERE allowed = 1;")

rows = c.fetchall()

app_to_service_mapping = {}

for row in rows:
    if  row[0] not in app_to_service_mapping:
        app_to_service_mapping[row[0]] = []

    if row[1][len("kTCCService") : ] == "Ubiquity":
        app_to_service_mapping[row[0]].append("iCloud")
    else:
        app_to_service_mapping[row[0]].append(row[1][len("kTCCService") : ])

tree = ET.parse('clients.plist')
root = tree.getroot()

main_dict = root.find('dict')

keys = main_dict.findall('key')
small_dicts = main_dict.findall('dict')

for i in range(len(keys)):
    if '/' not in keys[i].text:
        mini_keys = small_dicts[i].findall('key')

        for mini_key in mini_keys:
            if mini_key.text == 'Authorization':
                level = small_dicts[i].find('integer')

                if level.text == '2':
                    if keys[i].text not in app_to_service_mapping:
                        app_to_service_mapping[keys[i].text] = []

                    app_to_service_mapping[keys[i].text].append("location_while_using")
                elif level.text == '4':
                    if keys[i].text not in app_to_service_mapping:
                        app_to_service_mapping[keys[i].text] = []

                    app_to_service_mapping[keys[i].text].append("location_always")

                break

udid_file = open('udid_list.list')

app_ids = udid_file.readlines()

for app_id in app_ids:
    app_id = app_id[:len(app_id) - 1]
    if app_id not in app_to_service_mapping and app_id != ' ':
        app_to_service_mapping[app_id] = []

    app_to_service_mapping[app_id].append("device_id")

phone_number_file = open('phone_number.list')

app_ids = phone_number_file.readlines()

for app_id in app_ids:
    app_id = app_id[:len(app_id) - 1]
    if app_id not in app_to_service_mapping and app_id != ' ':
        app_to_service_mapping[app_id] = []

    app_to_service_mapping[app_id].append("phone_number")


wifi_file = open('wifi.list')

app_ids = wifi_file.readlines()

for app_id in app_ids:
    app_id = app_id[:len(app_id) - 1]
    if app_id not in app_to_service_mapping and app_id != ' ':
        app_to_service_mapping[app_id] = []

    app_to_service_mapping[app_id].append("wifi")

csv_data = []
csv_columns = ["app_id", "resources"]

for key in app_to_service_mapping:
    csv_data.append({"app_id" : str(key), "resources" : app_to_service_mapping[key]})

csv_file = "apps_to_resources.csv"
try:
    with open(csv_file, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
        writer.writeheader()
        for data in csv_data:
            writer.writerow(data)
except IOError:
    print("I/O error")
