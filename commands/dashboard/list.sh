#!/bin/bash

function dashboard_list {
  controller_call -X GET /controller/restui/dashboards/getAllDashboardsByType/false
}

register dashboard_list List all dashboards available on the controller
