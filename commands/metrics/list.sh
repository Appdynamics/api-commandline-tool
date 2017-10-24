#!/bin/bash

function metrics_list {
  local APPLICATION=$*
  controller_call /controller/rest/applications/${APPLICATION}/metrics
}

register metrics_list List all metrics available for one application
describe metrics_list << EOF
List all metrics available for one application
EOF
