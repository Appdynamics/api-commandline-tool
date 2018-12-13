#!/bin/bash

function environment_source {
  source "${HOME}/.appdynamics/act/config.$1.sh"
}

register environment_source Load environment variables
describe environment_source << EOF
Load environment variables
EOF

example environment_get << EOF
myaccount
EOF
