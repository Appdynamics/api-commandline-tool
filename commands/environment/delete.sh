#!/bin/bash

function environment_delete {
  rm "${HOME}/.appdynamics/act/config.$1.sh"
  COMMAND_RESULT="${1} deleted"
}

register environment_delete "Delete an environment"

describe environment_delete << EOF
Delete an environment. Provide the name of the environment as parameter.
EOF

example environment_delete << EOF
myaccount
EOF
