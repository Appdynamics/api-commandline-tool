#!/bin/bash
#     {
#       "enabled": true,
#       "id": 35428,
#       "name": "CPU utilization is too high"
#   }

ENVIRONMENT=$1
APPLICATION_ID=$2
HR_NAME=$3

echo "${ENVIRONMENT} ----  ${APPLICATION_ID} ----- ${HR_NAME} -------"
# Get a list of healthrules that match the grep argument
# Format is [ID] [Name]
# In case anyone cares - we do the grep after the sed and awk commands to handle the potential edge case of the grep regex matching one of our keywords (id, name).
# This way they get filtered out before we search on the HR name.
HEALTHRULES=$(../act.sh -E ${ENVIRONMENT} healthrule list -a ${APPLICATION_ID} | sed 's/},{/\'$'\n'/g | awk -F "\"" '/"id":([[:digit:]]+)/ {print $3" "$6}' - | sed 's/^://'g | sed 's/, / /' | grep "${HR_NAME}" | awk '{print $1}' - )

for HR in $HEALTHRULES 
do
echo "Enable HR ${HR}"
../act.sh -E ${ENVIRONMENT} healthrule enable -a ${APPLICATION_ID} -i ${HR}
done;
