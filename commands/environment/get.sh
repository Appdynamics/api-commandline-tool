#!/bin/bash

function environment_get {
  COMMAND_RESULT=`cat "${HOME}/.appdynamics/act/config.$1.sh"`
}

register environment_get Retrieve an environment
describe environment_get << EOF
Retrieve an environment. Provide the name of the environment as parameter.
EOF

example environment_get << EOF
myaccount
EOF
