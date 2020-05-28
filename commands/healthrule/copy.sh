#!/bin/bash

healthrule_copy() {
  local SOURCE_APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local TARGET_APPLICATION=""
  local TARGET_ENVIRONMENT=""
  while getopts "s:t:e:" opt "$@";
  do
    case "${opt}" in
      s)
        SOURCE_APPLICATION="${OPTARG}"
      ;;
      t)
        TARGET_APPLICATION="${OPTARG}"
      ;;
      e)
        TARGET_ENVIRONMENT="${OPTARG}"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  if [ -z "${SOURCE_APPLICATION}" ] ; then
    COMMAND_RESULT=""
    error "Source application is empty."
    exit
  fi
  if [ -z "${TARGET_APPLICATION}" ] ; then
    COMMAND_RESULT=""
    error "Target application is empty."
    exit
  fi
  OLD_CONFIG_OUTPUT_VERBOSITY=${CONFIG_OUTPUT_VERBOSITY}
  CONFIG_OUTPUT_VERBOSITY="output"
  healthrule_list -a ${SOURCE_APPLICATION}
  CONFIG_OUTPUT_VERBOSITY="${OLD_CONFIG_OUTPUT_VERBOSITY}"
  SOURCE_HEALTHRULE=${COMMAND_RESULT}
  COMMAND_RESULT=""
  if [ "${SOURCE_HEALTHRULE:1:12}" == "health-rules" ]
  then
    local R=${RANDOM}
    echo "$SOURCE_HEALTHRULE" > "/tmp/act-output-${R}"
    if [ -n "${TARGET_ENVIRONMENT}" ] ; then
      debug "Copy to target environment $TARGET_ENVIRONMENT, target application $TARGET_APPLICATION."
      $0 -E ${TARGET_ENVIRONMENT} healthrule import -a ${TARGET_APPLICATION} "/tmp/act-output-${R}"
    else
      debug "Copy to target application $TARGET_APPLICATION"
      healthrule_import -a "${TARGET_APPLICATION}" "/tmp/act-output-${R}"
    fi
    rm "/tmp/act-output-${R}"
  else
    COMMAND_RESULT="Could not export health rules from source application: ${COMMAND_RESULT}"
  fi
}

register healthrule_copy Copy healthrules from one application to another.

describe healthrule_copy << EOF
Copy healthrules from one application to another. Provide the source application id ("-s") and the target application ("-t").
If you provide ("-n") only the named health rule will be copied.
EOF
