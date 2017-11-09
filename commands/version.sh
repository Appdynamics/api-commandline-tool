#!/bin/bash

function _version {
  COMMAND_RESULT="$ADC_VERSION ~ $ADC_LAST_COMMIT"
}

register _version Print the current version of $SCRIPTNAME
describe _version << EOF
Print the current version of $SCRIPTNAME
EOF
