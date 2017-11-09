#!/bin/bash

function _version {
  COMMAND_RESULT="$ADC_VERSION ~ $ADC_LAST_COMMIT"
}

register _config Print the current version of $SCRIPTNAME
describe _config << EOF
Print the current version of $SCRIPTNAME
EOF
