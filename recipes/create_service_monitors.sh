#!/bin/bash
# Run this command with the act environment, the machine ID and your list of URLs as parameters, e.g.:
# ./create_service_monitors.sh demo 48 http://www.google.com http://www.google.ch http://www.google.de
ENVIRONMENT="${1}"
MACHINE_ID="${2}"
shift
shift
URLS="$@"
for URL in ${URLS}; do
  ../act.sh -E ${ENVIRONMENT} sam create -n "${URL}" -i ${MACHINE_ID} -u "${URL}" -p 10 -f 1 -s 3 -w 5 -c 30000 -t 30000 -m GET -d 5000 -v '{"field": "STATUS_CODE","value": "200","operator": "GREATER_THAN"}'
done;
