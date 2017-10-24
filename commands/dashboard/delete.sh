#!/bin/bash

function dashboard_delete {
  local DASHBOARD_ID=$*
  if [[ $DASHBOARD_ID =~ ^[0-9]+$ ]]; then
    controller_call -X POST -d "[$DASHBOARD_ID]" /controller/restui/dashboards/deleteDashboards
  else
    COMMAND_RESULT=""
    error "This is not a number: '$DASHBOARD_ID'"
  fi
}

register dashboard_delete Delete a specific dashboard
describe dashboard_delete << EOF
Delete a specific dashboard
EOF
