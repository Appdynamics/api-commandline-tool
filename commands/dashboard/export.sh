#!/bin/bash

function dashboard_export {
  local DASHBOARD_ID=$@
  if [[ $DASHBOARD_ID =~ ^[0-9]+$ ]]; then
    controller_call -X GET /controller/CustomDashboardImportExportServlet?dashboardId=$@
  else
    COMMAND_RESULT=""
    error "This is not a number: '$DASHBOARD_ID'"
  fi
}

register dashboard_export Export a specific dashboard
