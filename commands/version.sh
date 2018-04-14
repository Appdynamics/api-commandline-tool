#!/bin/bash

function _version {
  COMMAND_RESULT="$ACT_VERSION ~ $ACT_LAST_COMMIT"
}

register _version Print the current version of $SCRIPTNAME
describe _version << EOF
Print the current version of $SCRIPTNAME
EOF
