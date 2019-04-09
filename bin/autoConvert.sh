#!/bin/bash
d=`date +%y%m%d%H%M%S`

cp ../../../SavedVariables/PacGuildTools.lua ./PacGuildTools.lua
lua SavedVartoJson.lua
python3 convertJSONtoCSV.py
rm PacGuildTools.lua
rm SavedVarOutput.json

mv guild_history.csv logs/history/guild_history-$d.csv
mv guild_roster.csv logs/roster/guild_roster-$d.csv