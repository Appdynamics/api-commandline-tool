#!/bin/bash

function actiontemplate_delete {
  local TYPE="httprequest"
  local ID=0
  while getopts "t:i:" opt "$@";
  do
    case "${opt}" in
      t)
        TYPE=${OPTARG}
      ;;
      i)
        ID=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  if [ "${ID}" -eq 0 ] ; then
    error "actiontemplate id is not set"
    COMMAND_RESULT=""
  elif [ "$TYPE" == "httprequest" ] ; then
    controller_call -X POST -d "${ID}" '/controller/restui/httpaction/deleteHttpRequestActionPlan' "$@"
  else
    controller_call -X POST -d "${ID}" '/controller/restui/emailaction/deleteCustomEmailActionPlan' "$@"
  fi;
}

register actiontemplate_delete "Delete an action template"

describe actiontemplate_delete << EOF
Delete an action template. Provide an id (-i) and a type (-t) as parameters.
EOF

example actiontemplate_export << EOF
-t httprequest
EOF
