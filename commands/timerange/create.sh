#!/bin/bash

timerange_create() {
  local START_TIME=-1
  local END_TIME=-1
  local DURATION_IN_MINUTES=0
  local TYPE="BETWEEN_TIMES"
  local DESCRIPTION
  local SHARED=false
  while getopts "s:e:d:SD:" opt "$@";
  do
    case "${opt}" in
      s)
        START_TIME=${OPTARG}
      ;;
      e)
        END_TIME=${OPTARG}
      ;;
      d)
        DURATION_IN_MINUTES=${OPTARG}
        TYPE="BEFORE_NOW"
      ;;
      S)
        SHARED="true"
      ;;
      D)
        DESCRIPTION=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  TIMERANGE_NAME=$*
  controller_call -X POST -d "{\"name\":\"$TIMERANGE_NAME\",\"description\":\"$DESCRIPTION\",\"shared\":$SHARED,\"timeRange\":{\"type\":\"$TYPE\",\"durationInMinutes\":$DURATION_IN_MINUTES,\"startTime\":$START_TIME,\"endTime\":$END_TIME}}" /controller/restui/user/createCustomRange
}

register timerange_create Create a custom time range
describe timerange_create << EOF
Create a custom time range
EOF
