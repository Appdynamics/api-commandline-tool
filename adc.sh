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
  GLOBAL_HELP="$GLOBAL_HELP\n$*"
}
COLOR_WARNING="\033[0;33m"
COLOR_INFO="\033[0;32m"
COLOR_ERROR="\033[0;31m"
COLOR_DEBUG="\033[0;35m"
COLOR_RESET="\033[0m"
function debug {
  if [ "${CONFIG_OUTPUT_VERBOSITY/debug}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_DEBUG}DEBUG: $*${COLOR_RESET}"
  fi
}
function error {
  if [ "${CONFIG_OUTPUT_VERBOSITY/error}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_ERROR}ERROR: $*${COLOR_RESET}"
  fi
}
function warning {
  if [ "${CONFIG_OUTPUT_VERBOSITY/warning}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_WARNING}WARNING: $*${COLOR_RESET}"
  fi
}
function info {
  if [ "${CONFIG_OUTPUT_VERBOSITY/info}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_INFO}INFO: $*${COLOR_RESET}"
  fi
}
function output {
  if [ "${CONFIG_OUTPUT_VERBOSITY}" != "" ]; then
    echo -e "$*"
  fi
}
function httpClient {
 curl -L --connect-timeout 10 "$@"
}
SHIFTS=0
declare -i SHIFTS
function shiftOptInd {
  SHIFTS=$OPTIND
  SHIFTS=${SHIFTS}-1
  OPTIND=0
  return $SHIFTS
}
# from https://gist.github.com/cdown/1163649
function urlencode {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    LC_COLLATE=$old_lc_collate
}
function recursiveSource {
  if [ -d "$*" ]; then
    debug "Sourcing plugins from $*"
    for file in $*/* ; do
      if [ -f "$file" ] && [ "${file##*.}" == "sh" ] ; then
        . "$file"
      fi
      if [ -d "$file" ] ; then
        recursiveSource $file
      fi
    done
  fi
}
function _self-setup {
  local FORCE=0
  local GLOBAL=0
  while getopts "gf" opt "$@";
  do
    case "${opt}" in
      g)
        GLOBAL=1
      ;;
      f)
        FORCE=1
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  local CONTROLLER_HOST=""
  local CONTROLLER_CREDENTIALS=""
  local OUTPUT_DIRECTORY="${HOME}/.appdynamics/adc"
  local USER_PLUGIN_DIRECTORY="{$HOME}/.appdynamics/adc/plugins"
  local CONTROLLER_COOKIE_LOCATION="${OUTPUT_DIRECTORY}/cookie.txt"
  if [ $GLOBAL -eq 1 ] ; then
    OUTPUT_DIRECTORY="/etc/appdynamics/adc"
    CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-adc-cookie.txt"
  fi
  if [ -z ${CONFIG_CONTROLLER_HOST} ] ; then
   echo "Controller Host location (e.g. https://appdynamics.example.com:8090)"
   read CONTROLLER_HOST
  else
   info "Will use $CONFIG_CONTROLLER_HOST as controller host location"
   CONTROLLER_HOST=$CONFIG_CONTROLLER_HOST
  fi
  if [ -z ${CONFIG_CONTROLLER_CREDENTIALS} ] ; then
   echo "Controller Credentials (e.g. user@tenant:password)"
   read CONTROLLER_CREDENTIALS
  else
   info "Will use $CONFIG_CONTROLLER_CREDENTIALS as controller credentials"
   CONTROLLER_CREDENTIALS=$CONFIG_CONTROLLER_CREDENTIALS
  fi
  OUTPUT="CONFIG_CONTROLLER_HOST=${CONTROLLER_HOST}\nCONFIG_CONTROLLER_CREDENTIALS=${CONTROLLER_CREDENTIALS}\nCONFIG_CONTROLLER_COOKIE_LOCATION=${CONTROLLER_COOKIE_LOCATION}\nCONFIG_USER_PLUGIN_DIRECTORY=${USER_PLUGIN_DIRECTORY}"
  if [ ! -s "$OUTPUT_DIRECTORY/config.sh" ] || [ $FORCE -eq 1 ]
  then
    mkdir -p $OUTPUT_DIRECTORY
    echo -e "$OUTPUT" > "$OUTPUT_DIRECTORY/config.sh"
    COMMAND_RESULT="Created $OUTPUT_DIRECTORY/config.sh successfully"
  else
    error "Configuration file $OUTPUT_DIRECTORY/config.sh already exists. Please use (-f) to force override"
    COMMAND_RESULT=""
  fi
}
register _self-setup Initialize the adc configuration file
function _help {
  COMMAND_RESULT="Usage: $SCRIPTNAME <namespace> <command>\n"
  COMMAND_RESULT="${COMMAND_RESULT}\nTo execute a action, provide a namespace and a command, e.g. \"dbmon list\" to list all database collectors.\nFinally the following commands in the global namespace can be called directly:\n"
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
  ENDPOINT=$*
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
CONTROLLER_LOGIN_STATUS=0
function controller_ping {
  debug "Ping $CONFIG_CONTROLLER_HOST"
  local PING_RESPONSE=$(httpClient -sI $CONFIG_CONTROLLER_HOST  -w "TIME_TOTAL=%{time_total}")
  debug "RESPONSE: ${PING_RESPONSE}"
  if [[ "${PING_RESPONSE/200 OK}" != "$Ping_RESPONSE" ]]; then
    local TIME=${PING_RESPONSE##*TIME_TOTAL=}
    COMMAND_RESULT="Pong! Time: ${TIME}"
  else
    COMMAND_RESULT="Error"
  fi
}
register controller_ping Check the availability of an appdynamics controller
function dbmon_create {
  echo "Stub"
}
register dbmon_create Create a new database collector
function event_create {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local NODE
  local TIER
  local SEVERITY
  local EVENTTYPE
  local BT
  local COMMENT
  while getopts "n:e:s:t:c:a:" opt "$@";
  do
    case "${opt}" in
      n)
        NODE=${OPTARG}
      ;;
      t)
        TIER=${OPTARG}
      ;;
      s)
        SEVERITY=${OPTARG}
      ;;
      e)
        EVENTTYPE=${OPTARG}
      ;;
      b)
        BT=${OPTARG}
      ;;
      c)
        COMMENT=`urlencode "$OPTARG"`
      ;;
      a)
        APPLICATION=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  SUMMARY=`urlencode "$*"`
  debug -X POST "/controller/rest/applications/${APPLICATION}/events?summary=${SUMMARY}&comment=${COMMENT}&eventtype=${EVENTTYPE}&severity=${SEVERITY}&bt=${BT}&node=${NODE}&tier=${TIER}"
  controller_call -X POST "/controller/rest/applications/${APPLICATION}/events?summary=${SUMMARY}&comment=${COMMENT}&eventtype=${EVENTTYPE}&severity=${SEVERITY}&bt=${BT}&node=${NODE}&tier=${TIER}"
}
register event_create Create a custom event for a given application
function timerange_create {
  local START_TIME=-1
  local END_TIME=-1
  local DURATION_IN_MINUTES=0
  local TYPE=BETWEEN_TIMES
  while getopts "s:e:b:" opt "$@";
  do
    case "${opt}" in
      s)
        START_TIME=${OPTARG}
      ;;
      e)
        END_TIME=${OPTARG}
      ;;
      b)
        DURATION_IN_MINUTES=${OPTARG}
        TYPE="BEFORE_NOW"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  TIMERANGE_NAME=$*
  controller_call -X POST -d "{\"name\":\"$TIMERANGE_NAME\",\"timeRange\":{\"type\":\"$TYPE\",\"durationInMinutes\":$DURATION_IN_MINUTES,\"startTime\":$START_TIME,\"endTime\":$END_TIME}}" /controller/restui/user/createCustomRange
}
register timerange_create Create a custom time range
function timerange_list {
  controller_call -X GET /controller/restui/user/getAllCustomTimeRanges
}
register timerange_list List all custom timeranges available on the controller
function timerange_delete {
  local TIMERANGE_ID=$*
  if [[ $TIMERANGE_ID =~ ^[0-9]+$ ]]; then
    controller_call -X POST -d "$TIMERANGE_ID" /controller/restui/user/deleteCustomRange
  else
    COMMAND_RESULT=""
    error "This is not a number: '$TIMERANGE_ID'"
  fi
}
register timerange_delete Delete a specific time range by id
function dashboard_list {
  controller_call -X GET /controller/restui/dashboards/getAllDashboardsByType/false
}
register dashboard_list List all dashboards available on the controller
function dashboard_export {
  local DASHBOARD_ID=$*
  if [[ $DASHBOARD_ID =~ ^[0-9]+$ ]]; then
    controller_call -X GET /controller/CustomDashboardImportExportServlet?dashboardId=$DASHBOARD_ID
  else
    COMMAND_RESULT=""
    error "This is not a number: '$DASHBOARD_ID'"
  fi
}
register dashboard_export Export a specific dashboard
function dashboard_delete {
  local DASHBOARD_ID=$*
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
while getopts "H:C:D:P:F:" opt;
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
    ;;
    A)
      CONFIG_OUTPUT_VERBOSITY=${OPTARG}
      debug "Set CONFIG_OUTPUT_VERBOSITY=${CONFIG_OUTPUT_VERBOSITY}"
    ;;
    P)
      CONFIG_USER_PLUGIN_DIRECTORY=${OPTARG}
      debug "Set CONFIG_USER_PLUGIN_DIRECTORY=${CONFIG_USER_PLUGIN_DIRECTORY}"
    ;;
    F)
      CONTROLLER_INFO_XML=${OPTARG}
      debug "Reading CONFIG_CONTROLLER_HOST from $CONTROLLER_INFO_XML"
      CONTROLLER_INFO_XML_HOST="$(sed -n -e "s/<controller-host>\(.*\)<\/controller-host>/\1/p" $CONTROLLER_INFO_XML)"
      CONTROLLER_INFO_XML_PORT="$(sed -n -e "s/<controller-port>\(.*\)<\/controller-port>/\1/p" $CONTROLLER_INFO_XML)"
      CONTROLLER_INFO_XML_SSL_ENABLED="$(sed -n -e "s/<controller-ssl-enabled>\(.*\)<\/controller-ssl-enabled>/\1/p" $CONTROLLER_INFO_XML)"
      [[ ${CONTROLLER_INFO_XML_SSL_ENABLED// /} == "true" ]] && CONTROLLER_INFO_XML_SCHEMA=https || CONTROLLER_INFO_XML_SCHEMA=http
      CONFIG_CONTROLLER_HOST=${CONTROLLER_INFO_XML_SCHEMA}://${CONTROLLER_INFO_XML_HOST// /}:${CONTROLLER_INFO_XML_PORT// /}
      debug "Set CONFIG_CONTROLLER_HOST=${CONFIG_CONTROLLER_HOST}"
    ;;
  esac
done
shiftOptInd
shift $SHIFTS
debug "CONFIG_CONTROLLER_HOST=$CONFIG_CONTROLLER_HOST"
debug "CONFIG_CONTROLLER_CREDENTIALS=$CONFIG_CONTROLLER_CREDENTIALS"
debug "CONFIG_CONTROLLER_COOKIE_LOCATION=$CONFIG_CONTROLLER_COOKIE_LOCATION"
debug "CONFIG_OUTPUT_VERBOSITY=$CONFIG_OUTPUT_VERBOSITY"
debug "CONFIG_USER_PLUGIN_DIRECTORY=$CONFIG_USER_PLUGIN_DIRECTORY"
recursiveSource "${CONFIG_USER_PLUGIN_DIRECTORY}"
NAMESPACE=$1
COMMAND_RESULT=""
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
    ${NAMESPACE}_${COMMAND} "$@"
  else
    _help
  fi
  # Check if this is a global command
elif [ "${GLOBAL_COMMANDS/_${NAMESPACE}}" != "$GLOBAL_COMMANDS" ] ; then
  debug "_${NAMESPACE} found as global command"
  shift 1
  _${NAMESPACE} "$@"
else
  COMMAND_RESULT="Unknown command: $*"
fi
echo -e "$COMMAND_RESULT"
debug END
