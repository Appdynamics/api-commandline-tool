#!/bin/bash

function environment_edit {
  if [ -x "${EDITOR}" ] || [ -x "`which "${EDITOR}"`" ] ; then
    ${EDITOR} "${HOME}/.appdynamics/act/config.$1.sh"
  else
    error "No editor found. Please set \$EDITOR."
  fi
}

register environment_edit Open an environment file in your editor
describe environment_edit << EOF
EOF

example environment_edit << EOF
myaccount
EOF
