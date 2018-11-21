#!/bin/bash

function healthrule_copy {
  local SOURCE_APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local TARGET_APPLICATION=""
  local HEALTH_RULE_NAME=""
  while getopts "s:t:n:" opt "$@";
  do
    case "${opt}" in
      s)
        SOURCE_APPLICATION="${OPTARG}"
      ;;
      t)
        TARGET_APPLICATION="${OPTARG}"
      ;;
      n)
        HEALTH_RULE_NAME="${OPTARG}"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  healthrule_list -a ${SOURCE_APPLICATION}
  if [ "${COMMAND_RESULT:1:12}" == "health-rules" ]
  then
    local R=${RANDOM}
    echo "$COMMAND_RESULT" > "/tmp/act-output-${R}"
    healthrule_import -a ${TARGET_APPLICATION} "/tmp/act-output-${R}"
    rm "/tmp/act-output-${R}"
  else
    COMMAND_RESULT="Could not export health rules from source application: ${COMMAND_RESULT}"
  fi
}

register healthrule_copy Copy healthrules from one application to another.

describe healthrule_list << EOF
Copy healthrules from one application to another. Provide the source application id ("-s") and the target application ("-t").
If you provide ("-n") only the named health rule will be copied.
EOF
