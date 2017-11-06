#!/bin/bash

function dbmon_delete {
  local COLLECTOR_ID=$*
  if [[ $COLLECTOR_ID =~ ^[0-9]+$ ]]; then
    controller_call -X POST -d "[$COLLECTOR_ID]" /controller/restui/databases/collectors/configuration/batchDelete
  else
    COMMAND_RESULT=""
    error "This is not a number: '$COLLECTOR_ID'"
  fi
}

register dbmon_delete Delete a database collector
describe dbmon_delete << EOF
Delete a database collector. Provide the collector id as parameter.
EOF
