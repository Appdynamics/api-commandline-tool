#!/bin/bash

metric_get() {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local START_TIME=-1
  local END_TIME=-1
  local DURATION_IN_MINUTES=0
  local TYPE="BEFORE_NOW"
  local ROLLUP="true"
  while getopts "a:s:e:d:t:r:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=`urlencode "${OPTARG}"`
      ;;
      s)
        START_TIME=${OPTARG}
      ;;
      e)
        END_TIME=${OPTARG}
      ;;
      d)
        DURATION_IN_MINUTES=${OPTARG}
      ;;
      t)
        TYPE=${OPTARG}
      ;;
      r)
        ROLLUP=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  debug ${APPLICATION}
  local METRIC_PATH=`urlencode "$*"`
  controller_call -B -X GET "/controller/rest/applications/${APPLICATION}/metric-data?metric-path=${METRIC_PATH}&time-range-type=${TYPE}&duration-in-mins=${DURATION_IN_MINUTES}&start-time=${START_TIME}&end-time=${END_TIME}&rollup=${ROLLUP}"
}

register metric_get Get a specific metric
describe metric_get << EOF
Get a specific metric by providing the metric path. Provide the application with option -a
EOF
