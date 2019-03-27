#!/bin/bash

environment_source() {
  if [ "$1" == "" ] ; then
    source "${HOME}/.appdynamics/act/config.sh"
  else
    source "${HOME}/.appdynamics/act/config.$1.sh"
  fi
}

register environment_source Load environment variables
describe environment_source << EOF
Load environment variables
EOF

example environment_source << EOF
myaccount
EOF
