#!/bin/bash

function dashboard_import {
  FILE="$*"
  if [ -r $FILE ] ; then
    controller_call -X POST -F file=@$FILE /controller/CustomDashboardImportExportServlet
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}

register dashboard_import Import a dashboard
describe dashboard_import << EOF
Import a dashboard from a given file
EOF
