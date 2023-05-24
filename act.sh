#!/bin/bash
ACT_VERSION="v22.11.0"
ACT_LAST_COMMIT="739b80a0fcafeb3692d154d578257146850db9f7"
USER_CONFIG="$HOME/.appdynamics/act/config.sh"
GLOBAL_CONFIG="/etc/appdynamics/act/config.sh"
CONFIG_CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-controller-cookie.txt"
# Configure default output verbosity. May contain a combination of the following strings:
# - debug
# - error
# - warn
# - info
# - output (msg to stdout)
# An empty string silents all output
CONFIG_OUTPUT_VERBOSITY="error,output"
CONFIG_OUTPUT_COMMAND=0
CONFIG_OUTPUT_FORMAT="XML"
# Default Colors
COLOR_WARNING="\033[0;33m"
COLOR_INFO="\033[0;32m"
COLOR_ERROR="\033[0;31m"
COLOR_DEBUG="\033[0;35m"
COLOR_RESET="\033[0m"
EOL="
"
TAB="  "
GLOBAL_COMMANDS=""
GLOBAL_HELP=""
declare -i GLOBAL_COMMANDS_COUNTER=0
declare -a GLOBAL_LONG_HELP_STRINGS
declare -a GLOBAL_LONG_HELP_COMMANDS
declare -a GLOBAL_EXAMPLE_COMMANDS
declare -a GLOBAL_EXAMPLE_STRINGS
declare -a GLOBAL_DOC_NAMESPACES
declare -a GLOBAL_DOC_STRINGS
SCRIPTNAME=$(basename "$0")
VERBOSITY_COUNTER=0
declare -i VERBOSITY_COUNTER
# register namespace_command help
register() {
  GLOBAL_COMMANDS_COUNTER+=1
  GLOBAL_COMMANDS="${GLOBAL_COMMANDS} $1"
  GLOBAL_HELP="${GLOBAL_HELP}${EOL}$*"
}
describe() {
  GLOBAL_LONG_HELP_COMMANDS[${#GLOBAL_LONG_HELP_COMMANDS[@]}]="$1"
  read -r -d '' GLOBAL_LONG_HELP_STRINGS[${#GLOBAL_LONG_HELP_STRINGS[@]}]
}
example() {
  GLOBAL_EXAMPLE_COMMANDS[${#GLOBAL_EXAMPLE_COMMANDS[@]}]="$1"
  read -r -d '' GLOBAL_EXAMPLE_STRINGS[${#GLOBAL_EXAMPLE_STRINGS[@]}]
}
doc() {
  GLOBAL_DOC_NAMESPACES[${#GLOBAL_DOC_STRINGS[@]}]="$1"
  read -r -d '' GLOBAL_DOC_STRINGS[${#GLOBAL_DOC_STRINGS[@]}]
}
rde() {
  register "${1}" "${2}"
  describe "${1}" <<RRREOF
${2} ${3}
RRREOF
  example "${1}" <<RRREOF
${4}
RRREOF
}
doc account << EOF
Query the Account API
EOF
account_my() { apiCall '/controller/api/accounts/myaccount' "$@" ; }
rde account_my "Get details about the current account" "This command requires no further arguments." ""
doc action << EOF
Import or export all actions in the specified application to a JSON file.
EOF
action_create() { apiCall -X POST -d '{{d:actions}}' '/controller/restui/httpaction/createHttpRequestAction' "$@" ; }
rde action_create "" "Provide a json string or a file (with @ as prefix) as parameter (-d)" "-d @actions.json"
action_delete() { apiCall -X POST -d '[{{i:action_id}}]' '/controller/restui/policy/deleteActions' "$@" ; }
rde action_delete "" "Provide an action id (-i) as parameter." ""
action_export() { apiCall '/controller/actions/{{a:application}}' "$@" ; }
rde action_export "Export actions." "Provide an application id or name as parameter (-a)." "-a 15"
action_import() { apiCall -X POST -F 'file={{d:actions}}' '/controller/actions/{{a:application}}' "$@" ; }
rde action_import "Import actions." "Provide an application id or name as parameter (-a) and a json string or a file (with @ as prefix) as parameter (-d)" "-a 15 -d @actions.json"
action_list() { apiCall '/controller/restui/policy/getActionsListViewData/{{a:application}}' "$@" ; }
rde action_list "List actions." "Provide an application id or name as parameter (-a)." "-a 15"
doc actiontemplate << EOF
These commands allow you to import and export email/http action templates. A common use pattern is exporting the commands from one controller and importing into another. Please note that the export is a list of templates and the import expects a single object, so you need to split the json inbetween.
EOF
actiontemplate_createmediatype() { apiCall -X POST -d '{"name":"{{n:media_type_name}}","builtIn":false}' '/controller/restui/httpaction/createHttpRequestActionMediaType' "$@" ; }
rde actiontemplate_createmediatype "Create a custom media type." "Provide the name of the media type as parameter (-n)" "-n 'application/vnd.appd.events+json'"
actiontemplate_export() { apiCall '/controller/actiontemplate/{{t:action_template_type}}/' "$@" ; }
rde actiontemplate_export "Export all templates of a given type." "Provide the type (-t email or httprequest) as parameter." "-t httprequest"
actiontemplate_exportHttpActionPlanList() { apiCall '/controller/restui/httpaction/getHttpRequestActionPlanList' "$@" ; }
rde actiontemplate_exportHttpActionPlanList "Export the Http Action Plan List" "This command requires no further arguments." ""
doc adql << EOF
These commands allow you to run ADQL queries agains the controller (not the event service!)
EOF
adql_query() { apiCall -X POST -d '{"requests":[{"query":"{{q:query}}","label":"DataQuery","customResponseRequest":true,"responseConverter":"UIGRID","responseType":"ORDERED","start":"{{s:start}}","end":"{{e:end}}","chunk":false,"mode":"page","scrollId":"","size":"50000","offset":"0","limit":"1000000"}],"start":"","end":"","chunk":false,"mode":"none","scrollId":"","size":"","offset":"","limit":"1000000","chunkDelayMillis":"","chunkBreakDelayMillis":"","chunkBreakBytes":"","others":"false","emptyOnError":"false","token":"","dashboardId":0,"warRoomToken":"","warRoom":false}' '/controller/restui/analytics/adql/query' "$@" ; }
rde adql_query "Run an ADQL query" "Provide an adql query (-q), a start time (-s) and an end time (-e) as parameters. Remember to escape double quotes in the query." "-q 'SELECT eventTimestamp FROM transactions LIMIT 1' -s 2022-06-05T00:00:00.000Z -e 2022-06-16T06:00:00.000Z"
doc agents << EOF
List, Reset, Disable AppDynamics Agents
EOF
agents_disable() { apiCall -X POST '/controller/restui/agent/setting/disableAppServerAgentForNode/{{i:id}}?disableMonitoring={{m:disableMonitoring}}' "$@" ; }
rde agents_disable "Disable an app agent by id" "Provide an agent id (-i) and the disableMonitoring (-m) flag (true/false) as parameter." "-i 15 -m true"
agents_enable() { apiCall -X POST '/controller/restui/agent/setting/enableAppServerAgentForNode/{{i:id}}' "$@" ; }
rde agents_enable "Enable an app agent by id" "Provide an agent id (-i) as parameter." "-i 15"
agents_ids() { apiCall -X POST -d '{"requestFilter":[{{i:ids}}],"resultColumns":["HOST_NAME","AGENT_VERSION","NODE_NAME","COMPONENT_NAME","APPLICATION_NAME","DISABLED","ALL_MONITORING_DISABLED"],"offset":0,"limit":-1,"searchFilters":[],"columnSorts":[{"column":"HOST_NAME","direction":"ASC"}]}' '/controller/restui/agents/list/{{t:type}}/ids' "$@" ; }
rde agents_ids "Get more details on agents of a specific type by providing their ids" "Provide a type as parameter (-t) and a comma separated list of ids (-i). Possible types are appserver, machine, cluster." "-t appserver -i 1,2,3"
agents_list() { apiCall -X POST -d '{"requestFilter":{"queryParams":{"applicationAssociationType":"ALL"},"filters":[]},"resultColumns":[],"offset":0,"limit":-1,"searchFilters":[],"columnSorts":[{"column":"HOST_NAME","direction":"ASC"}]}' '/controller/restui/agents/list/{{t:type}}' "$@" ; }
rde agents_list "List all agents of a specific type" "Provide a type as parameter (-t). Possible types are appserver, machine, cluster." ""
agents_toggleMachineAgent() { apiCall -X POST -d '[{{i:id}}]' '/controller/restui/agent/setting/toggleMachineAgentEnable?enabledFlag={{m:enabledFlag}}&entityType=MACHINE_INSTANCE' "$@" ; }
rde agents_toggleMachineAgent "Enable or Disable an machine agent by id" "Provide an agent id (-i) and the enabled (-m) flag (true/false) as parameter." "-i 15 -m false"
doc alertingtemplate << EOF
These commands allow you to list, import and export action templates.
EOF
alertingtemplate_delete() { apiCall -X DELETE '/controller/alerting/rest/v1/templates/{{a:alerting_template_id}}' "$@" ; }
rde alertingtemplate_delete "Delete an alerting template" "Provide the id of the alerting template (-a) as parameter." "-i 68"
alertingtemplate_export() { apiCall -X POST '/controller/alerting/rest/v1/templates/{{a:alerting_template_id}}/export' "$@" ; }
rde alertingtemplate_export "Export an alerting template" "Provide the id of the alerting template (-a) as parameter." "-i 68"
alertingtemplate_import() { apiCall -X POST -d '{{d:alerting_template}}' '/controller/alerting/rest/v1/templates/import' "$@" ; }
rde alertingtemplate_import "Import an alerting template" "Provide a json string or a file (with @ as prefix) as parameter (-d)." "-d examples/alertingTemplate.json"
alertingtemplate_list() { apiCall '/controller/alerting/rest/v1/templates/details' "$@" ; }
rde alertingtemplate_list "List all alerting templates" "This command requires no further arguments." ""
doc analyticsmetric << EOF
Manage custom analytics metrics
EOF
analyticsmetric_create() { apiCall -X POST -d '{"adqlQueryString":"{{q:query}}","eventType":"{{e:eventType}}","enabled":true,"queryType":"ADQL_QUERY","queryName":"{{n:queryname}}","queryDescription":"{{d:querydescription?}}"}' '/controller/restui/analyticsMetric/create' "$@" ; }
rde analyticsmetric_create "Create analytics metric" "Provide an adql query (-q) and an event type (-e BROWSER_RECORD, BIZ_TXN) and a name (-n) as parameters. The description (-d) is optional." "-q 'SELECT count(*) FROM browser_records' -e BROWSER_RECORD -n 'My Custom Metric'"
analyticsmetric_list() { apiCall '/controller/restui/analyticsMetric/getAnalyticsScheduledQueryReports' "$@" ; }
rde analyticsmetric_list "List all analytics metrics" "" ""
doc analyticsschema << EOF
These commands allow you to manage analytics schemas.
EOF
analyticsschema_list() { apiCall '/controller/restui/analytics/schema' "$@" ; }
rde analyticsschema_list "List all analytics schemas." "This command requires no further arguments" ""
doc analyticssearch << EOF
These commands allow you to import and export email/http saved analytics searches.
EOF
analyticssearch_delete() { apiCall -X POST '/controller/restui/analyticsSavedSearches/deleteAnalyticsSavedSearch/{{i:analytics_search_id}}' "$@" ; }
rde analyticssearch_delete "Delete an analytics search by id." "Provide the id as parameter (-i)." "-i 6"
analyticssearch_get() { apiCall '/controller/restui/analyticsSavedSearches/getAnalyticsSavedSearchById/{{i:analytics_search_id}}' "$@" ; }
rde analyticssearch_get "Get an analytics search by id." "Provide the id as parameter (-i)." "-i 6"
analyticssearch_import() { apiCall -X POST -d '{{d:analytics_search}}' '/controller/restui/analyticsSavedSearches/createAnalyticsSavedSearch' "$@" ; }
rde analyticssearch_import "Import an analytics search." "Provide a json string or a file (with @ as prefix) as parameter (-d)." "-d search.json"
analyticssearch_list() { apiCall '/controller/restui/analyticsSavedSearches/getAllAnalyticsSavedSearches' "$@" ; }
rde analyticssearch_list "List all analytics searches." "This command requires no further arguments." ""
doc application << EOF
The applications API lets you retrieve information about the monitored environment as modeled in AppDynamics.
EOF
application_create() { apiCall -X POST -d '{"name": "{{n:application_name}}", "description": "{{d:application_description?}}"}' '/controller/restui/allApplications/createApplication?applicationType={{t:application_type}}' "$@" ; }
rde application_create "Create a new application." "Provide a name and a type (APM or WEB) as parameter." "-t APM -n MyNewApplication"
application_delete() { apiCall -X POST -d '{{a:application}}' '/controller/restui/allApplications/deleteApplication' "$@" ; }
rde application_delete "Delete an application." "Provide an application id as parameter (-a)" "-a 29"
application_export() { apiCall '/controller/ConfigObjectImportExportServlet?applicationId={{a:application}}' "$@" ; }
rde application_export "Export an application." "Provide an application id as parameter (-a)" "-a 29"
application_get() { apiCall '/controller/rest/applications/{{a:application}}' "$@" ; }
rde application_get "Get an application." "Provide an application id or name as parameter (-a)." "-a 15"
application_list() { apiCall '/controller/rest/applications' "$@" ; }
rde application_list "List all applications." "This command requires no further arguments." ""
application_listdetails() { apiCall -X POST -d '{"requestFilter":[{{i:ids}}],"timeRangeStart":{{s:start}},"timeRangeEnd":{{e:end}},"searchFilters":null,"columnSorts":null,"resultColumns":["APP_OVERALL_HEALTH","CALLS","CALLS_PER_MINUTE","AVERAGE_RESPONSE_TIME","ERROR_PERCENT","ERRORS","ERRORS_PER_MINUTE","NODE_HEALTH","BT_HEALTH"],"offset":0,"limit":-1} ' '/controller/restui/v1/app/list/ids' "$@" ; }
rde application_listdetails "List application details" "List application details including health. Provide application ids as parameter (-i), a start and end timestamp (-s and -e)." "-i 9326,8914 -s 1610389435 -e 1620389435"
doc audit << EOF
The Controller audit history is a record of the configuration and user activities in the Controller configuration.
EOF
audit_get() { apiCall '/controller/ControllerAuditHistory?startTime={{b:start_time}}&endTime={{f:end_time}}' "$@" ; }
rde audit_get "Get audit history." "Provide a start time (-b) and an end time (-f) as parameter." "-b 2015-12-19T10:50:03.607-700 -f 2015-12-19T17:50:03.607-0700"
doc backend << EOF
Retrieve information about backends within a given business application
EOF
backend_list() { apiCall '/controller/rest/applications/{{a:application}}/backends' "$@" ; }
rde backend_list "List all backends." "Provide the application id as parameter (-a)" "-a 29"
doc bizjourney << EOF
Manage business journeys in AppDynamics Analytics
EOF
bizjourney_disable() { apiCall -X PUT '/controller/restui/analytics/biz_outcome/definitions/{{i:business_journey_id}}/actions/userDisable' "$@" ; }
rde bizjourney_disable "Disable a business journey." "Provide the journey id (-i) as parameter." "-i 6"
bizjourney_enable() { apiCall -X PUT '/controller/restui/analytics/biz_outcome/definitions/{{i:business_journey_id}}/actions/enable' "$@" ; }
rde bizjourney_enable "Enable a business journey." "Provide the journey id (-i) as parameter." "-i 6"
bizjourney_import() { apiCall -X POST -d '{{d:business_journey_draft}}' '/controller/restui/analytics/biz_outcome/definitions/saveAsValidDraft' "$@" ; }
rde bizjourney_import "Import a business journey." "Provide a json string or a file (with @ as prefix) as parameter (-d)" "-d @journey.json"
bizjourney_list() { apiCall '/controller/restui/analytics/biz_outcome/definitions/summary' "$@" ; }
rde bizjourney_list "List all business journeys." "This command requires no further arguments." ""
doc bt << EOF
Retrieve information about business transactions within a given business application
EOF
bt_creategroup() { apiCall -X POST -d '[{{b:business_transactions}}]' '/controller/restui/bt/createBusinessTransactionGroup?applicationId={{a:application}}&groupName={{n:business_transaction_group_name}}' "$@" ; }
rde bt_creategroup "Create a BT group." "Provide the application id (-a), name (-n) and a comma separeted list of bt ids (-b)" "-b 13,14 -n MyGroup"
bt_delete() { apiCall -X POST -d '[{{b:business_transactions}}]' '/controller/restui/bt/deleteBTs' "$@" ; }
rde bt_delete "Delete a BT." "Provide the bt id as parameter (-b)" "-b 13"
bt_get() { apiCall '/controller/rest/applications/{{a:application}}/business-transactions/{{b:business_transaction}}' "$@" ; }
rde bt_get "Get a BT." "Provide as parameters bt id (-b) and application id (-a)." "-a 29 -b 13"
bt_list() { apiCall '/controller/rest/applications/{{a:application}}/business-transactions' "$@" ; }
rde bt_list "List all BTs." "Provide the application id as parameter (-a)" "-a 29"
bt_overflowtraffic() { apiCall -X POST -d '{"componentId":{{c:component_id}},"timeRangeSpecifier":{"type":"BEFORE_NOW","durationInMinutes":{{d:duration_in_minutes}}},"endEventId":0,"currentFetchedEventCount":0}' '/controller/restui/overflowtraffic/event' "$@" ; }
rde bt_overflowtraffic "Get the overflow traffic for a given component." "Provide a component id (-c) and a duration in minutes for a time range (-d) as parameters." ""
bt_rename() { apiCall -X POST -d '{{n:business_transaction_name}}' '/controller/restui/v1/bt/renameBT?id={{b:business_transaction}}' "$@" ; }
rde bt_rename "Rename a BT." "Provide the bt id (-b) and the new name (-n) as parameters" "-b 13 -n Checkout"
doc configuration << EOF
The configuration API enables you read and modify selected Controller configuration settings programmatically.
EOF
configuration_get() { apiCall '/controller/rest/configuration?name={{n:controller_setting_name}}' "$@" ; }
rde configuration_get "Get a controller setting by name." "Provide a name (-n) as parameter." "-n metrics.min.retention.period"
configuration_list() { apiCall '/controller/rest/configuration' "$@" ; }
rde configuration_list "List all controller settings" "The Controller global configuration values are made up of the Controller settings that are presented in the Administration Console." ""
configuration_set() { apiCall -X POST '/controller/rest/configuration?name={{n:controller_setting_name}}&value={{v:controller_setting_value}}' "$@" ; }
rde configuration_set "Set a controller setting." "Set a Controller setting to a specified value. Provide a name (-n) and a value (-v) as parameters" "-n metrics.min.retention.period -v 550"
doc controller << EOF
Basic calls against an AppDynamics controller.
EOF
controller_auth() { apiCall '/controller/auth?action=login' "$@" ; }
rde controller_auth "Authenticate." "" ""
controller_status() { apiCall '/controller/rest/serverstatus' "$@" ; }
rde controller_status "Get the server status." "This command will return a XML containing status information about the controller." ""
doc dashboard << EOF
Import and export custom dashboards in the AppDynamics controller
EOF
dashboard_delete() { apiCall -X POST -d '[{{i:dashboard_id}}]' '/controller/restui/dashboards/deleteDashboards' "$@" ; }
rde dashboard_delete "Delete a dashboard." "Provide a dashboard id (-i) as parameter" "-i 2"
dashboard_export() { apiCall '/controller/CustomDashboardImportExportServlet?dashboardId={{i:dashboard_id}}' "$@" ; }
rde dashboard_export "Export a dashboard." "Provide a dashboard id (-i) as parameter" "-i 2"
dashboard_get() { apiCall '/controller/restui/dashboards/dashboardIfUpdated/{{i:dashboard_id}}/-1' "$@" ; }
rde dashboard_get "Get a dashboard." "Provide a dashboard id (-i) as parameter." "-i 2"
dashboard_import() { apiCallExpand -X POST -F 'file={{d:dashboard}}' '/controller/CustomDashboardImportExportServlet' "$@" ; }
rde dashboard_import "Import a dashboard." "Provide a dashboard file or json (-d) as parameter." "-d @examples/dashboard.json"
dashboard_list() { apiCall '/controller/restui/dashboards/getAllDashboardsByType/false' "$@" ; }
rde dashboard_list "List all dashboards." "This command requires no further arguments." ""
dashboard_update() { apiCall -X POST -d '{{d:dashboard_definition}}' '/controller/restui/dashboards/updateDashboard' "$@" ; }
rde dashboard_update "Update a dashboard." "Provide a dashboard file or json (-d) as parameter. Use the dashboard get command to retrieve the correct format for updating." "-d @dashboardUpdate.json"
doc dbmon << EOF
Use the Database Visibility API to get, create, update, and delete Database Visibility Collectors.
EOF
dbmon_delete() { apiCall -X POST -d '[{{c:database_collectors}}]' '/controller/rest/databases/collectors/batchDelete' "$@" ; }
rde dbmon_delete "Delete multiple collectors." "Provide a comma seperated list of collector analyticsSavedSearches" "-c 17,18"
dbmon_get() { apiCall '/controller/rest/databases/collectors/{{c:database_collector}}' "$@" ; }
rde dbmon_get "Get a specifc collector." "Provide the collector id as parameter (-c)." "-c 17"
dbmon_import() { apiCall -X POST -d '{{d:database_collector_definition}}' '/controller/rest/databases/collectors/create' "$@" ; }
rde dbmon_import "Import a collector." "Provide a json string or a @file (-d) as parameter." "-d @collector.json"
dbmon_list() { apiCall '/controller/rest/databases/collectors' "$@" ; }
rde dbmon_list "List all collectors." "No further arguments required." ""
dbmon_queries() { apiCall -X POST -d '{"cluster":false,"serverId":{{i:server_id}},"field":"query-id","size":100,"filterBy":"time","startTime":{{b:start_time}},"endTime":{{f:end_time}},"waitStateIds":[],"useTimeBasedCorrelation":false}' '/controller/databasesui/databases/queryListData' "$@" ; }
rde dbmon_queries "Get queries for a server." "Requires a server id (-i), a start time (-b) and an end time (-f) as parameters." "-i 2 -b 1545237000000 -f 1545238602"
dbmon_servers() { apiCall '/controller/rest/databases/servers' "$@" ; }
rde dbmon_servers "List all servers." "No further arguments required." ""
dbmon_update() { apiCall -X POST -d '{{d:database_collector_update_definition}}' '/controller/rest/databases/collectors/update' "$@" ; }
rde dbmon_update "Update a specific collector." "Provide a json string or a @file (-d) as parameter." "-d @collector.json"
doc eumCorrelation << EOF
Manage correlation cookies for APM and EUM integration
EOF
eumCorrelation_disable() { apiCall -X POST -d '{"isEnabled":false,"includeRules":[],"excludeRules":[],"btHeaderInjectionForSafeAgentsEnabled":false}' '/controller/restui/configuration/userExperienceAppIntegration/businessTransactionEumCorrelation/saveConfiguration/{{a:application}}' "$@" ; }
rde eumCorrelation_disable "Disable all EUM correlation cookies." "" "-a 41"
doc event << EOF
Create and list events in your business applications.
EOF
event_create() { apiCall -X POST '/controller/rest/applications/{{a:application}}/events?summary={{s:event_summary}}&comment={{c:event_comment?}}&eventtype={{e:event_type}}&severity={{l:event_severity}}&bt={{b:business_transaction?}}&node={{n:node?}}&tier={{t:tier?}}' "$@" ; }
rde event_create "Create an event." "Provide an application (-a), a summary (-s), an event type (-e) and a severity level (-l). Optional parameters are bt (-b), node (-n) and tier (-t)" "-l INFO -c 'New bug fix release.' -e APPLICATION_DEPLOYMENT -a 29 -s 'Version 3.1.3'"
doc federation << EOF
Establish a federation between two AppDynamics Controllers.
EOF
federation_createkey() { apiCall -X POST -d '{"apiKeyName": "{{n:federation_api_key_name}}"}' '/controller/rest/federation/apikeyforfederation' "$@" ; }
rde federation_createkey "Create a key." "Provide a name for the api key (-n) as parameter." "-n saas2onprem"
federation_establish() { apiCall -X POST -d '{"accountName": "{{controller_account}}","controllerUrl": "{{controller_url}}","friendAccountName": "{{a:federation_friend_account}}", "friendAccountApiKey": "{{k:federation_friend_api_key}}", "friendAccountControllerUrl": "{{c:federation_friend_controller_url}}"}' '/controller/rest/federation/establishmutualfriendship' "$@" ; }
rde federation_establish "Establish a federation" "Provide an account name (-a), an api key (-k) and a controller url (-c) for the friend account." "-a customer1 -k NGEzNzlhNTctNzQ1Yy00ZWM3LTkzNmItYTVkYmY0NWVkYzZjOjA0Nzk0ZjI5NzU1OWM0Zjk4YzYxN2E0Y2I2ODkwMDMyZjdjMDhhZTY= -c http://localhost:8090"
doc flowmap << EOF
Retrieve flowmaps
EOF
flowmap_application() { apiCall '/controller/restui/applicationFlowMapUiService/application/{{a:application}}?time-range={{t:timerange}}&mapId=-1&baselineId=-1&forceFetch=false' "$@" ; }
rde flowmap_application "Get an application flowmap" "Provide an application (-a) and a time range string (-t) as parameter." "-a 41 -t last_1_hour.BEFORE_NOW.-1.-1.60"
flowmap_component() { apiCall '/controller/restui/componentFlowMapUiService/component/{{c:component}}?time-range={{t:timerange}}&mapId=-1&baselineId=-1' "$@" ; }
rde flowmap_component "Get an component flowmap" "Provide an component (tier, node, ...) id (-c) and a time range string (-t) as parameter" "-c 108 -t last_1_hour.BEFOREW_NOW.-1.-1.60"
doc healthrule << EOF
Configure and retrieve health rules and their violates.
EOF
healthrule_disable() { apiCall -X PUT -d '{"enabled": "false"}' '/controller/alerting/rest/v1/applications/{{a:application}}/health-rules/{{i:healthrule_id}}/configuration' "$@" ; }
rde healthrule_disable "Disable a healthrule." "Provide an application (-a) and a health rule id (-i) as parameters." "-a 29 -i 54"
healthrule_enable() { apiCall -X PUT -d '{"enabled": "true"}' '/controller/alerting/rest/v1/applications/{{a:application}}/health-rules/{{i:healthrule_id}}/configuration' "$@" ; }
rde healthrule_enable "Enable a healthrule." "Provide an application (-a) and a health rule id (-i) as parameters." "-a 29 -i 54"
healthrule_get() { apiCall '/controller/healthrules/{{a:application}}/?name={{n:healthrule_name?}}' "$@" ; }
rde healthrule_get "Get a healthrule." "Provide an application (-a) and a health rule name (-n) as parameters." "-a 29"
healthrule_list() { apiCall '/controller/alerting/rest/v1/applications/{{a:application}}/health-rules' "$@" ; }
rde healthrule_list "List all healthrules." "Provide an application (-a) as parameter" "-a 29"
healthrule_violations() { apiCall '/controller/rest/applications/{{a:application}}/problems/healthrule-violations?time-range-type={{t:time_range_type}}&duration-in-mins={{d:duration_in_minutes?}}&start-time={{b:start_time?}}&end-time={{e:end_time?}}' "$@" ; }
rde healthrule_violations "Get all healthrule violations." "Provide an application (-a) and a time range type (-t) as parameters, as well as a duration in minutes (-d) or a start-time (-b) and an end time (-f)" "-a 29 -t BEFORE_NOW -d 120"
doc informationPoint << EOF
EOF
informationPoint_create() { apiCall -X POST -d '{{d:infopoint_config}}' '/controller/restui/informationPointUiService/createInfoPointGathererConfig' "$@" ; }
rde informationPoint_create "Create an information point." "Provide an json file (with @ as prefix) containing the information point config (-d) as parameter." "-d @examples/information_point.json"
informationPoint_delete() { apiCall -X POST -d '[{{i:information_points}}]' '/controller/restui/informationPointUiService/deleteInformationPoints' "$@" ; }
rde informationPoint_delete "Delete information points." "Provide an id or an list of ids of information points (-i) as parameter." "-i 1326,1327"
informationPoint_list() { apiCall '/controller/restui/informationPointUiService/getAllInfoPointsListViewData/{{a:application}}?time-range={{t:timerange}}' "$@" ; }
rde informationPoint_list "List information points." "Provide an application id (-a) and a time range string (-t) as parameters." "-a 6743 -t last_1_hour.BEFORE_NOW.-1.-1.60"
informationPoint_update() { apiCall -X POST -d '{{d:infopoint_config}}' '/controller/restui/informationPointUiService/updateInfoPointGathererConfig' "$@" ; }
rde informationPoint_update "Update an information point." "Provide an json file (with @ as prefix) containing the information point update config (-d) as parameter." "-d @examples/information_point_update.json"
doc licenserule << EOF
EOF
licenserule_create() { apiCall -X POST '/controller/mds/v1/license/rules' "$@" ; }
rde licenserule_create "Create a license rule." "Provide a json string or a @file (-d) as parameter." "-d examples/licenserule.json"
licenserule_detailview() { apiCall -X POST -d '{"type":"BEFORE_NOW","durationInMinutes":60}' '/controller/restui/licenseRule/getApmLicenseRuleDetailViewData/{{l:licenserule}}' "$@" ; }
rde licenserule_detailview "Get detail view for a license rule" "Provide a license id (-l) as parameter." "-l ff0fb8ff-d2ef-446d-83bd-8f8e5b8c0d20"
licenserule_list() { apiCall '/controller/mds/v1/license/rules' "$@" ; }
rde licenserule_list "List all license rules." "This command requires no further arguments" ""
doc logsources << EOF
EOF
logsources_import() { apiCall -X POST -d 'payload: {{d:logsourcerule}}' '/controller/restui/analytics/logsources' "$@" ; }
rde logsources_import "Import a source rule." "Provide a json string or a file (with @ as prefix) as parameter (-d)" "-d @examples/logsources.json"
logsources_list() { apiCall '/controller/restui/analytics/logsources' "$@" ; }
rde logsources_list "List all sources." "This command requires no further arguments." ""
doc mobileCrash << EOF
API to list and retrieve mobile crashes
EOF
mobileCrash_get() { apiCall '/controller/restui/crashDetails/download/{{a:application}}/{{c:crash}}' "$@" ; }
rde mobileCrash_get "Get crash details" "Provide an application ID (-a) and crash ID (-c) as parameters" "-a 41 -c d65fff8f-6ff0-4765-8ff4-2ffcbd0441bd"
doc node << EOF
Retrieve nodes within a business application
EOF
node_get() { apiCall '/controller/rest/applications/{{a:application}}/nodes/{{n:node}}' "$@" ; }
rde node_get "Get a node." "Provide the application (-a) and the node (-n) as parameters" "-a 29 -n 45"
node_list() { apiCall '/controller/rest/applications/{{a:application}}/nodes' "$@" ; }
rde node_list "List all nodes." "Provide the application id as parameter (-a)." "-a 29"
node_markhistorical() { apiCall -X POST '/controller/rest/mark-nodes-historical?application-component-node-ids={{n:nodes}}' "$@" ; }
rde node_markhistorical "Mark nodes as historical." "Provide a comma separated list of node ids." "-n 45,46"
node_move() { apiCall -X POST '/controller/restui/nodeUiService/moveNode/{{n:node}}/{{t:tier}}' "$@" ; }
rde node_move "Move node." "Provide a node id (-n) and a tier id (-t) to move the given node to the given tier." "-n 1782418 -t 187811"
doc otel << EOF
Configure OpenTelemetry collector for AppDynamics
EOF
otel_getApiKey() { apiCall '/controller/restui/otel/getOtelApiKey' "$@" ; }
rde otel_getApiKey "Get OpenTelemetry API Key" "No parameter required." ""
otel_isEnabled() { apiCall '/controller/restui/otel/isOtelEnabled' "$@" ; }
rde otel_isEnabled "Check if OpenTelemetry enabled." "No parameter required." ""
doc policy << EOF
Import and export policies
EOF
policy_export() { apiCall '/controller/policies/{{a:application}}' "$@" ; }
rde policy_export "List all policies." "Provide an application (-a) as parameter." "-a 29"
policy_get() { apiCall '/controller/restui/event_reactor/getAllEventReactorsForApplication/{{p:policy}}' "$@" ; }
rde policy_get "Get a policy." "Provide a policy id (-p) as parameter." "-p 9886"
policy_import() { apiCall -X POST -F 'file={{d:policy}}' '/controller/policies/{{a:application}}' "$@" ; }
rde policy_import "Import a policy." "Provide an application (-a) and a policy file or json (-d) as parameter." "-a 29 -d @examples/policy.json"
policy_update() { apiCall -X POST -d '{{d:policy}}' '/controller/restui/event_reactor/update' "$@" ; }
rde policy_update "Update an existing policy." "Provide a policy file or json (-d) as parameter." "-d @examples/policy.json"
doc sam << EOF
Manage service monitoring configurations
EOF
sam_create() { apiCall -X POST -d '{"name":"{{n:name}}","description":"","protocol":"HTTP","machineId":{{i:machineId}},"configs":{"target":"{{u:url}}","pingIntervalSeconds":{{p:pingInterval}},"failureThreshold":{{f:failureThreshold}},"successThreshold":{{s:successThreshold}},"thresholdWindow":{{w:thresholdWindow}},"connectTimeoutMillis":{{c:connectTimeout}},"socketTimeoutMillis":{{t:socketTimeout}},"method":"{{m:method}}","downloadSize":{{d:downloadSize}},"followRedirects":true,"headers":[{{h:headers?}}],"body":"{{b:body?}}","validationRules":[{{v:validationRules}}]}}' '/controller/sim/v2/user/sam/targets/http' "$@" ; }
rde sam_create "Create a monitor." "This command takes the following arguments. Those with '?' are optional: name (-n), machineId (-i), url (-u), interval (-i), failureThreshold (-f), successThreshold (-s), thresholdWindow (-w), connectTimeout (-c), socketTimeout (-t), method (-m), downloadSize (-d), headers (-h), body (-b), validationRules (-v)" "-n 'Checkout' -i 42 -u https://www.example.com/checkout -p 10 -f 1 -s 3 -w 5 -c 30000 -t 30000 -m POST -d 5000"
sam_delete() { apiCall -X DELETE '/controller/sim/v2/user/sam/targets/http/{{i:monitorId}}' "$@" ; }
rde sam_delete "Delete a monitor" "Provide a monitor id (-i) as parameter" "-i 29"
sam_get() { apiCall '/controller/sim/v2/user/sam/targets/http/{{i:monitorId}}' "$@" ; }
rde sam_get "Get a monitor." "Provide a monitor id (-i) as parameter" "-i 29"
sam_import() { apiCall -X POST -d '{{d:monitor_definition}}' '/controller/sim/v2/user/sam/targets/http' "$@" ; }
rde sam_import "Import a monitor." "Provide a json string or a @file (-d) as parameter." "-d @examples/sam.json"
sam_list() { apiCall '/controller/sim/v2/user/sam/targets/http' "$@" ; }
rde sam_list "List monitors." "This command requires no further arguments." ""
doc scope << EOF
Manage scopes for instrumentation
EOF
scope_create() { apiCall -X POST -d '{{d:scope_definition}}' '/controller/restui/transactionConfigProto/createScope?applicationId={{a:application}}' "$@" ; }
rde scope_create "Create a new scope." "Provide an application id (-a) as parameter" ""
scope_list() { apiCall '/controller/restui/transactionConfigProto/getScopes/{{a:application}}' "$@" ; }
rde scope_list "List all scopes." "Provide an application id (-a) as parameter" "-a 25"
doc sep << EOF
List service endpoints
EOF
sep_config() { apiCall '/controller/api/accounts/{{i:accountid}}/applications/{{a:application}}/sep' "$@" ; }
rde sep_config "List all SEP configurations." "Provide an application id (-a)." "-a 29"
sep_delete() { apiCall -X POST -d '[{{s:service_endpoints}}]' '/controller/restui/serviceEndpoint/delete' "$@" ; }
rde sep_delete "Delete SEPs" "Provide an id or an list of ids of service end points (-s) as parameter." "-s 11705717,11705424"
sep_list() { apiCall -X POST -d '{"requestFilter":{"queryParams":{"applicationId":{{a:application}},"mode":"FILTER_EXCLUDED"},"searchText":"","filters":{"type":[],"sepName":[]}},"columnSorts":[{"column":"NAME","direction":"ASC"}],"timeRangeStart":{{s:start}},"timeRangeEnd":{{e:end}}}' '/controller/restui/serviceEndpoint/list' "$@" ; }
rde sep_list "List all SEPs" "Provide an application id (-a), a start timestamp (-s) and an end timestamp (-e) as parameters." "-a 29 -s 1610389435 -e 1620389435"
sep_updateConfig() { apiCall -X POST -d '{{d:sep_json}}' '/controller/api/accounts/{{i:accountid}}/applications/{{a:application}}/sep' "$@" ; }
rde sep_updateConfig "Insert or Update SEPs." "Provide an application id (-a) and a json string or a @file (-d) as parameter." "-a 29 -d @examples/sep.json"
doc server << EOF
List servers, their properties and metrics
EOF
server_delete() { apiCall -X DELETE '/controller/sim/v2/user/machines/deleteMachines?ids={{m:machine}}' "$@" ; }
rde server_delete "Delete a machine." "Provide a machine id (-m) as parameter." "-m 244"
server_get() { apiCall '/controller/sim/v2/user/machines/{{m:machine}}' "$@" ; }
rde server_get "Get a machine." "Provide a machine id (-m) as parameter." "-m 244"
server_list() { apiCall '/controller/sim/v2/user/machines' "$@" ; }
rde server_list "List all machines." "No additional argument required." ""
server_query() { apiCall -X POST -d '{"filter":{"appIds":[],"nodeIds":[],"tierIds":[],"types":["PHYSICAL","CONTAINER_AWARE"],"timeRangeStart":0,"timeRangeEnd":0},"search":{"query":"{{m:machine}}"},"sorter":{"field":"HEALTH","direction":"ASC"}}' '/controller/sim/v2/user/machines/keys' "$@" ; }
rde server_query "Query a machineagent by hostname" "provide a machine name (-m) as parameter" "-m Myserver or if you want to query your own name -m \${HOSTNAME} on Linux"
doc snapshot << EOF
List APM snapshots.
EOF
snapshot_list() { apiCall '/controller/rest/applications/{{a:application}}/request-snapshots?time-range-type={{t:time_range_type}}&duration-in-mins={{d:duration_in_minutes?}}&start-time={{b:start_time?}}&end-time={{f:end_time?}}&need-props=true&need-exit-calls=true' "$@" ; }
rde snapshot_list "Retrieve a list of snapshots" "Provide an application (-a) as parameter, as well as a time range (-t), the duration in minutes (-d) or start (-b) and end time (-f)" "-a 29 -t BEFORE_NOW -d 120"
doc synthetic << EOF
Create synthetic snapshots or jobs
EOF
synthetic_import() { apiCallExpand -X POST -d '{{d:synthetic_job}}' '/controller/restui/synthetic/schedule/{{a:application}}/updateSchedule' "$@" ; }
rde synthetic_import "Import a synthetic job." "Provide an EUM application id (-a) as parameter and a json string or a file (with @ as prefix) as parameter (-d)" "-a 41 -d @examples/syntheticjob.json"
synthetic_list() { apiCall -X POST '/controller/restui/synthetic/schedule/getJobList/{{a:application}}' "$@" ; }
rde synthetic_list "List all synthetic jobs." "Provide an EUM application id (-a) as parameter." "-a 41"
synthetic_snapshot() { apiCall -X POST -d '{"url":"{{u:url}}","location":"{{l:location}}","browser":"{{b:browser}}","applicationId":{{a:application}},"timeRangeString":null,"timeoutSeconds":30,"script":null}' '/controller/restui/synthetic/launch/generateLoad' "$@" ; }
rde synthetic_snapshot "Generate synthetic snapshot." "Provide an EUM application (-a), a brower (-b) and an URL (-u) as parameter." "-u http://www.appdynmics.com -l AMS -b Chrome -a 128"
synthetic_update() { apiCall -X POST -d '{{d:synthetic_job}}' '/controller/restui/synthetic/schedule/{{a:application}}/updateScheduleBatch' "$@" ; }
rde synthetic_update "Update a synthetic job." "Provide an EUM application id (-a) as parameter and a json string or a file (with @ as prefix) as parameter (-d)" "-a 41 -d @examples/updatesyntheticjob.json"
doc tier << EOF
List all tiers.
EOF
tier_get() { apiCall '/controller/rest/applications/{{a:application}}/tiers/{{t:tier}}' "$@" ; }
rde tier_get "Get a tier." "Provide the application (-a) and the tier (-t) as parameters" "-a 29 -t 45"
tier_list() { apiCall '/controller/rest/applications/{{a:application}}/tiers' "$@" ; }
rde tier_list "List all tiers for a given application." "Provide the application id as parameter (-a)." "-a 29"
tier_nodes() { apiCall '/controller/rest/applications/{{a:application}}/tiers/{{t:tier}}/nodes' "$@" ; }
rde tier_nodes "List nodes for a tier." "Provide the application (-a) and the tier (-t) as parameters" "-a 29 -t 45"
doc transactiondetection << EOF
Import and export transaction detection rules.
EOF
transactiondetection_export() { apiCall '/controller/transactiondetection/{{a:application}}/{{r:ruletype}}/{{e:entrypointtype?}}' "$@" ; }
rde transactiondetection_export "Export transaction detection rules." "Provide the application (-a) and the rule type (-r) as parameters. Provide an entry point type (-e) as optional parameter." "-a 29 -r custom -e servlet"
transactiondetection_import() { apiCall -X POST -F 'file={{d:transaction_detection_rules}}' '/controller/transactiondetection/{{a:application}}/{{r:ruletype}}/{{e:entrypointtype?}}' "$@" ; }
rde transactiondetection_import "Import transaction detection rules." "Provide the application (-a), the rule type (-r) and an xml file (with @ as prefix) containing the rules (-d) as parameters. Provide an entry point type (-e) as optional parameter." "-a 29 -r custom -e servlet -d @rules.xml"
doc user << EOF
Create and Modify AppDynamics Users.
EOF
user_create() { apiCall -X POST '/controller/rest/users?user-name={{n:user_name}}&user-display-name={{d:user_display_name}}&user-password={{p:user_password}}&user-email={{m:user_mail}}&user-roles={{r:user_roles?}}' "$@" ; }
rde user_create "Create a new user." "Provide a name (-n), a display name (-d), a list of roles (-r), a password (-p) and a mail address (-m) as parameters." "-n myadmin -d Administrator -r "Account Administrator,Administrator" -p ******** -m admin@localhost"
user_update() { apiCall -X POST '/controller/rest/users?user-id={{i:user_id}}&user-name={{n:user_name}}&user-display-name={{d:user_display_name}}&user-password={{p:user_password?}}&user-email={{m:user_mail}}&user-roles={{r:user_roles?}}' "$@" ; }
rde user_update "Update an existing user." "Provide an id (-i), name (-n), a display name (-d), a list of roles (-r), a password (-p) and a mail address (-m) as parameters." "-n myadmin -d Administrator -r "Account Administrator,Administrator" -p ******** -m admin@localhost"
dbmon_create() {
  apiCall -X POST -d "{ \
                      \"name\": \"{{i}}\",\
                      \"username\": \"{{u}}\",\
                      \"hostname\": \"{{h}}\",\
                      \"agentName\": \"{{a}}\",\
                      \"type\": \"{{t}}\",\
                      \"orapkiSslEnabled\": false,\
                      \"orasslTruststoreLoc\": null,\
                      \"orasslTruststoreType\": null,\
                      \"orasslTruststorePassword\": null,\
                      \"orasslClientAuthEnabled\": false,\
                      \"orasslKeystoreLoc\": null,\
                      \"orasslKeystoreType\": null,\
                      \"orasslKeystorePassword\": null,\
                      \"databaseName\": \"{{n}}\",\
                      \"port\": \"{{p}}\",\
                      \"password\": \"{{s}}\",\
                      \"excludedSchemas\": [],\
                      \"enabled\": true\
                    }" /controller/rest/databases/collectors/create "$@"
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
example dbmon_create << EOF
-i MyTestDB -h localhost -n db -u user -a "Default Database Agent" -t DB2 -p 1555 -s password
EOF
dbmon_events() {
  event_list -a '_dbmon' "$@"
}
register dbmon_events List all database agent events.
describe dbmon_events << EOF
List all database agent events. This is an alias for \`${SCRIPTNAME} event list -a '_dbmon'\`, so you can use the same parameters for querying the events.
EOF
example dbmon_events << EOF
-t BEFORE_NOW -d 60 -s INFO,WARN,ERROR -e AGENT_EVENT
EOF
_doc() {
read -r -d '' COMMAND_RESULT <<- EOM
# Usage
Below you will find a list of all available namespaces and commands available with
\`act.sh\`. The given examples allow you to understand, how each command is used.
For more complex examples, have a look into [RECIPES.md](RECIPES.md)
## Options
The following options are available on a global level. Put them in front of your command (e.g. \`${SCRIPTNAME} -E testenv -vvv application list\`):${EOL}
| Option | Description |
|--------|-------------|
${AVAILABLE_GLOBAL_OPTIONS}
EOM
  local NAMESPACES=""
  for INDEX in "${!GLOBAL_LONG_HELP_COMMANDS[@]}" ; do
    local COMMAND="${GLOBAL_LONG_HELP_COMMANDS[$INDEX]}"
    NAMESPACES="${NAMESPACES}\n${COMMAND%%_*}"
  done
  for NS in "" $(echo -en $NAMESPACES | sort -u); do
    debug "Processing ${NS}";
    COMMAND_RESULT="${COMMAND_RESULT}${EOL}${EOL}## ${NS:-Global}${EOL}"
    for INDEX in "${!GLOBAL_DOC_NAMESPACES[@]}" ; do
      local NS2="${GLOBAL_DOC_NAMESPACES[$INDEX]}"
      if [ "${NS}" == "${NS2}" ] ; then
        local DOC=${GLOBAL_DOC_STRINGS[$INDEX]}
        COMMAND_RESULT="${COMMAND_RESULT}${EOL}${DOC}${EOL}"
      fi
    done;
    COMMAND_RESULT="${COMMAND_RESULT}${EOL}| Command | Description | Example |"
    COMMAND_RESULT="${COMMAND_RESULT}${EOL}| ------- | ----------- | ------- |"
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
        COMMAND_RESULT="${COMMAND_RESULT}${EOL}| ${COMMAND##*_} | ${HELP//$'\n'/"<br>"/} | ${EXAMPLE} |"
      fi
    done
    COMMAND_RESULT="${COMMAND_RESULT}${EOL}"
  done;
}
register _doc Print the output of help in markdown
doc "" << EOF
The following commands in the global namespace can be called directly.
EOF
_help() {
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
_usage() {
    # shellcheck disable=SC2034
    read -r -d '' COMMAND_RESULT <<- EOM
Usage: ${USAGE_DESCRIPTION}${EOL}
'${SCRIPTNAME} help' will list available namespaces and subcommands.
See '${SCRIPTNAME} help <namespace>' to read about a specific namespace and the available subcommands
EOM
}
register _usage Display usage information.
controller_isup() {
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
example controller_isup << EOF
; ${SCRIPTNAME} application list
EOF
controller_call() {
  debug "Calling $CONFIG_CONTROLLER_HOST"
  local METHOD="GET"
  local FORM=""
  local PAYLOAD
  local USE_BASIC_AUTH=0
  debug "$@"
  while getopts "X:d:F:B" opt "$@";
  do
    case "${opt}" in
      X)
	METHOD=${OPTARG}
      ;;
      d)
        PAYLOAD="${OPTARG}"
      ;;
      F)
        FORM="${OPTARG}"
      ;;
      B)
        USE_BASIC_AUTH=1
      ;;
      *)
        debug "Invalid flag ${OPTARG} for controller_call"
      ;;
    esac
  done
  shiftOptInd
  shift $SHIFTS
  ENDPOINT=$*
  if [ "${CONFIG_OUTPUT_FORMAT}" == "JSON" ] ; then
    if [[ ${ENDPOINT} = *"?"* ]]; then
      ENDPOINT="${ENDPOINT}&output=JSON"
    else
      ENDPOINT="${ENDPOINT}?output=JSON"
    fi;
  fi;
  if [ "${USE_BASIC_AUTH}" -eq 1 ] ; then
    debug "Using basic authentication"
    CONTROLLER_LOGIN_STATUS=1
  else
    controller_login
  fi
  # Debug the COMMAND_RESULT from controller_login
  debug "Login result: $COMMAND_RESULT"
  if [ $CONTROLLER_LOGIN_STATUS -eq 1 ]; then
    debug "Endpoint: $ENDPOINT"
    local SEPERATOR="==========act-stats: ${RANDOM}-${RANDOM}-${RANDOM}-${RANDOM}"
    local HTTP_CLIENT_RESULT=""
    local HTTP_CALL=("-s")
    if [ "${CONFIG_OUTPUT_VERBOSITY/debug}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
      HTTP_CALL=("-v")
    fi
    if [ "${USE_BASIC_AUTH}" -eq 1 ] ; then
      HTTP_CALL+=("--user" "${CONFIG_CONTROLLER_CREDENTIALS}" "-X" "${METHOD}")
    else
      HTTP_CALL+=("-b" "${CONFIG_CONTROLLER_COOKIE_LOCATION}" "-X" "${METHOD}" "-H" "X-CSRF-TOKEN: ${XCSRFTOKEN}")
    fi
    if [ -n "$FORM" ] ; then
      HTTP_CALL+=("-F" "${FORM}")
    else
      HTTP_CALL+=("-H" "Content-Type: application/json;charset=UTF-8")
    fi;
    HTTP_CALL+=("-H" "Accept: application/json, text/plain, */*")
    if [ -n "${PAYLOAD}" ] ; then
      HTTP_CALL+=("-d" "${PAYLOAD}")
    fi;
    if [ "${CONFIG_OUTPUT_COMMAND}" -eq 1 ] ; then
      HTTP_CALL+=("${CONFIG_CONTROLLER_HOST}${ENDPOINT}")
      COMMAND_RESULT="curl -L"
      for P in "${HTTP_CALL[@]}" ; do
        if [[ "$P" == -* ]]; then
          COMMAND_RESULT="$COMMAND_RESULT $P"
        else
          COMMAND_RESULT="$COMMAND_RESULT '$P'"
        fi
      done
    else
      HTTP_CALL+=("-w" "${SEPERATOR}%{http_code}")
      HTTP_CALL+=("${CONFIG_CONTROLLER_HOST}${ENDPOINT}")
      HTTP_CLIENT_RESULT=`httpClient "${HTTP_CALL[@]}"`
      COMMAND_RESULT=${HTTP_CLIENT_RESULT%${SEPERATOR}*}
      COMMAND_STATS=${HTTP_CLIENT_RESULT##*${SEPERATOR}}
       debug "Command result: ($COMMAND_RESULT)"
       info "HTTP Status Code: $COMMAND_STATS"
       if [ -z "${COMMAND_RESULT}" ] ; then
         COMMAND_RESULT="HTTP Status: ${COMMAND_STATS}"
       fi
    fi
   else
     COMMAND_RESULT="Controller Login Error! Please check hostname and credentials"
   fi
}
register controller_call Send a custom HTTP call to a controller
describe controller_call << EOF
Send a custom HTTP call to an AppDynamics controller. Provide the endpoint you want to call as parameter. You can modify the http method with option -X and add payload with option -d.
EOF
example controller_call << EOF
/controller/rest/serverstatus
EOF
CONTROLLER_LOGIN_STATUS=0
controller_login() {
  debug "Login at ${CONFIG_CONTROLLER_HOST} with ${CONFIG_CONTROLLER_CREDENTIALS}"
  LOGIN_RESPONSE=$(httpClient -v -c "${CONFIG_CONTROLLER_COOKIE_LOCATION}" --user "${CONFIG_CONTROLLER_CREDENTIALS}" "${CONFIG_CONTROLLER_HOST}/controller/auth?action=login" 2>&1)
  debug "RESPONSE: ${LOGIN_RESPONSE}"
  # The section option is for supporting HTTP2 (#12)
  if [[ "${LOGIN_RESPONSE/200 OK}" != "${LOGIN_RESPONSE}" ]] || [[ "${LOGIN_RESPONSE/HTTP\/2 200}" != "${LOGIN_RESPONSE}" ]]; then
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
Check if the login with your appdynamics controller works properly. If the login fails, use \`${SCRIPTNAME} controller ping\` to check if the controller is running and check your credentials if they are correct.
EOF
example controller_login << EOF
EOF
controller_ping() {
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
example controller_ping << EOF
EOF
controller_version() {
  controller_call -X GET /controller/rest/serverstatus
  COMMAND_RESULT=`echo -e $COMMAND_RESULT | sed -n -e 's/.*Controller v\(.*\) Build.*/\1/p'`
}
register controller_version Get installed version from controller
describe controller_version << EOF
Get installed version from controller
EOF
example controller_version << EOF
EOF
actiontemplate_delete() {
  local TYPE="httprequest"
  local ID=0
  while getopts "t:i:" opt "$@";
  do
    case "${opt}" in
      t)
        TYPE=${OPTARG}
      ;;
      i)
        ID=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  if [ "${ID}" -eq 0 ] ; then
    error "actiontemplate id is not set"
    COMMAND_RESULT=""
  elif [ "$TYPE" == "httprequest" ] ; then
    controller_call -X POST -d "${ID}" '/controller/restui/httpaction/deleteHttpRequestActionPlan' "$@"
  else
    controller_call -X POST -d "${ID}" '/controller/restui/emailaction/deleteCustomEmailActionPlan' "$@"
  fi;
}
register actiontemplate_delete "Delete an action template"
describe actiontemplate_delete << EOF
Delete an action template. Provide an id (-i) and a type (-t) as parameters.
EOF
example actiontemplate_export << EOF
-t httprequest
EOF
actiontemplate_import() {
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
example actiontemplate_import << EOF
template.json
EOF
actiontemplate_list() {
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
  if [ "$TYPE" == "httprequest" ] ; then
    controller_call '/controller/restui/httpaction/getHttpRequestActionPlanList'
  else
    controller_call 'controller/restui/emailaction/getCustomEmailActionPlanList'
  fi;
}
register actiontemplate_list "List all actiontemplates."
describe actiontemplate_list << EOF
List all actiontemplates. Provide a type (-t) as parameter.
EOF
example actiontemplate_export << EOF
-t httprequest
EOF
PORTAL_LOGIN_STATUS=0
PORTAL_LOGIN_TOKEN=""
download_login() {
  if [ -n "$CONFIG_PORTAL_CREDENTIALS" ] ; then
    USERNAME=${CONFIG_PORTAL_CREDENTIALS%%:*}
    PASSWORD=${CONFIG_PORTAL_CREDENTIALS#*:}
    debug "Login at 'https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token' with $USERNAME and $PASSWORD"
    LOGIN_RESPONSE=$(httpClient -s -X POST -d "{\"username\": \"${USERNAME}\",\"password\": \"${PASSWORD}\",\"scopes\": [\"download\"]}" https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token)
    if [[ "${LOGIN_RESPONSE/\"error\"}" != "${LOGIN_RESPONSE}" ]]; then
      COMMAND_RESULT="Login Error! Please check your portal credentials."
    else
      PORTAL_LOGIN_STATUS=1
      PORTAL_LOGIN_TOKEN="${LOGIN_RESPONSE#*"access_token\": \""}"
      PORTAL_LOGIN_TOKEN=${PORTAL_LOGIN_TOKEN%%\"*}
      COMMAND_RESULT="Login Successful! Token: ${PORTAL_LOGIN_TOKEN}"
    fi
  else
    COMMAND_RESULT="Please run $1 config -p to setup portal credentials."
  fi
}
rde download_login "Login with AppDynamics to retrieve an OAUTH token for downloads." "You can use the provided token for downloads from https://download.appdynamics.com/" ""
download_get() {
  local WORKING_DIRECTORY="."
  local DOWNLOAD_DRYRUN=0
  local DOWNLOAD_ALL_MATCHES=0
  local DOWNLOAD_FILTER=""
  local SEARCH=""
  local WITHSEARCH=""
  while getopts "Aard:s:" opt "$@";
  do
    case "${opt}" in
      d)
        WORKING_DIRECTORY=${OPTARG}
      ;;
      r)
        DOWNLOAD_DRYRUN=1
      ;;
      s)
        WITHSEARCH="-s"
        SEARCH="${OPTARG}"
        DOWNLOAD_FILTER='.*'
      ;;
      a)
        DOWNLOAD_ALL_MATCHES=1
      ;;
      A)
        DOWNLOAD_ALL_MATCHES=1
        DOWNLOAD_FILTER='.*'
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  if [ ! -d ${WORKING_DIRECTORY} ] ; then
    error "${WORKING_DIRECTORY} is not a directory"
    exit 1
  fi;
  if [ "${DOWNLOAD_ALL_MATCHES}" -eq "0" ] ; then
    download_list -f "${1:-${DOWNLOAD_FILTER}}" -1 -d ${WITHSEARCH} "${SEARCH}"
  else
    download_list -f "${1:-${DOWNLOAD_FILTER}}" -d ${WITHSEARCH} "${SEARCH}"
  fi
  # use echo to remove trailing line breaks
  FILES=$COMMAND_RESULT
  COMMAND_RESULT=""
  if [ "$FILES" != "" ]; then
    download_login
    if [ $PORTAL_LOGIN_STATUS -eq 1 ] ; then
      OLD_DIRECTORY=`pwd`
      cd ${WORKING_DIRECTORY} || exit
      for FILE in ${FILES} ; do
        output "Downloading ${FILE} to ${WORKING_DIRECTORY}"
        if [ "${DOWNLOAD_DRYRUN}" -eq "0" ] ; then
          httpClient -L -O -H "Authorization: Bearer ${PORTAL_LOGIN_TOKEN}" "${FILE}"
        else
          output "Dry run."
        fi
      done
      COMMAND_RESULT="Successfully downloaded $(bashBasename ${FILE}) to ${WORKING_DIRECTORY}"
      cd "${OLD_DIRECTORY}" || exit
    fi
  else
    COMMAND_RESULT="No matching agent found."
  fi
}
rde download_get "Download an agent." "You need to provide a partial name of an agent you want to download. Optionally, you can provide a directory (-d) as download location. By default only the first match is downloaded, you can provide parameter -a to download all matches." "-d /tmp golang"
download_list() {
  local FILES
  local DELIMITER='"filename":'
  local ENTRY
  local DOWNLOADFILES="https://download.appdynamics.com/download/downloadfilelatest/"
  local FILTER='.*'
  local BREAKONFIRST=0
  while getopts "1df:s:" opt "$@";
  do
    case "${opt}" in
      d)
        DELIMITER='"download_path":'
      ;;
      f)
        FILTER="${OPTARG}"
      ;;
      s)
        DOWNLOADFILES="https://download.appdynamics.com/download/downloadfile/?format=json&page=1&search=$(urlencode "${OPTARG}")"
      ;;
      1)
        BREAKONFIRST=1
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  output "Downloading list of available files. Please wait."
  debug "Download URL: ${DOWNLOADFILES}"
  FILES=$(httpClient -s "${DOWNLOADFILES}")
  #delimiter='"download_path":'
  local s=$FILES${DELIMITER}
  COMMAND_RESULT=""
  while [[ $s ]]; do
    ENTRY="${s%%"${DELIMITER}"*}\n\n"
    if [ "${ENTRY:0:1}" == "\"" ] ; then
	    ENTRY=${ENTRY:1}
      ENTRY=${ENTRY%%\",*}
      if [[ "${ENTRY}" =~ ${FILTER} ]] ; then
	       COMMAND_RESULT="${COMMAND_RESULT}${ENTRY}${EOL}"
         if [ "${BREAKONFIRST}" -eq 1 ] ; then
           return
         fi;
      else
        debug "${ENTRY} does not match ${FILTER}"
      fi;
    fi;
    s=${s#*"${DELIMITER}"};
  done;
}
rde download_list "List agent files." "You can provide a filter (-f) to filter for specific agent files. Or you can provide a search query (-s) to execute . Provide parameter -d to get the full download path" "-d -f golang"
download_versionlist() {
  local DELIMITER='"version":'
  local DEGREE=3
  local FILES=''
  while getopts "d:" opt "$@";
  do
    case "${opt}" in
      d)
        DEGREE="${OPTARG}"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  FILES=$(httpClient -s "https://download.appdynamics.com/download/version/?version-degree=${DEGREE}")
  local s=$FILES${DELIMITER}
  COMMAND_RESULT=""
  while [[ $s ]]; do
    ENTRY="${s%%"${DELIMITER}"*}\n\n"
    if [ "${ENTRY:0:1}" == "\"" ] ; then
      ENTRY=${ENTRY:1}
      ENTRY=${ENTRY%%\",*}
      COMMAND_RESULT="${COMMAND_RESULT}${ENTRY}${EOL}"
    fi;
    s=${s#*"${DELIMITER}"};
  done;
}
rde download_versionlist "" "" ""
federation_setup() {
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
}
register federation_setup Setup a controller federation: Generates a key and establishes the mutal friendship.
describe federation_setup << EOF
Setup a controller federation: Generates a key and establishes the mutal friendship.
EOF
eum_getapps() {
  apiCall  "/controller/restui/eumApplications/getAllEumApplicationsData?time-range=last_1_hour.BEFORE_NOW.-1.-1.60"
}
register eum_getapps Get EUM App Keys
describe eum_getapps << EOF
Get EUM Apps.
EOF
timerange_delete() {
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
timerange_create() {
  local START_TIME=-1
  local END_TIME=-1
  local DURATION_IN_MINUTES=0
  local TYPE="BETWEEN_TIMES"
  local DESCRIPTION
  local SHARED=false
  while getopts "s:e:d:SD:" opt "$@";
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
      S)
        SHARED="true"
      ;;
      D)
        DESCRIPTION=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  TIMERANGE_NAME=$*
  controller_call -X POST -d "{\"name\":\"$TIMERANGE_NAME\",\"description\":\"$DESCRIPTION\",\"shared\":$SHARED,\"timeRange\":{\"type\":\"$TYPE\",\"durationInMinutes\":$DURATION_IN_MINUTES,\"startTime\":$START_TIME,\"endTime\":$END_TIME}}" /controller/restui/user/createCustomRange
}
register timerange_create Create a custom time range
describe timerange_create << EOF
Create a custom time range
EOF
timerange_list() {
  controller_call -X GET /controller/restui/user/getAllCustomTimeRanges
}
register timerange_list List all custom timeranges available on the controller
describe timerange_list << EOF
List all custom timeranges available on the controller
EOF
doc environment << EOF
If you want to use ${SCRIPTNAME} to manage multiple controllers, you can use environments to add and manage them easily.
Use \`${SCRIPTNAME} environment add\` to create an environment providing a name, controller url and credentials.
Afterwards you can use \`${SCRIPTNAME} -E <name>\` to call the given controller.
EOF
environment_source() {
  if [ "$1" == "" ] ; then
    source "${HOME}/.appdynamics/act/config.sh"
  else
    source "${HOME}/.appdynamics/act/config.$1.sh"
  fi
}
register environment_source Load environment variables
describe environment_source << EOF
Load environment variables
EOF
example environment_source << EOF
myaccount
EOF
environment_get() {
  COMMAND_RESULT=`cat "${HOME}/.appdynamics/act/config.$1.sh"`
}
register environment_get Retrieve an environment
describe environment_get << EOF
Retrieve an environment. Provide the name of the environment as parameter.
EOF
example environment_get << EOF
myaccount
EOF
environment_delete() {
  rm "${HOME}/.appdynamics/act/config.$1.sh"
  COMMAND_RESULT="${1} deleted"
}
register environment_delete "Delete an environment"
describe environment_delete << EOF
Delete an environment. Provide the name of the environment as parameter.
EOF
example environment_delete << EOF
myaccount
EOF
environment_add() {
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
    OUTPUT_FILE="${OUTPUT_DIRECTORY}/config.${ENVIRONMENT}.sh"
    if [ $DEFAULT -eq 1 ] ; then
      OUTPUT_FILE="${OUTPUT_DIRECTORY}/config.sh"
    fi
    if [ ! -s "${OUTPUT_FILE}" ] || [ $FORCE -eq 1 ]
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
Add a new environment. To change the default environment, run with \`-d\`
EOF
example environment_add << EOF
-d
EOF
environment_list() {
  local BASE
  local TEMP
  COMMAND_RESULT="(default)"
  for file in "${HOME}/.appdynamics/act/config."*".sh"
  do
    BASE=$(bashBasename "${file}")
    TEMP=${BASE#*.}
    COMMAND_RESULT="${COMMAND_RESULT} ${TEMP%.*}"
  done
}
register environment_list List all your environments
describe environment_list << EOF
List all your environments
EOF
example environment_list << EOF
EOF
environment_export() {
  environment_source "${1}";
  local USER_AND_ACCOUNT="${CONFIG_CONTROLLER_CREDENTIALS%%:*}"
  read -r -d '' COMMAND_RESULT << EOF
  {
  	"name": "${1:-default}",
  	"values": [
  		{
  			"key": "controller_host",
  			"value": "${CONFIG_CONTROLLER_HOST}",
  			"description": "",
  			"enabled": true
  		},
  		{
  			"key": "controller_user",
  			"value": "${USER_AND_ACCOUNT%%@*}",
  			"description": "",
  			"enabled": true
  		},
      {
  			"key": "controller_account",
  			"value": "${USER_AND_ACCOUNT##*@}",
  			"description": "",
  			"enabled": true
  		},
      {
  			"key": "controller_password",
  			"value": "${CONFIG_CONTROLLER_CREDENTIALS#*:}",
  			"description": "",
  			"enabled": true
  		}
  	],
  	"_postman_variable_scope": "environment"
  }
EOF
}
register environment_export Export an environment into a postman environment
describe environment_export << EOF
Export an environment into a postman environment
EOF
example environment_export << EOF
> output.json
EOF
environment_edit() {
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
_config() {
  environment_add -d "$@"
}
register _config "Initialize the default environment. This is an alias for \`${SCRIPTNAME} environment add -d\`"
describe _config << EOF
Initialize the default environment. This is an alias for \`${SCRIPTNAME} environment add -d\`
EOF
example _config << EOF
EOF
_version() {
  # shellcheck disable=SC2034
  COMMAND_RESULT="$ACT_VERSION ~ $ACT_LAST_COMMIT (${GLOBAL_COMMANDS_COUNTER} commands)"
}
register _version Print the current version of $SCRIPTNAME
describe _version << EOF
Print the current version of $SCRIPTNAME
EOF
example _version << EOF
EOF
metric_get() {
  local APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local START_TIME=-1
  local END_TIME=-1
  local DURATION_IN_MINUTES=0
  local TYPE="BEFORE_NOW"
  local ROLLUP="true"
  while getopts "a:s:e:d:t:r:" opt "$@";
  do
    case "${opt}" in
      a)
        APPLICATION=`urlencode "${OPTARG}"`
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
      r)
        ROLLUP=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  debug ${APPLICATION}
  local METRIC_PATH=`urlencode "$*"`
  controller_call -B -X GET "/controller/rest/applications/${APPLICATION}/metric-data?metric-path=${METRIC_PATH}&time-range-type=${TYPE}&duration-in-mins=${DURATION_IN_MINUTES}&start-time=${START_TIME}&end-time=${END_TIME}&rollup=${ROLLUP}"
}
register metric_get Get a specific metric
describe metric_get << EOF
Get a specific metric by providing the metric path. Provide the application with option -a
EOF
RECURSIVE_COMMAND_RESULT=""
metric_tree() {
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
        RECURSIVE_COMMAND_RESULT="${RECURSIVE_COMMAND_RESULT}${TABS}${name%\"}${EOL}"
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
metric_list() {
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
healthrule_import() {
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
healthrule_copy() {
  local SOURCE_APPLICATION=${CONFIG_CONTROLLER_DEFAULT_APPLICATION}
  local TARGET_APPLICATION=""
  local TARGET_ENVIRONMENT=""
  while getopts "s:t:e:" opt "$@";
  do
    case "${opt}" in
      s)
        SOURCE_APPLICATION="${OPTARG}"
      ;;
      t)
        TARGET_APPLICATION="${OPTARG}"
      ;;
      e)
        TARGET_ENVIRONMENT="${OPTARG}"
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  if [ -z "${SOURCE_APPLICATION}" ] ; then
    COMMAND_RESULT=""
    error "Source application is empty."
    exit
  fi
  if [ -z "${TARGET_APPLICATION}" ] ; then
    COMMAND_RESULT=""
    error "Target application is empty."
    exit
  fi
  OLD_CONFIG_OUTPUT_VERBOSITY=${CONFIG_OUTPUT_VERBOSITY}
  CONFIG_OUTPUT_VERBOSITY="output"
  healthrule_list -a ${SOURCE_APPLICATION}
  CONFIG_OUTPUT_VERBOSITY="${OLD_CONFIG_OUTPUT_VERBOSITY}"
  SOURCE_HEALTHRULE=${COMMAND_RESULT}
  COMMAND_RESULT=""
  if [ "${SOURCE_HEALTHRULE:1:12}" == "health-rules" ]
  then
    local R=${RANDOM}
    echo "$SOURCE_HEALTHRULE" > "/tmp/act-output-${R}"
    if [ -n "${TARGET_ENVIRONMENT}" ] ; then
      debug "Copy to target environment $TARGET_ENVIRONMENT, target application $TARGET_APPLICATION."
      $0 -E ${TARGET_ENVIRONMENT} healthrule import -a ${TARGET_APPLICATION} "/tmp/act-output-${R}"
    else
      debug "Copy to target application $TARGET_APPLICATION"
      healthrule_import -a "${TARGET_APPLICATION}" "/tmp/act-output-${R}"
    fi
    rm "/tmp/act-output-${R}"
  else
    COMMAND_RESULT="Could not export health rules from source application: ${COMMAND_RESULT}"
  fi
}
register healthrule_copy Copy healthrules from one application to another.
describe healthrule_copy << EOF
Copy healthrules from one application to another. Provide the source application id ("-s") and the target application ("-t").
If you provide ("-n") only the named health rule will be copied.
EOF
event_list() {
  # Add some "ALL" magic
  local PREV=""
  local ARGS=()
  for ARG in "$@"; do
    if [ "${PREV}" == "-s" ] && [ "${ARG}" == "ALL" ] ; then
      ARG="INFO,WARN,ERROR"
    fi;
    if [ "${PREV}" == "-e" ] && [ "${ARG}" == "ALL" ] ; then
      # DB_SERVER_PARAMETER_CHANGE
      ARG="ACTIVITY_TRACE,ADJUDICATION_CANCELLED,AGENT_ADD_BLACKLIST_REG_LIMIT_REACHED,AGENT_ASYNC_ADD_REG_LIMIT_REACHED,AGENT_CONFIGURATION_ERROR,APPLICATION_CRASH,AGENT_DIAGNOSTICS,AGENT_ERROR_ADD_REG_LIMIT_REACHED,AGENT_EVENT,AGENT_METRIC_BLACKLIST_REG_LIMIT_REACHED,AGENT_METRIC_REG_LIMIT_REACHED,AGENT_STATUS,ALREADY_ADJUDICATED,APPDYNAMICS_DATA,APPDYNAMICS_INTERNAL_DIAGNOSTICS,APPLICATION_CONFIG_CHANGE,APPLICATION_DEPLOYMENT,APPLICATION_DISCOVERED,APPLICATION_ERROR,APP_SERVER_RESTART,AZURE_AUTO_SCALING,BACKEND_DISCOVERED,BT_DISCOVERED,BUSINESS_ERROR,CLR_CRASH,CONTROLLER_AGENT_VERSION_INCOMPATIBILITY,CONTROLLER_ASYNC_ADD_REG_LIMIT_REACHED,CONTROLLER_COLLECTIONS_ADD_REG_LIMIT_REACHED,CONTROLLER_ERROR_ADD_REG_LIMIT_REACHED,CONTROLLER_EVENT_UPLOAD_LIMIT_REACHED,CONTROLLER_MEMORY_ADD_REG_LIMIT_REACHED,CONTROLLER_METADATA_REGISTRATION_LIMIT_REACHED,CONTROLLER_METRIC_DATA_BUFFER_OVERFLOW,CONTROLLER_METRIC_REG_LIMIT_REACHED,CONTROLLER_PSD_UPLOAD_LIMIT_REACHED,CONTROLLER_RSD_UPLOAD_LIMIT_REACHED,CONTROLLER_SEP_ADD_REG_LIMIT_REACHED,CONTROLLER_STACKTRACE_ADD_REG_LIMIT_REACHED,CONTROLLER_TRACKED_OBJECT_ADD_REG_LIMIT_REACHED,CUSTOM,CUSTOM_ACTION_END,CUSTOM_ACTION_FAILED,CUSTOM_ACTION_STARTED,CUSTOM_EMAIL_ACTION_END,CUSTOM_EMAIL_ACTION_FAILED,CUSTOM_EMAIL_ACTION_STARTED,DEADLOCK,DEV_MODE_CONFIG_UPDATE,DIAGNOSTIC_SESSION,DISK_SPACE,EMAIL_ACTION_FAILED,EMAIL_SENT,EUM_CLOUD_BROWSER_EVENT,EUM_CLOUD_SYNTHETIC_BROWSER_EVENT,EUM_INTERNAL_ERROR,HTTP_REQUEST_ACTION_END,HTTP_REQUEST_ACTION_FAILED,HTTP_REQUEST_ACTION_STARTED,INFO_INSTRUMENTATION_VISIBILITY,INTERNAL_UI_EVENT,JIRA_ACTION_END,JIRA_ACTION_FAILED,JIRA_ACTION_STARTED,LICENSE,MACHINE_AGENT_LOG,MACHINE_DISCOVERED,MEMORY,MEMORY_LEAK_DIAGNOSTICS,MOBILE_CRASH_IOS_EVENT,MOBILE_CRASH_ANDROID_EVENT,NETWORK,NODE_DISCOVERED,NORMAL,OBJECT_CONTENT_SUMMARY,POLICY_CANCELED_CRITICAL,POLICY_CANCELED_WARNING,POLICY_CLOSE_CRITICAL,POLICY_CLOSE_WARNING,POLICY_CONTINUES_CRITICAL,POLICY_CONTINUES_WARNING,POLICY_DOWNGRADED,POLICY_OPEN_CRITICAL,POLICY_OPEN_WARNING,POLICY_UPGRADED,RESOURCE_POOL_LIMIT,RUNBOOK_DIAGNOSTIC_SESSION_END,RUNBOOK_DIAGNOSTIC_SESSION_FAILED,RUNBOOK_DIAGNOSTIC_SESSION_STARTED,RUN_LOCAL_SCRIPT_ACTION_END,RUN_LOCAL_SCRIPT_ACTION_FAILED,RUN_LOCAL_SCRIPT_ACTION_STARTED,SERVICE_ENDPOINT_DISCOVERED,SLOW,SMS_SENT,STALL,SYSTEM_LOG,THREAD_DUMP_ACTION_END,THREAD_DUMP_ACTION_FAILED,THREAD_DUMP_ACTION_STARTED,TIER_DISCOVERED,VERY_SLOW,WARROOM_NOTE"
    fi;
    PREV="${ARG}"
    ARGS+=("${ARG}")
  done;
  apiCall '/controller/rest/applications/{{a}}/events?time-range-type={{t}}&duration-in-mins={{d?}}&start-time={{b?}}&end-time={{f?}}&event-types={{e}}&severities={{s}}' "${ARGS[@]}"
}
register event_list List all events for a given time range.
describe event_list << EOF
List all events for a given time range.
EOF
example event_list << EOF
-a 15 -t BEFORE_NOW -d 60 -s ALL -e ALL
EOF
recursiveSource() {
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
# Helper function to expand multiple files that are provided as payload
apiCallExpand() {
  debug "Calling apiCallExpand"
  local COUNTER=0
  local PREFIX=""
  local SUFFIX=""
  local LIST=""
  declare -i COUNTER
  for ARG in $*; do
    if [ "${COUNTER}" -gt "0" ]; then
      SUFFIX="${SUFFIX} ${ARG}"
    elif [ "${ARG:0:1}" = "@" ] && [ "${ARG:1}" != "$(echo ${ARG:1})" ] ; then
      LIST=$(echo ${ARG:1})
      COUNTER=${COUNTER}+1
    else
      PREFIX="${PREFIX} ${ARG}"
    fi;
  done;
  case "${COUNTER}" in
    "0")
      debug "apiCallExpand: No expansion"
      apiCall "$@"
    ;;
    "1")
      debug "apiCallExpand: With expansion"
      local COMBINED_RESULT=""
      for ELEMENT in ${LIST}; do
        apiCall ${PREFIX} @${ELEMENT} ${SUFFIX}
        COMBINED_RESULT="${COMBINED_RESULT}${EOL}${COMMAND_RESULT}"
        COMMAND_RESULT=""
      done;
      COMMAND_RESULT=${COMBINED_RESULT}
    ;;
    *)
      error "You can only provide one file list for expansion."
      COMMAND_RESULT=""
    ;;
  esac
}
apiCall() {
  local OPTS
  local OPTIONAL_OPTIONS=""
  local OPTS_TYPES=()
  local METHOD="GET"
  local WITH_FORM=0
  local PAYLOAD
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
        PAYLOAD=${OPTARG}
        WITH_FORM=1
      ;;
    esac
  done
  shiftOptInd
  shift $SHIFTS
  ENDPOINT=$1
  debug "Unparsed endpoint is $ENDPOINT"
  debug "Unparsed payload is $PAYLOAD"
  shift
  ## Special replacements for {{controller_account}} and {{controller_url}}
  ## (This is currently used by federation_establish)
  local ACCOUNT=${CONFIG_CONTROLLER_CREDENTIALS##*@}
  ACCOUNT=${ACCOUNT%%:*}
  local ACCOUNT_PATTERN="{{controller_account}}"
  local CONTROLLER_URL_PATTERN="{{controller_url}}"
  PAYLOAD=${PAYLOAD//${ACCOUNT_PATTERN}/${ACCOUNT}}
  PAYLOAD=${PAYLOAD//${CONTROLLER_URL_PATTERN}/${CONFIG_CONTROLLER_HOST}}
  OLDIFS=$IFS
  IFS="{{"
  for MATCH in $PAYLOAD ; do
    if [[ $MATCH =~ ([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      OPTS_TYPES+=(${BASH_REMATCH[1]}${BASH_REMATCH[2]})
      if [ "${BASH_REMATCH[3]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;
  for MATCH in $ENDPOINT ; do
    if [[ $MATCH =~ ([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      OPTS_TYPES+=(${BASH_REMATCH[1]}${BASH_REMATCH[2]})
      if [ "${BASH_REMATCH[3]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;
  IFS=$OLDIFS
  debug "Identified Options: ${OPTS}"
  debug "Identified Types: ${OPTS_TYPES[*]}"
  debug "Optional Options: $OPTIONAL_OPTIONS"
  if [ -n "$OPTS" ] ; then
    while getopts ${OPTS} opt;
    do
      local ARG=`urlencode "$OPTARG"`
      debug "Applying $opt with $ARG"
      # PAYLOAD=${PAYLOAD//\$\{${opt}\}/$OPTARG}
      # ENDPOINT=${ENDPOINT//\$\{${opt}\}/$OPTARG}
      while [[ $PAYLOAD =~ \{\{$opt(:[a-zA-Z0-9_-]+)?\??\}\} ]] ; do
        PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$OPTARG}
      done;
      while [[ $ENDPOINT =~ \{\{$opt(:[a-zA-Z0-9_-]+)?\??\}\} ]] ; do
        ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$ARG}
      done;
    done
    shiftOptInd
    shift $SHIFTS
  fi
  while [[ $PAYLOAD =~ \{\{([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      if [ "${MISSING}" == "a" ] && [ -n "${CONFIG_CONTROLLER_DEFAULT_APPLICATION}" ] ; then
        ENDPOINT=${ENDPOINT//'{{a}}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
      else
        error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
        return;
      fi
    fi
    PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$1}
    shift
  done
  while [[ $ENDPOINT =~ \{\{([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      ERROR_MESSAGE="Please provide an argument for parameter -${MISSING}"
      for TYPE in "${OPTS_TYPES[@]}" ;
      do
        if [[ "${TYPE}" == ${MISSING}:* ]] ; then
          TYPE=${TYPE//_/ }
          TYPE=${TYPE#*:}
          if [[ "${TYPE}" == "application" ]] ; then
            debug "Using default application for -a: ${CONFIG_CONTROLLER_DEFAULT_APPLICATION}"
            ENDPOINT=${ENDPOINT//'{{a:application}}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
            ERROR_MESSAGE=""
          elif [[ "${TYPE}" == "accountid" ]] ; then
            debug "Querying myaccount..."
            JSON=$(httpClient -s --user "${CONFIG_CONTROLLER_CREDENTIALS}" "${CONFIG_CONTROLLER_HOST}/controller/api/accounts/myaccount")
            JSON=${JSON// /}
            JSON=${JSON##*id\":\"}
            ACCOUNT_ID=${JSON%%\",*}
            debug "Account ID: ${ACCOUNT_ID}"
            COMMAND_RESULT=""
            debug ${ENDPOINT}
            ENDPOINT=${ENDPOINT//'{{i:accountid}}'/${ACCOUNT_ID}}
            debug ${ENDPOINT}
            ERROR_MESSAGE=""
          else
            ERROR_MESSAGE="Missing ${TYPE}: ${ERROR_MESSAGE}"
          fi;
        fi
      done;
      if [ -n "${ERROR_MESSAGE}" ] ; then
        error "${ERROR_MESSAGE}"
        return;
      fi
    fi
    local ARG=`urlencode "$1"`
    debug "Applying ${BASH_REMATCH[0]} with $ARG"
    ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$ARG}
    shift
  done
  local CONTROLLER_ARGS=()
  if [[ "${ENDPOINT}" == */controller/rest/* ]] || [[ "${ENDPOINT}" == */controller/transactiondetection/* ]] || [[ "${ENDPOINT}" == */mds/v1/license/* ]] ; then
    CONTROLLER_ARGS+=("-B")
    debug "Using basic http authentication"
  fi;
  if [ -n "${PAYLOAD}" ] ; then
    if [ "${PAYLOAD:0:1}" = "@" ] ; then
      debug "Loading payload from file ${PAYLOAD:1}"
      if [ -r "${PAYLOAD:1}" ] ; then
        PAYLOAD=$(<${PAYLOAD:1})
      else
        COMMAND_RESULT=""
        error "File not found or not readable: ${PAYLOAD:1}"
        exit
      fi
    fi
  fi;
  debug "With form: ${WITH_FORM}"
  if [ "${WITH_FORM}" -eq 1 ] ; then
    CONTROLLER_ARGS+=("-F" "${PAYLOAD}")
  else
    CONTROLLER_ARGS+=("-d" "${PAYLOAD}")
  fi
  CONTROLLER_ARGS+=("-X" "${METHOD}" "${ENDPOINT}")
  debug "Call Controller with ${CONTROLLER_ARGS[*]}"
  controller_call "${CONTROLLER_ARGS[@]}"
}
SHIFTS=0
declare -i SHIFTS
shiftOptInd() {
  SHIFTS=$OPTIND
  SHIFTS=${SHIFTS}-1
  OPTIND=0
  return $SHIFTS
}
debug() {
  if [ "${CONFIG_OUTPUT_VERBOSITY/debug}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_DEBUG}DEBUG: $*${COLOR_RESET}"
  fi
}
error() {
  if [ "${CONFIG_OUTPUT_VERBOSITY/error}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_ERROR}ERROR: $*${COLOR_RESET}"
  fi
}
warning() {
  if [ "${CONFIG_OUTPUT_VERBOSITY/warning}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_WARNING}WARNING: $*${COLOR_RESET}"
  fi
}
info() {
  if [ "${CONFIG_OUTPUT_VERBOSITY/info}" != "$CONFIG_OUTPUT_VERBOSITY" ]; then
    echo -e "${COLOR_INFO}INFO: $*${COLOR_RESET}"
  fi
}
output() {
  if [ "${CONFIG_OUTPUT_VERBOSITY}" != "" ]; then
    echo -e "$*"
  fi
}
# from https://gist.github.com/cdown/1163649
urlencode() {
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
# Source: https://github.com/dylanaraps/pure-bash-bible#get-the-base-name-of-a-file-path
bashBasename() {
    # Usage: basename "path"
    : "${1%/}"
    printf '%s\n' "${_##*/}"
}
httpClient() {
 local TIMEOUT=10
 if [ -n "$CONFIG_HTTP_TIMEOUT" ] ; then
   TIMEOUT=$CONFIG_HTTP_TIMEOUT
 fi
 debug "curl -L --connect-timeout ${TIMEOUT} $*"
 curl -L --connect-timeout ${TIMEOUT} "$@"
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
USAGE_DESCRIPTION="$SCRIPTNAME [-H <controller-host>] [-C <controller-credentials>] [-D <output-verbosity>] [-E <environment>] [-J <cookie-location>] [-P <plugin-directory>] [-F <controller-info-xml>] [-A <application-name>] [-O] [-N] [-Q] [-v[vv]] <namespace> <command>"
read -r -d '' AVAILABLE_GLOBAL_OPTIONS <<- EOM
|-H <controller-host>          |specify the host of the controller you want to connect to|
|-C <controller-credentials>   |provide the credentials for the controller. Format: user@tenant:password|
|-D <output-verbosity>         |Change the output verbosity. Provide a list of the following values: debug,error,warn,info,output|
|-E <environment>              |Call the controller within the given environment|
|-A <application-name>         |Provide a default application.|
|-J <cookie-location>          |Store the session cookie at a different location.|
|-F <controller-info-xml>      |Read the controller credentials from a given controller-info.xml|
|-O                            |Don't execute the command and just print the curl call.|
|-N                            |Don't use colors for the verbose output.|
|-Q                            |If possible set the output format to JSON.|
|-v[vv]                        |Increase application verbosity: v = warn, vv = warn,info, vvv = warn,info,debug|
EOM
while getopts "A:H:C:E:J:D:OP:S:F:NQv" opt;
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
    O)
      CONFIG_OUTPUT_COMMAND=1
      debug "Set CONFIG_OUTPUT_COMMAND=${CONFIG_OUTPUT_COMMAND}"
    ;;
    Q)
      CONFIG_OUTPUT_FORMAT="JSON"
      debug "Set CONFIG_OUTPUT_FORMAT=${CONFIG_OUTPUT_FORMAT}"
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
if [ "$#" -eq 0 ] ; then
  _usage
# Check if the namespace is used
elif [ "${GLOBAL_COMMANDS/${NAMESPACE}_}" != "$GLOBAL_COMMANDS" ] ; then
  debug "${NAMESPACE} has commands"
  COMMAND=$2
  if [ "$COMMAND" == "" ] || [ "$COMMAND" == "help" ] ; then
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
printf '%s\n' "$COMMAND_RESULT"
debug END
