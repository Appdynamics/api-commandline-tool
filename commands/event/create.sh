#!/bin/bash

function event_create {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local NODE
  local TIER
  local SEVERITY
  local EVENTTYPE
  local BT
  local COMMENT
  while getopts "n:e:s:t:c:a:" opt "$@";
  do
    case "${opt}" in
      n)
        NODE=${OPTARG}
      ;;
      t)
        TIER=${OPTARG}
      ;;
      s)
        SEVERITY=${OPTARG}
      ;;
      e)
        EVENTTYPE=${OPTARG}
      ;;
      b)
        BT=${OPTARG}
      ;;
      c)
        COMMENT=`urlencode "$OPTARG"`
      ;;
      a)
        APPLICATION=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  SUMMARY=`urlencode "$*"`
  debug -X POST "/controller/rest/applications/${APPLICATION}/events?summary=${SUMMARY}&comment=${COMMENT}&eventtype=${EVENTTYPE}&severity=${SEVERITY}&bt=${BT}&node=${NODE}&tier=${TIER}"
  controller_call -X POST "/controller/rest/applications/${APPLICATION}/events?summary=${SUMMARY}&comment=${COMMENT}&eventtype=${EVENTTYPE}&severity=${SEVERITY}&bt=${BT}&node=${NODE}&tier=${TIER}"
}

register event_create Create a custom event for a given application
