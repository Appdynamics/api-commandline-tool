#!/bin/bash

healthrule_import() {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local FILE=""
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
  FILE="$*"
  if [ -r $FILE ] ; then
    controller_call -X POST -F file="@$FILE" "/controller/healthrules/${APPLICATION}"
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}

register healthrule_import Import a health rule

describe healthrule_import << EOF
Import a health rule.
EOF
