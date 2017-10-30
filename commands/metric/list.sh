#!/bin/bash

function metric_list {
  local APPLICATION=$*
  controller_call /controller/rest/applications/${APPLICATION}/metrics
}

register metric_list List all metrics available for one application
describe metric_list << EOF
List all metrics available for one application
EOF
