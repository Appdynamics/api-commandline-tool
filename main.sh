#!/bin/bash

USER_CONFIG="$HOME/.appdynamics/adc/config.sh"
GLOBAL_CONFIG="/etc/appdynamics/adc/config.sh"

CONFIG_CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-controller-cookie.txt"

# Configure default output verbosity. May contain a combination of the following strings:
# - debug
# - error
# - warn
# - info
# - output (msg to stdout)
# An empty string silents all output
CONFIG_OUTPUT_VERBOSITY="error,output"

GLOBAL_COMMANDS=""
GLOBAL_HELP=""
SCRIPTNAME=$0

# register namespace_command help
function register {
  GLOBAL_COMMANDS="$GLOBAL_COMMANDS $1"
  GLOBAL_HELP="$GLOBAL_HELP\n$@"
}

source ./helpers/output.sh
source ./helpers/httpClient.sh
source ./helpers/shiftOptInd.sh

source ./commands/self-setup.sh
source ./commands/help.sh

source ./commands/controller/login.sh
source ./commands/controller/call.sh

source ./commands/dbmon/create.sh

source ./commands/timerange/create.sh

source ./commands/dashboard/list.sh
source ./commands/dashboard/export.sh
source ./commands/dashboard/delete.sh

if [ -f "${GLOBAL_CONFIG}" ]; then
  debug "Sourcing global config from ${GLOBAL_CONFIG} "
  . ${GLOBAL_CONFIG}
else
  warning "File ${GLOBAL_CONFIG} not found!"
fi


if [ -f "${USER_CONFIG}" ]; then
  debug "Sourcing user config from ${USER_CONFIG} "
  . ${USER_CONFIG}
else
  warning "File ${USER_CONFIG} not found!"
fi




# Parse global options
while getopts "H:C:D:" opt;
do
  case "${opt}" in
     H)
	CONFIG_CONTROLLER_HOST=${OPTARG}
	debug "Set CONFIG_CONTROLLER_HOST=${CONFIG_CONTROLLER_HOST}"
     ;;
     C)
        CONFIG_CONTROLLER_CREDENTIALS=${OPTARG}
        debug "Set CONFIG_CONTROLLER_CREDENTIALS=${CONFIG_CONTROLLER_CREDENTIALS}"
     ;;
     J)
	CONFIG_CONTROLLER_COOKIE_LOCATION=${OPTARG}
        debug "Set CONFIG_CONTROLLER_COOKIE_LOCATION=${CONFIG_CONTROLLER_COOKIE_LOCATION}"
     ;;
     D)
	CONFIG_OUTPUT_VERBOSITY=${OPTARG}
        debug "Set CONFIG_OUTPUT_VERBOSITY=${CONFIG_OUTPUT_VERBOSITY}"
  esac 
done

shiftOptInd
shift $SHIFTS

debug "CONFIG_CONTROLLER_HOST=$CONFIG_CONTROLLER_HOST"
debug "CONFIG_CONTROLLER_CREDENTIALS=$CONFIG_CONTROLLER_CREDENTIALS"
debug "CONFIG_CONTROLLER_COOKIE_LOCATION=$CONFIG_CONTROLLER_COOKIE_LOCATION"
debug "CONFIG_OUTPUT_VERBOSITY=$CONFIG_OUTPUT_VERBOSITY"

NAMESPACE=$1

COMMAND_RESULT="Unknown command"

# Check if the namespace is used
if [ "${GLOBAL_COMMANDS/${NAMESPACE}_}" != "$GLOBAL_COMMANDS" ] ; then
 debug "_${NAMESPACE} has commands"
 COMMAND=$2
 if [ "$COMMAND" == "" ] ; then
   _help
 fi 
 if [ "${GLOBAL_COMMANDS/${NAMESPACE}_${COMMAND}}" != "$GLOBAL_COMMANDS" ] ; then
  debug "${NAMESPACE}_${COMMAND} is a valid command"
  shift 2
  ${NAMESPACE}_${COMMAND} $@
 fi
# Check if this is a global command
elif [ "${GLOBAL_COMMANDS/_${NAMESPACE}}" != "$GLOBAL_COMMANDS" ] ; then
 debug "_${NAMESPACE} found as global command"
 shift 1 
 _${NAMESPACE} $@
fi

if [ "$COMMAND_RESULT" != "" ]; then
 output $COMMAND_RESULT
fi

debug END
