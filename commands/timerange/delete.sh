#!/bin/bash

function timerange_delete {
  local TIMERANGE_ID=$@
  if [[ $TIMERANGE_ID =~ ^[0-9]+$ ]]; then
    controller_call -X POST -d "$TIMERANGE_ID" /controller/restui/user/deleteCustomRange
  else
    COMMAND_RESULT=""
    error "This is not a number: '$TIMERANGE_ID'"
  fi
}

register timerange_delete Delete a specific time range by id
