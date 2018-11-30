#!/bin/bash

function _config {
  environment_add -d "$@"
}

register _config Initialize the default environment. This is an alias for "${0} environment add -d"
describe _config << EOF
Initialize the default environment.
EOF
