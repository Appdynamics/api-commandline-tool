#!/bin/bash

function _version {
  # shellcheck disable=SC2034
  COMMAND_RESULT="$ACT_VERSION ~ $ACT_LAST_COMMIT (${GLOBAL_COMMANDS_COUNTER} commands)"
}

register _version Print the current version of $SCRIPTNAME
describe _version << EOF
Print the current version of $SCRIPTNAME
EOF

example _version << EOF

EOF
