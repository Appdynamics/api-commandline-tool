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
COLOR_WARNING="\033[0;33m"
COLOR_INFO="\039[0;33m"
COLOR_ERROR="\033[0;31m"
COLOR_DEBUG="\033[0;35m"
COLOR_RESET="\033[0m"
function debug {
  if [ "${CONFIG_OUTPUT_VERBOSITY/debug}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_DEBUG}DEBUG: $@${COLOR_RESET}"
  fi
}
function error {
  if [ "${CONFIG_OUTPUT_VERBOSITY/error}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_ERROR}ERROR: $@${COLOR_RESET}"
  fi
}
function warning {
  if [ "${CONFIG_OUTPUT_VERBOSITY/warning}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_WARNING}WARNING: $@${COLOR_RESET}"
  fi
}
function info {
  if [ "${CONFIG_OUTPUT_VERBOSITY/info}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_INFO}INFO: $@${COLOR_RESET}"
  fi
}
function output {
  if [ "${CONFIG_OUTPUT_VERBOSITY}" != "" ]; then
    echo -e "$@"
  fi
}
function httpClient {
 curl "$@"
}
SHIFTS=0
declare -i SHIFTS
function shiftOptInd {
  SHIFTS=$OPTIND
  SHIFTS=${SHIFTS}-1
  OPTIND=0
  return $SHIFTS
}
function global_self-setup {
  echo "Self Setup"
  exit 0
}
register _self-setup Initialize the adc configuration file
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
CONTROLLER_LOGIN_STATUS=0
function controller_login {
  debug "Login at $CONFIG_CONTROLLER_HOST with $CONFIG_CONTROLLER_CREDENTIALS"
  LOGIN_RESPONSE=$(httpClient -sI -c $CONFIG_CONTROLLER_COOKIE_LOCATION --user $CONFIG_CONTROLLER_CREDENTIALS $CONFIG_CONTROLLER_HOST/controller/auth?action=login)
  debug "RESPONSE: ${LOGIN_RESPONSE}"
  if [[ "${LOGIN_RESPONSE/200 OK}" != "$LOGIN_RESPONSE" ]]; then
    COMMAND_RESULT="Controller Login Successful"
    CONTROLLER_LOGIN_STATUS=1
  else
    COMMAND_RESULT="Controller Login Error! Please check hostname and credentials"
    CONTROLLER_LOGIN_STATUS=0
  fi
  XCSRFTOKEN=$(tail -1 $CONFIG_CONTROLLER_COOKIE_LOCATION | awk 'NF>1{print $NF}')
  debug "XCSRFTOKEN: $XCSRFTOKEN"
}
register controller_login Login to your controller
function controller_call {
  debug "Calling $CONFIG_CONTROLLER_HOST"
  local METHOD="GET"
  while getopts "X:d:" opt "$@";
  do
    case "${opt}" in
      X)
	METHOD=${OPTARG}
      ;;
      d)
        PAYLOAD=${OPTARG}
      ;;
    esac
  done
 
  shiftOptInd
  shift $SHIFTS
  ENDPOINT=$@
  
  controller_login
  # Debug the COMMAND_RESULT from controller_login
  debug $COMMAND_RESULT
  if [ $CONTROLLER_LOGIN_STATUS -eq 1 ]; then
    COMMAND_RESULT=$(httpClient -s -b $CONFIG_CONTROLLER_COOKIE_LOCATION \
          -X $METHOD\
          -H "X-CSRF-TOKEN: $XCSRFTOKEN" \
          -H "Content-Type: application/json;charset=UTF-8" \
          -H "Accept: application/json, text/plain, */*"\
          -d "$PAYLOAD" \
          $CONFIG_CONTROLLER_HOST$ENDPOINT)
   else
     COMMAND_RESULT="Controller Login Error! Please check hostname and credentials"
   fi
}
register controller_call Send a custom HTTP call to a controller 
function dbmon_create {
  echo "Stub"
}
register dbmon_create Create a new database collector
function timerange_create {
  while getopts "s:e:" opt "$@";
  do
    case "${opt}" in
      s)
        START_TIME=${OPTARG}
      ;;
      e)
        END_TIME=${OPTARG}
      ;;
    esac   
  done;
  shiftOptInd
  shift $SHIFTS
  TIMERANGE_NAME=$@
  controller_call -X POST -d "{\"name\":\"$TIMERANGE_NAME\",\"timeRange\":{\"type\":\"BETWEEN_TIMES\",\"durationInMinutes\":0,\"startTime\":$START_TIME,\"endTime\":$END_TIME}}" /controller/restui/user/createCustomRange
}
register timerange_create Create a custom time range 
function dashboard_list {
  controller_call -X GET /controller/restui/dashboards/getAllDashboardsByType/false
}
register dashboard_list List all dashboards available on the controller
function dashboard_export {
  local DASHBOARD_ID=$@
  if [[ $DASHBOARD_ID =~ ^[0-9]+$ ]]; then
    controller_call -X GET /controller/CustomDashboardImportExportServlet?dashboardId=$@
  else
    COMMAND_RESULT=""
    error "This is not a number: '$DASHBOARD_ID'"
  fi
}
register dashboard_export Export a specific dashboard
function dashboard_delete {
  local DASHBOARD_ID=$@
  if [[ $DASHBOARD_ID =~ ^[0-9]+$ ]]; then
    controller_call -X POST -d "[$DASHBOARD_ID]" /controller/restui/dashboards/deleteDashboards
  else
    COMMAND_RESULT=""
    error "This is not a number: '$DASHBOARD_ID'"
  fi
}
register dashboard_delete Delete a specific dashboard
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
