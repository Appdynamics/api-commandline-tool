#!/bin/bash
# SINCE: yesterday, 0:00, UNTIL today, 0:00
TODAY_MIDNIGHT=$(date -r $(((`date +%s`/86400*86400))) +%s)
declare -i TODAY_MIDNIGHT
DEFAULT_SINCE="$((${TODAY_MIDNIGHT}-86400))000"
DEFAULT_UNTIL="${TODAY_MIDNIGHT}000"

ENVIRONMENT=$1
DASHBOARD_ID=$2
SINCE=${3:-${DEFAULT_SINCE}}
UNTIL=${4:-${DEFAULT_UNTIL}}

# Fix ADQL queries and set startTime and endTime for dashboard or widget specific time ranges
JSON=$(../act.sh -E ${ENVIRONMENT} dashboard get -i ${DASHBOARD_ID} | sed -e "s/SINCE[[:space:]]*[0-9]*[[:space:]]*UNTIL[[:space:]]*[0-9]*/SINCE ${SINCE} UNTIL ${UNTIL}/g" | sed -e "s/\"\startTime\"\([[:space:]]*\):[^,]*,/\"startTime\"\1: ${SINCE},/g" | sed -e "s/\"\endTime\"\([[:space:]]*\):[^,]*,/\"endTime\"\1: ${UNTIL},/g")


../act.sh -E ${ENVIRONMENT} dashboard update -d "${JSON}"
