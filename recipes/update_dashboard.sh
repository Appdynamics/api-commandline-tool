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


JSON=$(../act.sh -E ${ENVIRONMENT} dashboard get -i ${DASHBOARD_ID} | sed -e "s/SINCE[[:space:]]*[0-9]*[[:space:]]*UNTIL[[:space:]]*[0-9]*/SINCE ${SINCE} UNTIL ${UNTIL}/g")

../act.sh -E ${ENVIRONMENT} dashboard update -d "${JSON}"
