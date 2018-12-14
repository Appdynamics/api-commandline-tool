#!/bin/bash

function _export {
  local WITH_ENVIRONMENTS="1"
  while getopts "e" opt "$@";
  do
    case "${opt}" in
      e)
        WITH_ENVIRONMENTS="0"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  local ENVIRONMENTS=""
  local COLLECTIONS=""

  if [ "${WITH_ENVIRONMENTS}" -eq "1" ] ; then
    environment_list
    for ENVIRONMENT in ${COMMAND_RESULT} ; do
      environment_export ${ENVIRONMENT/(default)/}
      ENVIRONMENTS+="${COMMAND_RESULT},"
    done;
    ENVIRONMENTS=${ENVIRONMENTS%,}
  fi
  read -r -d '' COMMAND_RESULT << EOF
  {
  	"version": 1,
  	"collections": [${COLLECTIONS}],
  	"environments": [
    ${ENVIRONMENTS}
    ]
  }
EOF
}

register _export "Export to postman"
describe _export << EOF
Export to postman
EOF

example _export << EOF
> postman.json
EOF
