#!/bin/bash

#
function dashboard_update {
  apiCall -X POST -d '@{{f}}' '/controller/restui/dashboards/updateDashboard' "$@"
}

register dashboard_update Update a specific dashboard
describe dashboard_update << EOF
Update a specific dashboard. Please not that the json you need to provide is not compatible with the export format!
EOF
