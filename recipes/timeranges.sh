#!/bin/bash

TODAY_MIDNIGHT=$(date -r $(((`date +%s`/86400*86400))) +%s)
declare -i TODAY_MIDNIGHT

# yesterday, 0:00 - today, 0:00)
../act.sh timerange create -s "$((${TODAY_MIDNIGHT}-86400))000" -e "${TODAY_MIDNIGHT}000" yesterday

# "Business Hours", today, 6am-8pm
../act.sh timerange create -s "$((${TODAY_MIDNIGHT}+21600))000" -e "$((${TODAY_MIDNIGHT}+72000))000" 'Business Hours'

# "Same Weekday, 7 days ago"
../act.sh timerange create -s "$((${TODAY_MIDNIGHT}-604800))000" -e "$((${TODAY_MIDNIGHT}-518400))000" '7 days ago'
