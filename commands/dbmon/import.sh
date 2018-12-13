#!/bin/bash

function dbmon_import {
  local FILE="$*"
  if [ -r "${FILE}" ] ; then
    DATA="$(<${FILE})"
    controller_call -X POST -d "${DATA}" '/controller/rest/databases/collectors/create'
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}

register dbmon_import Import a database collector from a json file.
describe dbmon_import << EOF
Create a new database collector. Provide a valid json file as parameter.
EOF
example dbmon_import << EOF
dbmon.json
EOF
