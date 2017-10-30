#!/bin/bash

function _help {
  if [ "$1" = "" ] ; then
    COMMAND_RESULT="Usage: $SCRIPTNAME [-H <controller-host>] [-C <controller-credentials>] [-D <output-verbosity>] [-P <plugin-directory>] [-A <application-name>] <namespace> <command>\n"
    COMMAND_RESULT="${COMMAND_RESULT}\nYou can use the following options on a global level:\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-H <controller-host>\t\t specify the host of the controller you want to connect to\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-C <controller-credentials>\t provide the credentials for the controller. Format: user@tenant:password\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-D <output-verbosity>\t\t Change the output verbosity. Provide a list of the following values: debug,error,warn,info,output\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-D <application-name>\t\t Provide a default application"
    COMMAND_RESULT="${COMMAND_RESULT}\nTo execute a action, provide a namespace and a command, e.g. \"metrics get\" to get a specific metric.\nFinally the following commands in the global namespace can be called directly:\n"
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
    COMMAND_RESULT="Usage $SCRIPTNAME $1 <command>"
    COMMAND_RESULT="${COMMAND_RESULT}\nTo execute a action within the $1 namespace provide one of the following commands:\n"
    for INDEX in "${!GLOBAL_LONG_HELP_COMMANDS[@]}" ; do
      local COMMAND="${GLOBAL_LONG_HELP_COMMANDS[$INDEX]}"
      if [[ $COMMAND == $1_* ]] ; then
        COMMAND_RESULT="${COMMAND_RESULT}\n--- ${COMMAND##*_} ---\n${GLOBAL_LONG_HELP_STRINGS[$INDEX]}\n"
      fi
    done
  fi
}

register _help Display the global usage information
