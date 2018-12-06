#!/bin/bash

function analyticssearch_import {
  FILE="$*"
  if [ -r "${FILE}" ] ; then
    DATA="$(<${FILE})"
    regex='("id" *: *[0-9]+,)'
    if [[ ${DATA} =~ $regex ]]; then
      DATA=${DATA/${BASH_REMATCH[0]}/}
    fi
    if [[ $DATA == '['* ]]
    then
      COMMAND_RESULT=""
      error "File contains multiple saved searches. Please provide only a single element."
    else
      controller_call -X POST -d "${DATA}" '/controller/restui/analyticsSavedSearches/createAnalyticsSavedSearch'
    fi
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}

register analyticssearch_import Import an analytics search. Provide a json file as parameter.

describe analyticssearch_import << EOF
Import an analytics search. Provide a json file as parameter.
EOF

example analyticssearch_import << EOF
search.json
EOF
