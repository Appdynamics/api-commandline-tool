#!/bin/bash

metric_list() {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local METRIC_PATH=""
  while getopts "a:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  METRIC_PATH=`urlencode "$*"`
  debug "Will call /controller/rest/applications/${APPLICATION}/metrics?output=JSON\&metric-path=${METRIC_PATH}"
  controller_call /controller/rest/applications/${APPLICATION}/metrics?output=JSON\&metric-path=${METRIC_PATH}
}

register metric_list List metrics available for one application.
describe metric_list << EOF
List all metrics available for one application (-a). Provide a metric path like "Overall Application Performance" to walk the metrics tree.
EOF
