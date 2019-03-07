#!/bin/bash
# Run this command with the act environment, the machine ID and your list of URLs as parameters, e.g.:
# ./create_service_monitors.sh demo 48 http://www.google.com http://www.google.ch http://www.google.de
ENVIRONMENT="${1}"
MACHINE_ID="${2}"

### Service Monitoring Configuration
SOCKET_TIMEOUT=30000
CONNECT_TIMEOUT=30000
SUCCESS_TRESHOLD=3
FAILURE_TRESHOLD=1
CHECK_INTERVAL=10
MAX_RESPONSE_SIZE=5000
RESULTS_WINDOW_SIZE=5
HTTP_METHOD="GET"
RESPONSE_VALIDATORS='{"field": "STATUS_CODE","value": "200","operator": "LESS_THAN_EQ"}'

shift
shift
URLS="$@"
for URL in ${URLS}; do
  ../act.sh -E ${ENVIRONMENT} sam create -n "${URL}" -i ${MACHINE_ID} -u "${URL}" -p ${CHECK_INTERVAL} -f ${FAILURE_TRESHOLD} -s ${SUCCESS_TRESHOLD} -w ${RESULTS_WINDOW_SIZE} -c ${CONNECT_TIMEOUT} -t ${SOCKET_TIMEOUT} -m ${HTTP_METHOD} -d ${MAX_RESPONSE_SIZE} -v "${RESPONSE_VALIDATORS}"
done;
