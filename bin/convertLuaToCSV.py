#!/usr/bin/env python

import json
import csv

with open(r"SavedVar.json") as json_file:
    data = json.load(json_file)
    lastUpdate = data['Default']['@LadyWinry']['$AccountWide']["lastUpdate"]


    with open('guild_roster.csv', mode='w') as guild_roster:
        guild_writer = csv.writer(guild_roster, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
        guild_writer.writerow(["lastUpdate",
                                "displayName",
                                "statusString",
                                "status",
                                "rankIndex",
                                "secsSinceLogoff",
                                "logoffString"
                                    ])

        for member in data['Default']['@LadyWinry']['$AccountWide']['guildRoster']:
            guild_writer.writerow([lastUpdate,
                                    member['displayName'],
                                    member['statusString'],
                                    member['status'],
                                    member['rankIndex'],
                                    member['secsSinceLogoff'],
                                    member['logoffString']
                                    ])
    
    with open('guild_history.csv', mode='w') as guild_history:
        history_writer = csv.writer(guild_history, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
        history_writer.writerow([
                                "timestamp",
                                "displayName",
                                "item",
                                "itemCount",
                                "eventType",
                                "eventName"
                                ])

        for item in data['Default']['@LadyWinry']['$AccountWide']['guildDepositList']:
            history_writer.writerow([
                                    item['timestamp'],
                                    item['displayName'],
                                    item['item'],
                                    item['count'],
                                    item['eventType'],
                                    item['eventName']
                                    ])