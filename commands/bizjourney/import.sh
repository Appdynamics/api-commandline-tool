#!/bin/bash

function bizjourney_import {
  local FILE="$*"
  if [ -r "${FILE}" ] ; then
    DATA="$(<${FILE})"
    controller_call -X POST -d "${DATA}" '/controller/restui/analytics/biz_outcome/definitions/saveAsValidDraft'
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}

register bizjourney_import Create a new business journey

describe bizjourney_import << EOF
Create a new business journey. Provide a name and a type (APM or WEB) as parameter.
EOF
