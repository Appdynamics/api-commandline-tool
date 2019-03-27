#!/bin/bash

environment_list() {
  local BASE
  local TEMP
  COMMAND_RESULT="(default)"
  for file in "${HOME}/.appdynamics/act/config."*".sh"
  do
    BASE=$(bashBasename "${file}")
    TEMP=${BASE#*.}
    COMMAND_RESULT="${COMMAND_RESULT} ${TEMP%.*}"
  done
}

register environment_list List all your environments
describe environment_list << EOF
List all your environments
EOF

example environment_list << EOF
EOF
