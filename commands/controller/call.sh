#!/bin/bash

function controller_call {
  debug "Calling $CONFIG_CONTROLLER_HOST"
  local METHOD="GET"
  local FORM=""
  while getopts "X:d:F:" opt "$@";
  do
    case "${opt}" in
      X)
	METHOD=${OPTARG}
      ;;
      d)
        PAYLOAD="${OPTARG}"
      ;;
      F)
        FORM="${OPTARG}"
      ;;
    esac
  done

  shiftOptInd
  shift $SHIFTS

  ENDPOINT=$*

  controller_login
  # Debug the COMMAND_RESULT from controller_login
  debug "Login result: $COMMAND_RESULT"
  if [ $CONTROLLER_LOGIN_STATUS -eq 1 ]; then
    debug "Endpoint: $ENDPOINT"
    # Note that the line for FORM and PAYLOAD is not breaking since curl will have issues with multiple line breaks
    # assuming that every empty line contains an additional URL.

    local SEPERATOR="==========act-stats: ${RANDOM}-${RANDOM}-${RANDOM}-${RANDOM}"

    #local HTTP_CLIENT_RESULT=$(httpClient -s -b $CONFIG_CONTROLLER_COOKIE_LOCATION \
    #      -X "${METHOD}"\
    #      -H "X-CSRF-TOKEN: ${XCSRFTOKEN}"\
    #      "$([ -z "$FORM" ] && echo "-HContent-Type: application/json;charset=UTF-8")"\
    #      "`[ -n "${PAYLOAD}" ] && echo "-d ${PAYLOAD}"`""`[ -n "$FORM" ] && echo " -F ${FORM}"`"\
    #      "${CONFIG_CONTROLLER_HOST}${ENDPOINT}"\
    #      -w  "\"${SEPERATOR} %{http_code}; %{time_total}\""
    #      )

    local HTTP_CLIENT_RESULT=""

    HTTP_CALL=("-s" "-b" "${CONFIG_CONTROLLER_COOKIE_LOCATION}" "-X" "${METHOD}" "-H" "X-CSRF-TOKEN: ${XCSRFTOKEN}")

    if [ -n "$FORM" ] ; then
      HTTP_CALL+=("-F" "${FORM}")
    else
      HTTP_CALL+=("-H" "Content-Type: application/json;charset=UTF-8")
    fi;

    if [ -n "${PAYLOAD}" ] ; then
      HTTP_CALL+=("-d" "${PAYLOAD}")
    fi;

    HTTP_CALL+=("-w" "${SEPERATOR}%{http_code}")

    HTTP_CALL+=("${CONFIG_CONTROLLER_HOST}${ENDPOINT}")

    HTTP_CLIENT_RESULT=`httpClient "${HTTP_CALL[@]}"`

    COMMAND_RESULT=${HTTP_CLIENT_RESULT%${SEPERATOR}*}
    COMMAND_STATS=${HTTP_CLIENT_RESULT##*${SEPERATOR}}

    COMMAND_STATS_HTTP_CODE="${COMMAND_STATS#*;}"
    COMMAND_STATS_HTTP_TIME="${COMMAND_STATS%;*}"

     debug "Command result: ($COMMAND_RESULT)"
     info "HTTP Status Code: $COMMAND_STATS"

     if [ -z "${COMMAND_RESULT}" ] ; then
       COMMAND_RESULT="HTTP Status: ${COMMAND_STATS}"
     fi

   else
     COMMAND_RESULT="Controller Login Error! Please check hostname and credentials"
   fi
}

register controller_call Send a custom HTTP call to a controller
describe controller_call << EOF
Send a custom HTTP call to an AppDynamics controller. Provide the endpoint you want to call as parameter. You can modify the http method with option -X and add payload with option -d.
EOF

example controller_call << EOF
/controller/rest/serverstatus
EOF
