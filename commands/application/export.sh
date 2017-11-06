#!/bin/bash

function application_export {
  local APPLICATION_ID=$*
  if [[ $APPLICATION_ID =~ ^[0-9]+$ ]]; then
    controller_call /controller/ConfigObjectImportExportServlet?applicationId=97
  else
    COMMAND_RESULT=""
    error "This is not a number: '$APPLICATION_ID'"
  fi

}

register application_export Export an application from the controller

describe application_export << EOF
Export a application from the controller. Specifiy the application id as parameter.
EOF
