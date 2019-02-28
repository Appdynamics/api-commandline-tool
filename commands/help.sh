#!/bin/bash

function _help {
  if [ "$1" = "" ] ; then
    read -r -d '' COMMAND_RESULT <<- EOM
Usage: ${USAGE_DESCRIPTION}${EOL}

You can use the following options on a global level:${EOL}

${AVAILABLE_GLOBAL_OPTIONS//|/}${EOL}

To execute a action, provide a namespace and a command, e.g. \"metrics get\" to get a specific metric.
The following commands in the global namespace can be called directly:
EOM
    local NAMESPACE=""
    local SORTED
    SORTED=`echo -en "$GLOBAL_HELP" | sort`
    OLD_IFS=$IFS
    IFS=$'\n'
    for LINE in $SORTED; do
      NEW_NAMESPACE=${LINE%%_*}
      if [ "$NEW_NAMESPACE" != "$NAMESPACE" ]
      then
        COMMAND_RESULT="${COMMAND_RESULT}${EOL}$NEW_NAMESPACE${EOL}"
        NAMESPACE=$NEW_NAMESPACE
      fi
      COMMAND=${LINE##*_}
      COMMAND_RESULT="${COMMAND_RESULT}${TAB}${COMMAND%% *} - ${COMMAND#* }${EOL}"
    done
    IFS=$OLD_IFS
    COMMAND_RESULT="${COMMAND_RESULT}${EOL}Run $SCRIPTNAME help <namespace> to get detailed help on subcommands in that namespace."
  else
    COMMAND_RESULT="Usage $SCRIPTNAME ${1} <command>"
    for INDEX in "${!GLOBAL_DOC_NAMESPACES[@]}" ; do
      local NS2="${GLOBAL_DOC_NAMESPACES[$INDEX]}"
      if [ "${1}" == "${NS2}" ] ; then
        local DOC=${GLOBAL_DOC_STRINGS[$INDEX]}
        COMMAND_RESULT="${COMMAND_RESULT}${EOL}${EOL}${DOC}${EOL}"
      fi
    done;
    COMMAND_RESULT="${COMMAND_RESULT}${EOL}To execute a action within the ${1} namespace provide one of the following commands:${EOL}"
    for INDEX in "${!GLOBAL_LONG_HELP_COMMANDS[@]}" ; do
      local COMMAND="${GLOBAL_LONG_HELP_COMMANDS[$INDEX]}"
      if [[ $COMMAND == $1_* ]] ; then
        COMMAND_RESULT="${COMMAND_RESULT}${EOL}--- ${COMMAND##*_} ---${EOL}${GLOBAL_LONG_HELP_STRINGS[$INDEX]}${EOL}"
        for INDEX2 in "${!GLOBAL_EXAMPLE_COMMANDS[@]}" ; do
          local EXAMPLE_COMMAND="${GLOBAL_EXAMPLE_COMMANDS[$INDEX2]}"
          if [ "${COMMAND}" == "${EXAMPLE_COMMAND}" ] ; then
            COMMAND_RESULT="${COMMAND_RESULT}${EOL}Example: ${SCRIPTNAME} ${1} ${COMMAND##*_} ${GLOBAL_EXAMPLE_STRINGS[$INDEX2]}${EOL}"
          fi
        done
      fi
    done
  fi
}

register _help Display the global help.
