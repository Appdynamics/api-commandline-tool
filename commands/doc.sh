#!/bin/bash

function _doc {
read -r -d '' COMMAND_RESULT <<- EOM
# Usage
Below you will find a list of all available namespaces and commands available with
\`act.sh\`. The given examples allow you to understand, how each command is used.
For more complex examples, have a look into [RECIPES.md](RECIPES.md)
EOM
  local NAMESPACES=""
  for INDEX in "${!GLOBAL_LONG_HELP_COMMANDS[@]}" ; do
    local COMMAND="${GLOBAL_LONG_HELP_COMMANDS[$INDEX]}"
    NAMESPACES="${NAMESPACES}\n${COMMAND%%_*}"
  done
  for NS in "" $(echo -en $NAMESPACES | sort -u); do
    COMMAND_RESULT="${COMMAND_RESULT}\n\n## ${NS:-Global}\n"
    for INDEX in "${!GLOBAL_DOC_NAMESPACES[@]}" ; do
      local NS2="${GLOBAL_DOC_NAMESPACES[$INDEX]}"
      if [ "${NS}" == "${NS2}" ] ; then
        local DOC=${GLOBAL_DOC_STRINGS[$INDEX]}
        COMMAND_RESULT="${COMMAND_RESULT}\n${DOC}\n"
      fi
    done;
    COMMAND_RESULT="${COMMAND_RESULT}\n| Command | Description | Example |"
    COMMAND_RESULT="${COMMAND_RESULT}\n| ------- | ----------- | ------- |"
    for INDEX in "${!GLOBAL_LONG_HELP_COMMANDS[@]}" ; do
      local COMMAND="${GLOBAL_LONG_HELP_COMMANDS[$INDEX]}"
      if [[ ${COMMAND} == ${NS}_* ]] ; then
        local HELP=${GLOBAL_LONG_HELP_STRINGS[$INDEX]}
        local EXAMPLE=""
        for INDEX2 in "${!GLOBAL_EXAMPLE_COMMANDS[@]}" ; do
          local EXAMPLE_COMMAND="${GLOBAL_EXAMPLE_COMMANDS[$INDEX2]}"
          if [ "${COMMAND}" == "${EXAMPLE_COMMAND}" ] ; then
            EXAMPLE='`'"${SCRIPTNAME} ${NS} ${COMMAND##*_} ${GLOBAL_EXAMPLE_STRINGS[$INDEX2]}"'`'
          fi
        done
        COMMAND_RESULT="${COMMAND_RESULT}\n| ${COMMAND##*_} | ${HELP//$'\n'/"<br>"/} | ${EXAMPLE} |"
      fi
    done
    COMMAND_RESULT="${COMMAND_RESULT}\n"
  done;
}

register _doc Print the output of help in markdown

doc "" << EOF
The following commands in the global namespace can be called directly.
EOF
