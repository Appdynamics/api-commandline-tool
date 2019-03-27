#!/bin/bash

actiontemplate_list() {
  local TYPE="httprequest"
  while getopts "t:" opt "$@";
  do
    case "${opt}" in
      t)
        TYPE=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  if [ "$TYPE" == "httprequest" ] ; then
    controller_call '/controller/restui/httpaction/getHttpRequestActionPlanList'
  else
    controller_call 'controller/restui/emailaction/getCustomEmailActionPlanList'
  fi;
}

register actiontemplate_list "List all actiontemplates."

describe actiontemplate_list << EOF
List all actiontemplates. Provide a type (-t) as parameter.
EOF

example actiontemplate_export << EOF
-t httprequest
EOF
