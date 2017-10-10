#!/bin/bash

function timerange_create {
  while getopts "s:e:" opt "$@";
  do
    case "${opt}" in
      s)
        START_TIME=${OPTARG}
      ;;
      e)
        END_TIME=${OPTARG}
      ;;
    esac   
  done;
  shiftOptInd
  shift $SHIFTS
  TIMERANGE_NAME=$@
  controller_call -X POST -d "{\"name\":\"$TIMERANGE_NAME\",\"timeRange\":{\"type\":\"BETWEEN_TIMES\",\"durationInMinutes\":0,\"startTime\":$START_TIME,\"endTime\":$END_TIME}}" /controller/restui/user/createCustomRange
}

register timerange_create Create a custom time range 
