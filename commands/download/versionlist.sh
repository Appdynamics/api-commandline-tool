#!/bin/bash
download_versionlist() {
  local DELIMITER='"version":'
  local DEGREE=3
  local FILES=''
  while getopts "d:" opt "$@";
  do
    case "${opt}" in
      d)
        DEGREE="${OPTARG}"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  FILES=$(httpClient -s "https://download.appdynamics.com/download/version/?version-degree=${DEGREE}")
  local s=$FILES${DELIMITER}
  COMMAND_RESULT=""
  while [[ $s ]]; do
    ENTRY="${s%%"${DELIMITER}"*}\n\n"
    if [ "${ENTRY:0:1}" == "\"" ] ; then
      ENTRY=${ENTRY:1}
      ENTRY=${ENTRY%%\",*}
      COMMAND_RESULT="${COMMAND_RESULT}${ENTRY}${EOL}"
    fi;
    s=${s#*"${DELIMITER}"};
  done;
}

rde download_versionlist "" "" ""
