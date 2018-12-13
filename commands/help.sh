#!/bin/bash

function _help {
  if [ "$1" = "" ] ; then
    read -r -d '' COMMAND_RESULT <<- EOM
Usage: $SCRIPTNAME [-H <controller-host>] [-C <controller-credentials>] [-D <output-verbosity>] [-P <plugin-directory>] [-A <application-name>] <namespace> <command>\n

You can use the following options on a global level:\n

${AVAILABLE_GLOBAL_OPTIONS//|/}

To execute a action, provide a namespace and a command, e.g. \"metrics get\" to get a specific metric.\n
The following commands in the global namespace can be called directly:\n
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
        COMMAND_RESULT="${COMMAND_RESULT}\n$NEW_NAMESPACE\n"
        NAMESPACE=$NEW_NAMESPACE
      fi
      COMMAND=${LINE##*_}
      COMMAND_RESULT="${COMMAND_RESULT}\t${COMMAND%% *}\t\t${COMMAND#* }\n"
    done
    IFS=$OLD_IFS
    COMMAND_RESULT="${COMMAND_RESULT}\nRun $SCRIPTNAME help <namespace> to get detailed help on subcommands in that namespace."
  else
    COMMAND_RESULT="Usage $SCRIPTNAME ${1} <command>"
    for INDEX in "${!GLOBAL_DOC_NAMESPACES[@]}" ; do
      local NS2="${GLOBAL_DOC_NAMESPACES[$INDEX]}"
      if [ "${1}" == "${NS2}" ] ; then
        local DOC=${GLOBAL_DOC_STRINGS[$INDEX]}
        COMMAND_RESULT="${COMMAND_RESULT}\n\n${DOC}\n"
      fi
    done;
    COMMAND_RESULT="${COMMAND_RESULT}\nTo execute a action within the ${1} namespace provide one of the following commands:\n"
    for INDEX in "${!GLOBAL_LONG_HELP_COMMANDS[@]}" ; do
      local COMMAND="${GLOBAL_LONG_HELP_COMMANDS[$INDEX]}"
      if [[ $COMMAND == $1_* ]] ; then
        COMMAND_RESULT="${COMMAND_RESULT}\n--- ${COMMAND##*_} ---\n${GLOBAL_LONG_HELP_STRINGS[$INDEX]}\n"
        for INDEX2 in "${!GLOBAL_EXAMPLE_COMMANDS[@]}" ; do
          local EXAMPLE_COMMAND="${GLOBAL_EXAMPLE_COMMANDS[$INDEX2]}"
          if [ "${COMMAND}" == "${EXAMPLE_COMMAND}" ] ; then
            COMMAND_RESULT="${COMMAND_RESULT}\nExample: ${SCRIPTNAME} ${1} ${COMMAND##*_} ${GLOBAL_EXAMPLE_STRINGS[$INDEX2]}\n"
          fi
        done
      fi
    done
  fi
}

register _help Display the global usage information
