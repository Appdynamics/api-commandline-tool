#!/bin/bash
ACT_VERSION="v0.4.0"
ACT_LAST_COMMIT="bbcc9da147aba4682c4939d050e3330ac3bfb179"
USER_CONFIG="$HOME/.appdynamics/act/config.sh"
GLOBAL_CONFIG="/etc/appdynamics/act/config.sh"
CONFIG_CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-controller-cookie.txt"
CONFIG_PORTAL_COOKIE_LOCATION="/tmp/appdynamics-portal-cookie.txt"
# Configure default output verbosity. May contain a combination of the following strings:
# - debug
# - error
# - warn
# - info
# - output (msg to stdout)
# An empty string silents all output
CONFIG_OUTPUT_VERBOSITY="error,output"
# Default Colors
COLOR_WARNING="\033[0;33m"
COLOR_INFO="\033[0;32m"
COLOR_ERROR="\033[0;31m"
COLOR_DEBUG="\033[0;35m"
COLOR_RESET="\033[0m"
GLOBAL_COMMANDS=""
GLOBAL_HELP=""
GLOBAL_LONG_HELP_COUNTER=0
declare -a GLOBAL_LONG_HELP_STRINGS
declare -a GLOBAL_LONG_HELP_COMMANDS
SCRIPTNAME=$(basename "$0")
VERBOSITY_COUNTER=0
declare -i VERBOSITY_COUNTER
# register namespace_command help
function register {
  GLOBAL_COMMANDS="$GLOBAL_COMMANDS $1"
  GLOBAL_HELP="$GLOBAL_HELP\n$*"
}
function describe {
  GLOBAL_LONG_HELP_COMMANDS[${#GLOBAL_LONG_HELP_COMMANDS[@]}]="$1"
  GLOBAL_LONG_HELP_STRINGS[${#GLOBAL_LONG_HELP_STRINGS[@]}]=$(cat)
}
function dbmon_get {
  apiCall "/controller/restui/databases/collectors/configurations/\${c}" "$@"
}
register dbmon_get Retrieve information about a specific database collector
describe dbmon_get << EOF
Retrieve information about a specific database collector. Provide the collector id as parameter.
EOF
function dbmon_delete {
    apiCall -X POST -d "[\"\${c}\"]" /controller/restui/databases/collectors/configuration/batchDelete "$@"
}
register dbmon_delete Delete a database collector
describe dbmon_delete << EOF
Delete a database collector. Provide the collector id as parameter.
EOF
function dbmon_create {
  apiCall -X POST -d "{ \
                      \"name\": \"\${i}\",\
                      \"username\": \"\${u}\",\
                      \"hostname\": \"\${h}\",\
                      \"agentName\": \"\${a}\",\
                      \"type\": \"\${t}\",\
                      \"orapkiSslEnabled\": false,\
                      \"orasslTruststoreLoc\": null,\
                      \"orasslTruststoreType\": null,\
                      \"orasslTruststorePassword\": null,\
                      \"orasslClientAuthEnabled\": false,\
                      \"orasslKeystoreLoc\": null,\
                      \"orasslKeystoreType\": null,\
                      \"orasslKeystorePassword\": null,\
                      \"databaseName\": \"\${n}\",\
                      \"port\": \"\${p}\",\
                      \"password\": \"\${s}\",\
                      \"excludedSchemas\": [],\
                      \"enabled\": true\
                    }" /controller/restui/databases/collectors/createConfiguration "$@"
}
register dbmon_create Create a new database collector
describe dbmon_create << EOF
Create a new database collector. You need to provide the following parameters:
  -i name
  -u user name
  -h host name
  -a agent name
  -t type
  -d database name
  -p port
  -s password
EOF
function dbmon_list {
  controller_call /controller/restui/databases/collectors/
}
register dbmon_list List all database collectors
describe dbmon_list << EOF
List all database collectors
EOF
function snapshot_list {
  apiCall '/controller/rest/applications/${a}/request-snapshots?time-range-type=${t}&duration-in-mins=${d?}&start-time=${b?}&end-time=${f?}' "$@"
}
register snapshot_list Retrieve a list of snapshots for a specific application
describe application_list << EOF
Retrieve a list of snapshots for a specific application.
EOF
function configuration_set {
  apiCall -X POST '/controller/rest/configuration?name=${n}&value=${v}' "$@"
}
register configuration_set Set a Controller setting to a specified value.
describe configuration_set << EOF
Set a Controller setting to a specified value. Provide a name (-n) and a value (-v) as parameters
EOF
function configuration_get {
  apiCall -X GET '/controller/rest/configuration?name=${n}' "$@"
}
register configuration_get Retrieve a Controller Setting by Name
describe configuration_get << EOF
Retrieve a Controller Setting by Name. Provide a name (-n) as parameter
EOF
function configuration_list {
  apiCall -X GET "/controller/rest/configuration" "$@"
}
register configuration_list Retrieve All Controller Settings
describe configuration_list << EOF
Retrieve All Controller Settings
EOF
PORTAL_LOGIN_STATUS=0
function portal_login {
  if [ -n "$CONFIG_PORTAL_CREDENTIALS" ] ; then
    debug "Login at 'https://login.appdynamics.com/sso/login/' with $CONFIG_PORTAL_CREDENTIALS"
    LOGIN_RESPONSE=$(httpClient -s -c ${CONFIG_PORTAL_COOKIE_LOCATION} -d "username=${CONFIG_PORTAL_CREDENTIALS%%:*}&password=${CONFIG_PORTAL_CREDENTIALS##*:}" 'https://login.appdynamics.com/sso/login/')
    grep -q sso-sessionid ${CONFIG_PORTAL_COOKIE_LOCATION} && PORTAL_LOGIN_STATUS=1
    if [ $PORTAL_LOGIN_STATUS -eq 1 ]; then
      COMMAND_RESULT="Portal Login Successful"
    else
      COMMAND_RESULT="Portal Login Error! Please check your credentials"
    fi
  else
    COMMAND_RESULT="Please run $1 config -p to setup portal credentials."
  fi
}
register portal_login Login to portal.appdynamics.com
describe portal_login << EOF
Login to portal.appdynamics.com
EOF
function portal_download {
  local VERSION=0
  local OPERATING_SYSTEM=`uname -s`
  local MACHINE_HARDWARE=`uname -m`
  local MACHINE_HARDWARE_BITS=""
  local INSTALLER_SUFFIX=".sh"
  while getopts "v:s:m:" opt "$@";
  do
    case "${opt}" in
      v)
        VERSION=${OPTARG}
      ;;
      s)
        OPERATING_SYSTEM=${OPTARG}
      ;;
      m)
        MACHINE_HARDWARE=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  local TARGET=$*
  if [ $VERSION = "0" ] ; then
    controller_version
    VERSION=$COMMAND_RESULT
  fi
  local FILE=""
  case "$OPERATING_SYSTEM" in
    Darwin|darwin|OSX|osx)
      OPERATING_SYSTEM="osx"
      INSTALLER_SUFFIX=".dmg"
    ;;
    linux|Linux)
      OPERATING_SYSTEM="linux"
      INSTALLER_SUFFIX=".sh"
    ;;
    SunOS)
      OPERATING_SYSTEM="solaris-sparc"
      INSTALLER_SUFFIX=".sh"
    ;;
    Windows|windows|win)
    OPERATING_SYSTEM="windows"
    INSTALLER_SUFFIX=".msi"
    ;;
  esac
  case "$MACHINE_HARDWARE" in
    64bit|x86_64|64)
      MACHINE_HARDWARE="x64"
      MACHINE_HARDWARE_BITS="64bit"
    ;;
    32bit|i686)
      MACHINE_HARDWARE="x32"
      MACHINE_HARDWARE_BITS="32bit"
    ;;
  esac
  case "$TARGET" in
    java*)
      FILE="sun-jvm/$VERSION/AppServerAgent-$VERSION.zip"
    ;;
    universal*)
      FILE="universal-agent/$VERSION/universal-agent-$MACHINE_HARDWARE-$OPERATING_SYSTEM-$VERSION.zip"
    ;;
    machine*)
      FILE="machine-bundle/$VERSION/machineagent-bundle-$MACHINE_HARDWARE_BITS-$OPERATING_SYSTEM-$VERSION.zip"
    ;;
    controller)
      FILE="controller/$VERSION/controller_${MACHINE_HARDWARE_BITS}_$OPERATING_SYSTEM-$VERSION$INSTALLER_SUFFIX"
    ;;
    file*)
      shift
      FILE=$*
    ;;
    *)
      COMMAND_RESULT="Unknown agent type: $TARGET"
    ;;
  esac
  if [ "$FILE" != "" ]; then
    portal_login
    if [ $PORTAL_LOGIN_STATUS -eq 1 ] ; then
      info "Downloading https://download.appdynamics.com/download/prox/download-file/$FILE"
      httpClient -O -b $CONFIG_PORTAL_COOKIE_LOCATION https://download.appdynamics.com/download/prox/download-file/$FILE
    fi
  fi
}
register portal_download Download an appdynamics agent
describe portal_download << EOF
Download an appdynamics agent
EOF
function _help {
  if [ "$1" = "" ] ; then
    COMMAND_RESULT="Usage: $SCRIPTNAME [-H <controller-host>] [-C <controller-credentials>] [-D <output-verbosity>] [-P <plugin-directory>] [-A <application-name>] <namespace> <command>\n"
    COMMAND_RESULT="${COMMAND_RESULT}\nYou can use the following options on a global level:\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-H <controller-host>\t\t specify the host of the controller you want to connect to\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-C <controller-credentials>\t provide the credentials for the controller. Format: user@tenant:password\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-D <output-verbosity>\t\t Change the output verbosity. Provide a list of the following values: debug,error,warn,info,output\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-A <application-name>\t\t Provide a default application\n"
    COMMAND_RESULT="${COMMAND_RESULT}\t-v[vv] \t\t\t\t Increase application verbosity: v = warn, vv = warn,info, vvv = warn,info,debug\n"
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
function server_list {
  apiCall -X GET "/controller/sim/v2/user/machines" "$@"
}
register server_list List all servers
describe server_list << EOF
List all servers
EOF
function controller_isup {
  local START
  local END
  declare -i END
  START=`date +%s`
  controller_ping
  while [ "$COMMAND_RESULT" = "Error" ] ; do
    controller_ping
    sleep 1
  done
  sleep 1
  END=`date +%s`
  END=$END-$START
  COMMAND_RESULT="Controller at $CONFIG_CONTROLLER_HOST up after $END seconds"
}
register controller_isup Pause until controller is up
describe controller_isup << EOF
This command will pause until the controller is up. Use this to get notified after the controller is booted successfully.
EOF
function controller_call {
  debug "Calling $CONFIG_CONTROLLER_HOST"
  local METHOD="GET"
  local FORM=""
  while getopts "X:d:F:" opt "$@";
  do
    case "${opt}" in
      X)
	METHOD=${OPTARG}
      ;;
      d)
        PAYLOAD=${OPTARG}
      ;;
      F)
        FORM=${OPTARG}
      ;;
    esac
  done
  shiftOptInd
  shift $SHIFTS
  ENDPOINT=$*
  controller_login
  # Debug the COMMAND_RESULT from controller_login
  debug "Login result: $COMMAND_RESULT"
  if [ $CONTROLLER_LOGIN_STATUS -eq 1 ]; then
    debug "Endpoint: $ENDPOINT"
    COMMAND_RESULT=$(httpClient -s -b $CONFIG_CONTROLLER_COOKIE_LOCATION \
          -X $METHOD\
          -H "X-CSRF-TOKEN: $XCSRFTOKEN" \
          "$([ -z "$FORM" ] && echo "-HContent-Type: application/json;charset=UTF-8")" \
          -H "Accept: application/json, text/plain, */*"\
          "`[ -n "$PAYLOAD" ] && echo -d ${PAYLOAD}`" \
          "`[ -n "$FORM" ] && echo -F ${FORM}`" \
          $CONFIG_CONTROLLER_HOST$ENDPOINT)
    debug "Command result: $COMMAND_RESULT"
   else
     COMMAND_RESULT="Controller Login Error! Please check hostname and credentials"
   fi
}
register controller_call Send a custom HTTP call to a controller
describe controller_call << EOF
Send a custom HTTP call to an AppDynamics controller. Provide the endpoint you want to call as parameter:\n
$0 controller call /controller/restui/health_rules/getHealthRuleCurrentEvaluationStatus/app/41/healthRuleID/233\n
You can modify the http method with option -X and add payload with option -d.
EOF
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
  XCSRFTOKEN=$(grep "X-CSRF-TOKEN" $CONFIG_CONTROLLER_COOKIE_LOCATION | awk 'NF>1{print $NF}')
  debug "XCSRFTOKEN: $XCSRFTOKEN"
}
register controller_login Login to your controller
describe controller_login << EOF
Check if the login with your appdynamics controller works properly.
If the login fails, use $1 controller ping to check if the controller is running and check your credentials if they are correct.
EOF
function controller_ping {
  debug "Ping $CONFIG_CONTROLLER_HOST"
  local PING_RESPONSE=$(httpClient -sI $CONFIG_CONTROLLER_HOST  -w "RESPONSE=%{http_code} TIME_TOTAL=%{time_total}")
  debug "RESPONSE: ${PING_RESPONSE}"
  if [ -n "$PING_RESPONSE" ] && [[ "${PING_RESPONSE/200 OK}" != "$PING_RESPONSE" ]]; then
    local TIME=${PING_RESPONSE##*TIME_TOTAL=}
    COMMAND_RESULT="Pong! Time: ${TIME}"
  else
    COMMAND_RESULT="Error"
  fi
}
register controller_ping Check the availability of an appdynamics controller
describe controller_ping << EOF
Check the availability of an appdynamics controller. On success the response time will be provided.
EOF
function controller_status {
  controller_call -X GET /controller/rest/serverstatus
}
register controller_status Get server status from controller
describe controller_status << EOF
This command will return a XML containing status information about the controller.
EOF
function controller_version {
  controller_call -X GET /controller/rest/serverstatus
  COMMAND_RESULT=`echo -e $COMMAND_RESULT | sed -n -e 's/.*Controller v\(.*\) Build.*/\1/p'`
}
register controller_version Get installed version from controller
describe controller_version << EOF
Get installed version from controller
EOF
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
describe dashboard_delete << EOF
Delete a specific dashboard
EOF
#
function dashboard_update {
  apiCall -X POST -d @\$\{f\} /controller/restui/dashboards/updateDashboard "$@"
}
register dashboard_update Update a specific dashboard
describe dashboard_update << EOF
Update a specific dashboard. Please not that the json you need to provide is not compatible with the export format!
EOF
function dashboard_import {
  FILE="$*"
  if [ -r $FILE ] ; then
    controller_call -X POST -F file=@$FILE /controller/CustomDashboardImportExportServlet
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}
register dashboard_import Import a dashboard
describe dashboard_import << EOF
Import a dashboard from a given file
EOF
function dashboard_list {
  controller_call -X GET /controller/restui/dashboards/getAllDashboardsByType/false
}
register dashboard_list List all dashboards available on the controller
describe dashboard_list << EOF
List all dashboards available on the controller
EOF
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
describe dashboard_export << EOF
Export a specific dashboard
EOF
function actiontemplate_createmediatype {
  apiCall -X POST -d '{"name":"${n}","builtIn":false}' '/controller/restui/httpaction/createHttpRequestActionMediaType' "$@"
}
register actiontemplate_createmediatype "Create a custom media type"
describe actiontemplate_createmediatype << EOF
Create a custom media type. Provide the name of the media type as parameter (-n)
EOF
function actiontemplate_import {
  local FILE=""
  local TYPE="httprequest"
  while getopts "t:" opt "$@";
  do
    case "${opt}" in
      t)
        TYPE=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  FILE="$*"
  if [ -r $FILE ] ; then
    controller_call -X POST -F file="@$FILE" "/controller/actiontemplate/${TYPE}"
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}
register actiontemplate_import "Import an action template of a given type (email, httprequest)"
describe actiontemplate_import << EOF
Import an action template of a given type (email, httprequest)
EOF
function actiontemplate_export {
  apiCall -X GET '/controller/actiontemplate/${t}/ ' "$@"
}
register actiontemplate_export "Export all templates of a given type (-t email or httprequest)"
describe actiontemplate_export << EOF
Export all templates of a given type (-t email or httprequest)
EOF
function federation_setup {
  local FRIEND_CONTROLLER_CREDENTIALS=""
  local FRIEND_CONTROLLER_HOST=""
  local KEY_NAME=""
  local MY_ACCOUNT=${CONFIG_CONTROLLER_CREDENTIALS##*@}
  MY_ACCOUNT=${MY_ACCOUNT%%:*}
  while getopts "c:h:k:" opt "$@";
  do
    case "${opt}" in
      c)
        FRIEND_CONTROLLER_CREDENTIALS=${OPTARG}
      ;;
      h)
        FRIEND_CONTROLLER_HOST=${OPTARG}
      ;;
      k)
        KEY_NAME=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  if [ -z "$KEY_NAME" ] ; then
    local FRIEND_ACCOUNT=${FRIEND_CONTROLLER_CREDENTIALS##*@}
    FRIEND_ACCOUNT=${FRIEND_ACCOUNT%%:*}
    KEY_NAME=${FRIEND_ACCOUNT}_${FRIEND_CONTROLLER_HOST//[:\/]/_}_$RANDOM
  fi;
  federation_createkey -n $KEY_NAME
  debug "Key creation result: $COMMAND_RESULT"
  KEY=${COMMAND_RESULT##*\"key\": \"}
  KEY=${KEY%%\",\"*}
  debug "Identified key: $KEY"
  debug "Establishing mutual friendship: $0 -J /tmp/appdynamics-federation-cookie.txt -H $FRIEND_CONTROLLER_HOST -C $FRIEND_CONTROLLER_CREDENTIALS federation establish -a $MY_ACCOUNT -k $KEY -c $CONFIG_CONTROLLER_HOST"
  FRIEND_RESULT=`$0 -J /tmp/appdynamics-federation-cookie.txt -H "$FRIEND_CONTROLLER_HOST" -C "$FRIEND_CONTROLLER_CREDENTIALS" federation establish -a "$MY_ACCOUNT" -k "$KEY" -c "$CONFIG_CONTROLLER_HOST"`
  if [ -z "$FRIEND_RESULT" ] ; then
    COMMAND_RESULT="Federation between $CONFIG_CONTROLLER_HOST and $FRIEND_CONTROLLER_HOST successfully established."
  else
    COMMAND_RESULT=""
    error "Federation setup failed. Error from $FRIEND_CONTROLLER_HOST: ${FRIEND_RESULT}"
  fi
  rm /tmp/appdynamics-federation-cookie.txt
}
register federation_setup Setup a controller federation: Generates a key and establishes the mutal friendship.
describe federation_setup << EOF
Setup a controller federation: Generates a key and establishes the mutal friendship.
EOF
function federation_createkey {
  apiCall -X POST -d '{"apiKeyName": "${n}"}' "/controller/rest/federation/apikeyforfederation" "$@"
}
register federation_createkey Create API Key for Federation
describe federation_createkey << EOF
Create API Key for Federation.
EOF
function federation_establish {
  local ACCOUNT=${CONFIG_CONTROLLER_CREDENTIALS##*@}
  ACCOUNT=${ACCOUNT%%:*}
  info "Establishing friendship..."
  apiCall -X POST -d "{ \
    \"accountName\": \"${ACCOUNT}\", \
    \"controllerUrl\": \"${CONFIG_CONTROLLER_HOST}\", \
    \"friendAccountName\": \"\${a}\", \
    \"friendAccountApiKey\": \"\${k}\", \
    \"friendAccountControllerUrl\": \"\${c}\" \
  }" "/controller/rest/federation/establishmutualfriendship" "$@"
}
register federation_establish Establish Mutual Friendship
describe federation_establish << EOF
Establish Mutual Friendship
EOF
function application_get {
  apiCall '/controller/rest/applications/${a}' "$@"
}
register application_get Get an application
describe application_get << EOF
Get an application. Provide application id or name as parameter (-a).
EOF
function bt_list {
  apiCall -X GET "/controller/rest/applications/\${a}/business-transactions" "$@"
}
register bt_list List all business transactions for a given application
describe bt_list << EOF
List all business transactions for a given application. Provide the application id as parameter.
EOF
function eum_getapps {
  apiCall  "/controller/restui/eumApplications/getAllEumApplicationsData?time-range=last_1_hour.BEFORE_NOW.-1.-1.60"
}
register eum_getapps Get EUM App Keys
describe eum_getapps << EOF
Get EUM Apps.
EOF
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
describe timerange_delete << EOF
Delete a specific time range by id
EOF
function timerange_create {
  local START_TIME=-1
  local END_TIME=-1
  local DURATION_IN_MINUTES=0
  local TYPE="BETWEEN_TIMES"
  while getopts "s:e:b:" opt "$@";
  do
    case "${opt}" in
      s)
        START_TIME=${OPTARG}
      ;;
      e)
        END_TIME=${OPTARG}
      ;;
      d)
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
describe timerange_create << EOF
Create a custom time range
EOF
function timerange_list {
  controller_call -X GET /controller/restui/user/getAllCustomTimeRanges
}
register timerange_list List all custom timeranges available on the controller
describe timerange_list << EOF
List all custom timeranges available on the controller
EOF
function environment_get {  
  COMMAND_RESULT=`cat "${HOME}/.appdynamics/act/config.$1.sh"`
}
register environment_get Retrieve an environment
describe environment_get << EOF
Retrieve an environment
EOF
function environment_delete {
  rm "${HOME}/.appdynamics/act/config.$1.sh"
  COMMAND_RESULT="${1} deleted"
}
register environment_delete Delete an environment
describe environment_delete << EOF
Delete an environment
EOF
function environment_add {
  local FORCE=0
  local GLOBAL=0
  local SHOW=0
  local PORTAL=0
  local DEFAULT=0
  while getopts "gfspd" opt "$@";
  do
    case "${opt}" in
      g)
        GLOBAL=1
      ;;
      f)
        FORCE=1
      ;;
      s)
        SHOW=1
      ;;
      p)
        PORTAL=1
      ;;
      d)
        DEFAULT=1
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  local ENVIRONMENT=""
  local CONTROLLER_HOST=""
  local CONTROLLER_CREDENTIALS=""
  local PORTAL_PASSWORD=""
  local PORTAL_USER=""
  local OUTPUT_DIRECTORY="${HOME}/.appdynamics/act"
  local USER_PLUGIN_DIRECTORY="${HOME}/.appdynamics/act/plugins"
  local CONTROLLER_COOKIE_LOCATION="${OUTPUT_DIRECTORY}/cookie.txt"
  if [ $GLOBAL -eq 1 ] ; then
    OUTPUT_DIRECTORY="/etc/appdynamics/act"
    CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-act-cookie.txt"
  fi
  if [ $SHOW -eq 1 ] ; then
    if [ -r $OUTPUT_DIRECTORY/config.sh ] ; then
      COMMAND_RESULT=$(<$OUTPUT_DIRECTORY/config.sh)
    else
      COMMAND_RESULT="act is not configured."
    fi
  else
    if [ $DEFAULT -eq 0 ] ; then
      echo -n "Environment name"
      if [ -n "${CONFIG_ENVIRONMENT}" ] ; then
        echo " [${CONFIG_ENVIRONMENT}]"
      else
        echo " []"
      fi
      read ENVIRONMENT
    fi
    if [ -z "$ENVIRONMENT" ] ; then
      ENVIRONMENT=$CONFIG_ENVIRONMENT
    fi
    echo -n "Controller Host location (e.g. https://appdynamics.example.com:8090)"
    if [ -n "${CONFIG_CONTROLLER_HOST}" ] ; then
      echo " [${CONFIG_CONTROLLER_HOST}]"
    else
      echo " []"
    fi
    read CONTROLLER_HOST
    if [ -z "$CONTROLLER_HOST" ] ; then
      CONTROLLER_HOST=$CONFIG_CONTROLLER_HOST
    fi
    echo -n "Controller Credentials (e.g. user@tenant:password)"
    if [ -n "${CONFIG_CONTROLLER_CREDENTIALS}" ] ; then
      echo " [${CONFIG_CONTROLLER_CREDENTIALS%%:*}:********]"
    else
      echo " []"
    fi
    read CONTROLLER_CREDENTIALS
    if [ -z "$CONTROLLER_CREDENTIALS" ] ; then
      CONTROLLER_CREDENTIALS=$CONFIG_CONTROLLER_CREDENTIALS
    fi
    if [ $PORTAL -eq 1 ] ; then
      echo -n "AppDynamics Portal Credentials (e.g. user@example.com:password)"
      if [ -n "${CONFIG_PORTAL_CREDENTIALS}" ] ; then
        echo " [${CONFIG_PORTAL_CREDENTIALS%%:*}:********]"
      else
        echo " []"
      fi
      read PORTAL_CREDENTIALS
    fi
    OUTPUT="CONFIG_CONTROLLER_HOST=${CONTROLLER_HOST}\nCONFIG_CONTROLLER_CREDENTIALS=${CONTROLLER_CREDENTIALS}\nCONFIG_CONTROLLER_COOKIE_LOCATION=${CONTROLLER_COOKIE_LOCATION}\nCONFIG_USER_PLUGIN_DIRECTORY=${USER_PLUGIN_DIRECTORY}\nCONFIG_PORTAL_CREDENTIALS=${PORTAL_CREDENTIALS}"
    OUTPUT_FILE="$OUTPUT_DIRECTORY/config.${ENVIRONMENT}.sh"
    if [ $DEFAULT -eq 1 ] ; then
      OUTPUT_FILE="$OUTPUT_DIRECTORY/config.sh"
    fi
    if [ ! -s "$OUTPUT_DIRECTORY/config.${ENVIRONMENT}.sh" ] || [ $FORCE -eq 1 ]
    then
      mkdir -p $OUTPUT_DIRECTORY
      echo -e "$OUTPUT" > "${OUTPUT_FILE}"
      COMMAND_RESULT="Created ${OUTPUT_FILE} successfully"
    else
      error "Configuration file ${OUTPUT_FILE} already exists. Please use (-f) to force override"
      COMMAND_RESULT=""
    fi
  fi
}
register environment_add Add a new environment.
describe environment_add << EOF
Add a new environment.
EOF
function environment_list {
  local BASE
  local TEMP
  COMMAND_RESULT="(default)"
  for file in "${HOME}/.appdynamics/act/config."*".sh"
  do
    BASE=`basename "${file}"`
    TEMP=${BASE#*.}
    COMMAND_RESULT="${COMMAND_RESULT} ${TEMP%.*}"
  done
}
register environment_list List all your environments
describe environment_list << EOF
List all your environments
EOF
function _config {
  environment_add -d "$@"
}
register _config Initialize the default environment. This is an alias for "${0} environment add -d"
describe _config << EOF
Initialize the default environment.
EOF
function _version {
  COMMAND_RESULT="$ACT_VERSION ~ $ACT_LAST_COMMIT"
}
register _version Print the current version of $SCRIPTNAME
describe _version << EOF
Print the current version of $SCRIPTNAME
EOF
function bt_get {
  apiCall '/controller/rest/applications/${a}/business-transactions/${b}' "$@"
}
register bt_get Get an BT by id
describe bt_get << EOF
Get an BT. Provide as parameters bt id (-b) and application id (-a).
EOF
function application_delete {
  apiCall -X POST -d "\${a}" "/controller/restui/allApplications/deleteApplication" "$@"
}
register application_delete Delete an application
describe application_delete << EOF
Delete an application. Provide application id as parameter.
EOF
function application_create {
  apiCall -X POST -d "{\"name\": \"\${n}\", \"description\": \"\"}" "/controller/restui/allApplications/createApplication?applicationType=\${t}" "$@"
}
register application_create Create a new application
describe application_create << EOF
Create a new application. Provide a name and a type (APM or WEB) as parameter.
EOF
function application_list {
  controller_call /controller/rest/applications
}
register application_list List all applications available on the controller
describe application_list << EOF
List all applications available on the controller. This command requires no further arguments.
EOF
function application_export {
  local APPLICATION_ID=$*
  if [[ $APPLICATION_ID =~ ^[0-9]+$ ]]; then
    controller_call /controller/ConfigObjectImportExportServlet?applicationId=$APPLICATION_ID
  else
    COMMAND_RESULT=""
    error "This is not a number: '$APPLICATION_ID'"
  fi
}
register application_export Export an application from the controller
describe application_export << EOF
Export a application from the controller. Specifiy the application id as parameter.
EOF
function node_markhistorical {
  apiCall -X POST '/controller/rest/mark-nodes-historical?application-component-node-ids=${n}' "$@"
}
register node_markhistorical Mark Nodes as Historical
describe node_markhistorical << EOF
Mark Nodes as Historical. Provide a comma separated list of node ids.
EOF
function node_get {
  apiCall -X GET "/controller/rest/applications/\${a}/nodes/\${n}" "$@"
}
register node_get Retrieve Node Information by Node Name
describe node_get << EOF
Retrieve Node Information by Node Name. Provide the application and the node as parameters
EOF
function node_list {
  apiCall -X GET "/controller/rest/applications/\${a}/nodes" "$@"
}
register node_list Retrieve Node Information for All Nodes in a Business Application
describe node_list << EOF
Retrieve Node Information for All Nodes in a Business Application. Provide the application as parameter.
EOF
function metric_get {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local START_TIME=-1
  local END_TIME=-1
  local DURATION_IN_MINUTES=0
  local TYPE="BEFORE_NOW"
  while getopts "a:s:e:d:t:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=${OPTARG}
      ;;
      s)
        START_TIME=${OPTARG}
      ;;
      e)
        END_TIME=${OPTARG}
      ;;
      d)
        DURATION_IN_MINUTES=${OPTARG}
      ;;
      t)
        TYPE=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  local METRIC_PATH=`urlencode "$*"`
  controller_call -X GET "/controller/rest/applications/${APPLICATION}/metric-data?metric-path=${METRIC_PATH}&time-range-type=${TYPE}&duration-in-mins=${DURATION_IN_MINUTES}&start-time=${START_TIME}&end-time=${END_TIME}"
}
register metric_get Get a specific metric
describe metric_get << EOF
Get a specific metric by providing the metric path. Provide the application with option -a
EOF
RECURSIVE_COMMAND_RESULT=""
function metric_tree {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local DEPTH=0
  declare -i DEPTH
  local METRIC_PATH
  local ROOT
  local TABS=""
  while getopts "a:d:t:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=${OPTARG}
      ;;
      d)
        DEPTH=${OPTARG}
      ;;
      t)
          TABS=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  METRIC_PATH="$*"
  metric_list -a $APPLICATION $METRIC_PATH
  debug $COMMAND_RESULT
  ROOT=$COMMAND_RESULT
  COMMAND_RESULT=""
  OLDIFS=$IFS
  IFS=$'\n,{'
  for I in $ROOT ; do
    case "$I" in
      *name*)
        name=${I##*:}
      ;;
      *type*)
        type=${I##*:}
      ;;
      *\}*)
        name=${name:2}
        RECURSIVE_COMMAND_RESULT="${RECURSIVE_COMMAND_RESULT}${TABS}${name%\"}\n"
        if [[ "$type" == *folder* ]] ; then
          local SUB_PATH="${METRIC_PATH}|${name%\"}"
          metric_tree -d ${DEPTH}+1 -t "${TABS} " -a $APPLICATION ${SUB_PATH#"|"}
        fi
      esac
    done;
    IFS=$OLDIFS
    if [ $DEPTH -eq 0 ] ; then
      echo -e $RECURSIVE_COMMAND_RESULT
    fi
}
register metric_tree Build and return a metrics tree for one application
describe metric_tree << EOF
Create a metric tree for the given application (-a). Note that this will create a lot of requests towards your controller.
EOF
function metric_list {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local METRIC_PATH=""
  while getopts "a:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  METRIC_PATH=`urlencode "$*"`
  debug "Will call /controller/rest/applications/${APPLICATION}/metrics?output=JSON\&metric-path=${METRIC_PATH}"
  controller_call /controller/rest/applications/${APPLICATION}/metrics?output=JSON\&metric-path=${METRIC_PATH}
}
register metric_list List metrics available for one application.
describe metric_list << EOF
List all metrics available for one application (-a). Provide a metric path like "Overall Application Performance" to walk the metrics tree.
EOF
function healthrule_import {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local FILE=""
  while getopts "a:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  FILE="$*"
  if [ -r $FILE ] ; then
    controller_call -X POST -F file="@$FILE" "/controller/healthrules/${APPLICATION}"
  else
    COMMAND_RESULT=""
    error "File not found or not readable: $FILE"
  fi
}
register healthrule_import Import a health rule
describe healthrule_import << EOF
Import a health rule.
EOF
function healthrule_list {
  apiCall -X GET '/controller/healthrules/${a}/' "$@"
}
register healthrule_list List all healthrules
describe healthrule_list << EOF
List all health rules. Provide parameter a for the application and parameter.
EOF
function healthrule_export {
  apiCall -X GET '/controller/healthrules/${a}/?name=${n?}' "$@"
}
register healthrule_export Export a health rule
describe healthrule_export << EOF
Export a health rule. Provide parameter a for the application and parameter n for the name of the health rule. If you want to export all healthrules use the "list" command
EOF
function healthrule_copy {
  local SOURCE_APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local TARGET_APPLICATION=""
  local HEALTH_RULE_NAME=""
  while getopts "s:t:n:" opt "$@";
  do
    case "${opt}" in
      s)
        SOURCE_APPLICATION="${OPTARG}"
      ;;
      t)
        TARGET_APPLICATION="${OPTARG}"
      ;;
      n)
        HEALTH_RULE_NAME="${OPTARG}"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  healthrule_list -a ${SOURCE_APPLICATION}
  if [ "${COMMAND_RESULT:1:12}" == "health-rules" ]
  then
    local R=${RANDOM}
    echo "$COMMAND_RESULT" > "/tmp/act-output-${R}"
    healthrule_import -a ${TARGET_APPLICATION} "/tmp/act-output-${R}"
    rm "/tmp/act-output-${R}"
  else
    COMMAND_RESULT="Could not export health rules from source application: ${COMMAND_RESULT}"
  fi
}
register healthrule_copy Copy healthrules from one application to another.
describe healthrule_list << EOF
Copy healthrules from one application to another. Provide the source application id ("-s") and the target application ("-t").
If you provide ("-n") only the named health rule will be copied.
EOF
function event_create {
  apiCall -X POST "/controller/rest/applications/\${a}/events?summary=\${s}&comment=\${c?}&eventtype=\${e}&severity=\${l}&bt=&\${b?}node=\${n?}&tier=\${t?}" "$@"
}
register event_create Create a custom event for a given application
describe event_create << EOF
Create a custom event for a given application. Application, summary, event type and severity are required parameters.
EOF
function event_list {
  apiCall '/controller/rest/applications/${a}/events?time-range-type=${t}&duration-in-mins=${d?}&start-time=${b?}&end-time=${f?}&event-types=${e}&severities=${s}' "$@"
}
register event_list List all events for a given time range.
describe event_list << EOF
List all events for a given time range.
EOF
function analyticssearch_get {
  apiCall '/controller/restui/analyticsSavedSearches/getAnalyticsSavedSearchById/${i}' "$@"
}
register analyticssearch_get Get an analytics search by id.
describe analyticssearch_get << EOF
Get an analytics search by id. Provide the id as parameter (-i)
EOF
function analyticssearch_list {
  apiCall '/controller/restui/analyticsSavedSearches/getAllAnalyticsSavedSearches' "$@"
}
register analyticssearch_list List all analytics searches on the controller.
describe analyticssearch_list << EOF
List all analytics searches available on the controller. This command requires no further arguments.
EOF
function tier_nodes {
  apiCall -X GET "/controller/rest/applications/\${a}/tiers/\${t}/nodes" "$@"
}
register tier_nodes" Retrieve Node Information for All Nodes in a Tier"
describe tier_nodes << EOF
Retrieve Node Information for All Nodes in a Tier. Provide the application and the tier as parameters
EOF
function tier_get {
  apiCall -X GET "/controller/rest/applications/\${a}/tiers/\${t}" "$@"
}
register tier_get Retrieve Tier Information by Tier Name
describe tier_get << EOF
Retrieve Tier Information by Tier Name. Provide the application and the tier as parameters
EOF
function tier_list {
  apiCall -X GET "/controller/rest/applications/\${a}/tiers" "$@"
}
register tier_list List all tiers for a given application
describe tier_list << EOF
List all tiers for a given application. Provide the application id as parameter.
EOF
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
function apiCall {
  local OPTS
  local OPTIONAL_OPTIONS=""
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
  ENDPOINT=$1
  debug "Unparsed endpoint is $ENDPOINT"
  debug "Unparsed payload is $PAYLOAD"
  shift
  OLDIFS=$IFS
  IFS="\$"
  for MATCH in $PAYLOAD ; do
    if [[ $MATCH =~ \{([a-zA-Z])(\??)\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      if [ "${BASH_REMATCH[2]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;
  for MATCH in $ENDPOINT ; do
    if [[ $MATCH =~ \{([a-zA-Z])(\??)\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      if [ "${BASH_REMATCH[2]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;
  IFS=$OLDIFS
  debug "Identified Options: ${OPTS}"
  debug "Optional Options: $OPTIONAL_OPTIONS"
  if [ -n "$OPTS" ] ; then
    while getopts ${OPTS} opt;
    do
      local ARG=`urlencode "$OPTARG"`
      debug "Applying $opt with $ARG"
      # PAYLOAD=${PAYLOAD//\$\{${opt}\}/$OPTARG}
      # ENDPOINT=${ENDPOINT//\$\{${opt}\}/$OPTARG}
      while [[ $PAYLOAD =~ \$\{$opt\??\} ]] ; do
        PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$OPTARG}
      done;
      while [[ $ENDPOINT =~ \$\{$opt\??\} ]] ; do
        ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$ARG}
      done;
    done
    shiftOptInd
    shift $SHIFTS
  fi
  while [[ $PAYLOAD =~ \$\{([a-zA-Z])(\??)\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      if [ "${MISSING}" == "a" ] && [ -n "${CONFIG_CONTROLLER_DEFAULT_APPLICATION}" ] ; then
        ENDPOINT=${ENDPOINT//'${a}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
      else
        error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
        return;
      fi
    fi
    PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$1}
    shift
  done
  while [[ $ENDPOINT =~ \$\{([a-zA-Z])(\??)\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      if [ "${MISSING}" == "a" ] && [ -n "${CONFIG_CONTROLLER_DEFAULT_APPLICATION}" ] ; then
        ENDPOINT=${ENDPOINT//'${a}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
      else
        error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
        return;
      fi
    fi
    local ARG=`urlencode "$1"`
    debug "Applying ${BASH_REMATCH[0]} with $ARG"
    ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$ARG}
    shift
  done
  debug "Call Controller: -X $METHOD -d $PAYLOAD $ENDPOINT"
  if [ -n "$PAYLOAD" ] ; then
    if [ "${PAYLOAD:0:1}" = "@" ] ; then
      debug "Loading payload from file ${PAYLOAD:1}"
      PAYLOAD=$(<${PAYLOAD:1})
    fi
    controller_call -X $METHOD -d "$PAYLOAD" "$ENDPOINT"
  else
    controller_call -X $METHOD $ENDPOINT
  fi
}
SHIFTS=0
declare -i SHIFTS
function shiftOptInd {
  SHIFTS=$OPTIND
  SHIFTS=${SHIFTS}-1
  OPTIND=0
  return $SHIFTS
}
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
function httpClient {
 # debug "$*"
 local TIMEOUT=10
 if [ -n "$CONFIG_HTTP_TIMEOUT" ] ; then
   TIMEOUT=$CONFIG_HTTP_TIMEOUT
 fi
 curl -L --connect-timeout $TIMEOUT "$@"
}
#script_placeholder
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
while getopts "A:H:C:E:J:D:P:S:F:Nv" opt;
do
  case "${opt}" in
    E)
      CONFIG_ENVIRONMENT="${OPTARG}"
      debug "Set CONFIG_ENVIRONMENT=${CONFIG_ENVIRONMENT}"
      ENVIRONMENT_CONFIG="${HOME}/.appdynamics/act/config.${CONFIG_ENVIRONMENT}.sh"
      if [ -f "${ENVIRONMENT_CONFIG}" ]; then
        debug "Sourcing user config from ${ENVIRONMENT_CONFIG} "
        . ${ENVIRONMENT_CONFIG}
      else
        warning "File ${ENVIRONMENT_CONFIG} not found!"
      fi
    ;;
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
      CONFIG_CONTROLLER_DEFAULT_APPLICATION=${OPTARG}
      debug "Set CONFIG_CONTROLLER_DEFAULT_APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}"
    ;;
    P)
      CONFIG_USER_PLUGIN_DIRECTORY=${OPTARG}
      debug "Set CONFIG_USER_PLUGIN_DIRECTORY=${CONFIG_USER_PLUGIN_DIRECTORY}"
    ;;
    S)
      CONFIG_PORTAL_CREDENTIALS=${OPTARG}
      debug "Set CONFIG_PORTAL_CREDENTIALS=${CONFIG_PORTAL_CREDENTIALS}"
    ;;
    N)
      COLOR_WARNING=""
      COLOR_INFO=""
      COLOR_ERROR=""
      COLOR_DEBUG=""
      COLOR_RESET=""
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
    v)
      case $VERBOSITY_COUNTER in
        0)
        CONFIG_OUTPUT_VERBOSITY="${CONFIG_OUTPUT_VERBOSITY},warn"
        ;;
        1)
        CONFIG_OUTPUT_VERBOSITY="${CONFIG_OUTPUT_VERBOSITY},info"
        ;;
        2)
        CONFIG_OUTPUT_VERBOSITY="${CONFIG_OUTPUT_VERBOSITY},debug"
        ;;
      esac
      VERBOSITY_COUNTER=${VERBOSITY_COUNTER}+1
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
  debug "${NAMESPACE} has commands"
  COMMAND=$2
  if [ "$COMMAND" == "" ] || [ "$COMMAND" == "help" ]; then
    debug "Will display help for $NAMESPACE"
    _help ${NAMESPACE}
  elif [ "${GLOBAL_COMMANDS/${NAMESPACE}_${COMMAND}}" != "$GLOBAL_COMMANDS" ] ; then
    debug "${NAMESPACE}_${COMMAND} is a valid command"
    shift 2
    ${NAMESPACE}_${COMMAND} "$@"
  else
    COMMAND_RESULT="Unknown command: $*"
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
