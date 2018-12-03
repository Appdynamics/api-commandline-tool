#!/bin/bash

function actiontemplate_import {
  local FILE=""
  local TYPE="httprequest"
  while getopts "t:" opt "$@";
  do
    case "${opt}" in
      t)
        TYPE=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  FILE="$*"
  if [ -r $FILE ] ; then
    controller_call -X POST -F file="@$FILE" "/controller/actiontemplate/${TYPE}"
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}

register actiontemplate_import "Import an action template of a given type (email, httprequest)"

describe actiontemplate_import << EOF
Import an action template of a given type (email, httprequest)
EOF
