#!/bin/bash

function controller_ping {
  debug "Ping $CONFIG_CONTROLLER_HOST"
  local PING_RESPONSE=$(httpClient -sI $CONFIG_CONTROLLER_HOST  -w "RESPONSE=%{http_code} TIME_TOTAL=%{time_total}")
  debug "RESPONSE: ${PING_RESPONSE}"
  if [ -n "$PING_RESPONSE" ] && [[ "${PING_RESPONSE/200 OK}" != "$PING_RESPONSE" ]]; then
    local TIME=${PING_RESPONSE##*TIME_TOTAL=}
    COMMAND_RESULT="Pong! Time: ${TIME}"
  else
    COMMAND_RESULT="Error"
  fi
}

register controller_ping Check the availability of an appdynamics controller
describe controller_ping << EOF
Check the availability of an appdynamics controller. On success the response time will be provided.
EOF
