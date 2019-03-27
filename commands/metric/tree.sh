#!/bin/bash

RECURSIVE_COMMAND_RESULT=""

metric_tree() {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local DEPTH=0
  declare -i DEPTH
  local METRIC_PATH
  local ROOT
  local TABS=""
  while getopts "a:d:t:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=${OPTARG}
      ;;
      d)
        DEPTH=${OPTARG}
      ;;
      t)
          TABS=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  METRIC_PATH="$*"

  metric_list -a $APPLICATION $METRIC_PATH

  debug $COMMAND_RESULT

  ROOT=$COMMAND_RESULT

  COMMAND_RESULT=""

  OLDIFS=$IFS
  IFS=$'\n,{'
  for I in $ROOT ; do
    case "$I" in
      *name*)
        name=${I##*:}
      ;;
      *type*)
        type=${I##*:}
      ;;
      *\}*)
        name=${name:2}
        RECURSIVE_COMMAND_RESULT="${RECURSIVE_COMMAND_RESULT}${TABS}${name%\"}${EOL}"
        if [[ "$type" == *folder* ]] ; then
          local SUB_PATH="${METRIC_PATH}|${name%\"}"
          metric_tree -d ${DEPTH}+1 -t "${TABS} " -a $APPLICATION ${SUB_PATH#"|"}
        fi
      esac
    done;
    IFS=$OLDIFS

    if [ $DEPTH -eq 0 ] ; then
      echo -e $RECURSIVE_COMMAND_RESULT
    fi
}

register metric_tree Build and return a metrics tree for one application
describe metric_tree << EOF
Create a metric tree for the given application (-a). Note that this will create a lot of requests towards your controller.
EOF
