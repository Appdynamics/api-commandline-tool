#!/bin/bash

function controller_call {
  debug "Calling $CONFIG_CONTROLLER_HOST"
  local METHOD="GET"
  local FORM=""
  local USE_BASIC_AUTH=0
  debug "$@"
  while getopts "X:d:F:B" opt "$@";
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
      B)
        USE_BASIC_AUTH=1
      ;;
      *)
        debug "Invalid flag ${OPTARG} for controller_call"
      ;;
    esac
  done

  shiftOptInd
  shift $SHIFTS

  ENDPOINT=$*

  if [ "${USE_BASIC_AUTH}" -eq 1 ] ; then
    debug "Using basic authentication"
    CONTROLLER_LOGIN_STATUS=1
  else
    controller_login
  fi
  # Debug the COMMAND_RESULT from controller_login
  debug "Login result: $COMMAND_RESULT"
  if [ $CONTROLLER_LOGIN_STATUS -eq 1 ]; then
    debug "Endpoint: $ENDPOINT"

    local SEPERATOR="==========act-stats: ${RANDOM}-${RANDOM}-${RANDOM}-${RANDOM}"

    local HTTP_CLIENT_RESULT=""

    local HTTP_CALL=("-s")

    if [ "${CONFIG_OUTPUT_VERBOSITY/debug}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
      HTTP_CALL=("-v")
    fi

    if [ "${USE_BASIC_AUTH}" -eq 1 ] ; then
      HTTP_CALL+=("--user" "${CONFIG_CONTROLLER_CREDENTIALS}" "-X" "${METHOD}")
    else
      HTTP_CALL+=("-b" "${CONFIG_CONTROLLER_COOKIE_LOCATION}" "-X" "${METHOD}" "-H" "X-CSRF-TOKEN: ${XCSRFTOKEN}")
    fi



    if [ -n "$FORM" ] ; then
      HTTP_CALL+=("-F" "${FORM}")
    else
      HTTP_CALL+=("-H" "Content-Type: application/json;charset=UTF-8")
    fi;

    if [ -n "${PAYLOAD}" ] ; then
      HTTP_CALL+=("-d" "${PAYLOAD}")
    fi;
    if [ "${CONFIG_OUTPUT_COMMAND}" -eq 1 ] ; then
      HTTP_CALL+=("${CONFIG_CONTROLLER_HOST}${ENDPOINT}")
      COMMAND_RESULT="curl -L"
      for P in "${HTTP_CALL[@]}" ; do
        if [[ "$P" == -* ]]; then
          COMMAND_RESULT="$COMMAND_RESULT $P"
        else
          COMMAND_RESULT="$COMMAND_RESULT '$P'"
        fi
      done
    else
      HTTP_CALL+=("-w" "${SEPERATOR}%{http_code}")
      HTTP_CALL+=("${CONFIG_CONTROLLER_HOST}${ENDPOINT}")
      HTTP_CLIENT_RESULT=`httpClient "${HTTP_CALL[@]}"`

      COMMAND_RESULT=${HTTP_CLIENT_RESULT%${SEPERATOR}*}
      COMMAND_STATS=${HTTP_CLIENT_RESULT##*${SEPERATOR}}

       debug "Command result: ($COMMAND_RESULT)"
       info "HTTP Status Code: $COMMAND_STATS"

       if [ -z "${COMMAND_RESULT}" ] ; then
         COMMAND_RESULT="HTTP Status: ${COMMAND_STATS}"
       fi
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
