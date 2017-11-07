#!/bin/bash

function bt_list {
  local APPLICATION_ID=$*
  if [[ $APPLICATION_ID =~ ^[0-9]+$ ]]; then
    controller_call /controller/rest/applications/${APPLICATION_ID}/business-transactions
  else
    COMMAND_RESULT=""
    error "This is not a number: '$APPLICATION_ID'"
  fi
}

register bt_list List all business transactions for a given application

describe bt_list << EOF
List all business transactions for a given application. Provide the application id as parameter.
EOF
