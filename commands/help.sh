#!/bin/bash

function _help {
  COMMAND_RESULT="Usage: $SCRIPTNAME <namespace> <command>\n"
  COMMAND_RESULT="${COMMAND_RESULT}\nTo execute a action, provide a namespace and a command, e.g. \"dbmon list\" to list all database collectors.\nFinally the following commands in the global namespace can be called directly:\n"
  local NAMESPACE=""
  local SORTED=`echo -en "$GLOBAL_HELP" | sort`
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
}

register _help Display the global usage information 
