# Usage
Below you will find a list of all available namespaces and commands available with
`act.sh`. The given examples allow you to understand, how each command is used.
For more complex examples, have a look into [RECIPES.md](RECIPES.md)
## Options
The following options are available on a global level. Put them in front of your command (e.g. `act.sh -E testenv -vvv application list`):

| Option | Description |
|--------|-------------|
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

## Global

The following commands in the global namespace can be called directly.

| Command | Description | Example |
| ------- | ----------- | ------- |
| config | Initialize the default environment. This is an alias for `act.sh environment add -d` | `act.sh  config ` |
| version | Print the current version of act.sh | `act.sh  version ` |


## account

Query the Account API

| Command | Description | Example |
| ------- | ----------- | ------- |
| my | Get details about the current account This command requires no further arguments. | `act.sh account my ` |


## action

Import or export all actions in the specified application to a JSON file.

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Provide a json string or a file (with @ as prefix) as parameter (-d) | `act.sh action create -d @actions.json` |
| delete | Provide an action id (-i) as parameter. | `act.sh action delete ` |
| export | Export actions. Provide an application id or name as parameter (-a). | `act.sh action export -a 15` |
| import | Import actions. Provide an application id or name as parameter (-a) and a json string or a file (with @ as prefix) as parameter (-d) | `act.sh action import -a 15 -d @actions.json` |
| list | List actions. Provide an application id or name as parameter (-a). | `act.sh action list -a 15` |


## actiontemplate

These commands allow you to import and export email/http action templates. A common use pattern is exporting the commands from one controller and importing into another. Please note that the export is a list of templates and the import expects a single object, so you need to split the json inbetween.

| Command | Description | Example |
| ------- | ----------- | ------- |
| createmediatype | Create a custom media type. Provide the name of the media type as parameter (-n) | `act.sh actiontemplate createmediatype -n 'application/vnd.appd.events+json'` |
| export | Export all templates of a given type. Provide the type (-t email or httprequest) as parameter. | `act.sh actiontemplate export -t httprequest` |
| exportHttpActionPlanList | Export the Http Action Plan List This command requires no further arguments. | `act.sh actiontemplate exportHttpActionPlanList ` |
| delete | Delete an action template. Provide an id (-i) and a type (-t) as parameters. |  |
| import | Import an action template of a given type (email, httprequest) | `act.sh actiontemplate import template.json` |
| list | List all actiontemplates. Provide a type (-t) as parameter. |  |


## adql

These commands allow you to run ADQL queries agains the controller (not the event service!)

| Command | Description | Example |
| ------- | ----------- | ------- |
| query | Run an ADQL query Provide an adql query (-q), a start time (-s) and an end time (-e) as parameters. Remember to escape double quotes in the query. | `act.sh adql query -q 'SELECT eventTimestamp FROM transactions LIMIT 1' -s 2022-06-05T00:00:00.000Z -e 2022-06-16T06:00:00.000Z` |


## agents

List, Reset, Disable AppDynamics Agents

| Command | Description | Example |
| ------- | ----------- | ------- |
| disable | Disable an app agent by id Provide an agent id (-i) and the disableMonitoring (-m) flag (true/false) as parameter. | `act.sh agents disable -i 15 -m true` |
| enable | Enable an app agent by id Provide an agent id (-i) as parameter. | `act.sh agents enable -i 15` |
| ids | Get more details on agents of a specific type by providing their ids Provide a type as parameter (-t) and a comma separated list of ids (-i). Possible types are appserver, machine, cluster. | `act.sh agents ids -t appserver -i 1,2,3` |
| list | List all agents of a specific type Provide a type as parameter (-t). Possible types are appserver, machine, cluster. | `act.sh agents list ` |
| toggleMachineAgent | Enable or Disable an machine agent by id Provide an agent id (-i) and the enabled (-m) flag (true/false) as parameter. | `act.sh agents toggleMachineAgent -i 15 -m false` |


## alertingtemplate

These commands allow you to list, import and export action templates.

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete an alerting template Provide the id of the alerting template (-a) as parameter. | `act.sh alertingtemplate delete -i 68` |
| export | Export an alerting template Provide the id of the alerting template (-a) as parameter. | `act.sh alertingtemplate export -i 68` |
| import | Import an alerting template Provide a json string or a file (with @ as prefix) as parameter (-d). | `act.sh alertingtemplate import -d examples/alertingTemplate.json` |
| list | List all alerting templates This command requires no further arguments. | `act.sh alertingtemplate list ` |


## analyticsmetric

Manage custom analytics metrics

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create analytics metric Provide an adql query (-q) and an event type (-e BROWSER_RECORD, BIZ_TXN) and a name (-n) as parameters. The description (-d) is optional. | `act.sh analyticsmetric create -q 'SELECT count(*) FROM browser_records' -e BROWSER_RECORD -n 'My Custom Metric'` |


## analyticsschema

These commands allow you to manage analytics schemas.

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | List all analytics schemas. This command requires no further arguments | `act.sh analyticsschema list ` |


## analyticssearch

These commands allow you to import and export email/http saved analytics searches.

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete an analytics search by id. Provide the id as parameter (-i). | `act.sh analyticssearch delete -i 6` |
| get | Get an analytics search by id. Provide the id as parameter (-i). | `act.sh analyticssearch get -i 6` |
| import | Import an analytics search. Provide a json string or a file (with @ as prefix) as parameter (-d). | `act.sh analyticssearch import -d search.json` |
| list | List all analytics searches. This command requires no further arguments. | `act.sh analyticssearch list ` |


## application

The applications API lets you retrieve information about the monitored environment as modeled in AppDynamics.

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a new application. Provide a name and a type (APM or WEB) as parameter. | `act.sh application create -t APM -n MyNewApplication` |
| delete | Delete an application. Provide an application id as parameter (-a) | `act.sh application delete -a 29` |
| export | Export an application. Provide an application id as parameter (-a) | `act.sh application export -a 29` |
| get | Get an application. Provide an application id or name as parameter (-a). | `act.sh application get -a 15` |
| list | List all applications. This command requires no further arguments. | `act.sh application list ` |
| listdetails | List application details List application details including health. Provide application ids as parameter (-i), a start and end timestamp (-s and -e). | `act.sh application listdetails -i 9326,8914 -s 1610389435 -e 1620389435` |


## audit

The Controller audit history is a record of the configuration and user activities in the Controller configuration.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get audit history. Provide a start time (-b) and an end time (-f) as parameter. | `act.sh audit get -b 2015-12-19T10:50:03.607-700 -f 2015-12-19T17:50:03.607-0700` |


## backend

Retrieve information about backends within a given business application

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | List all backends. Provide the application id as parameter (-a) | `act.sh backend list -a 29` |


## bizjourney

Manage business journeys in AppDynamics Analytics

| Command | Description | Example |
| ------- | ----------- | ------- |
| disable | Disable a business journey. Provide the journey id (-i) as parameter. | `act.sh bizjourney disable -i 6` |
| enable | Enable a business journey. Provide the journey id (-i) as parameter. | `act.sh bizjourney enable -i 6` |
| import | Import a business journey. Provide a json string or a file (with @ as prefix) as parameter (-d) | `act.sh bizjourney import -d @journey.json` |
| list | List all business journeys. This command requires no further arguments. | `act.sh bizjourney list ` |


## bt

Retrieve information about business transactions within a given business application

| Command | Description | Example |
| ------- | ----------- | ------- |
| creategroup | Create a BT group. Provide the application id (-a), name (-n) and a comma separeted list of bt ids (-b) | `act.sh bt creategroup -b 13,14 -n MyGroup` |
| delete | Delete a BT. Provide the bt id as parameter (-b) | `act.sh bt delete -b 13` |
| get | Get a BT. Provide as parameters bt id (-b) and application id (-a). | `act.sh bt get -a 29 -b 13` |
| list | List all BTs. Provide the application id as parameter (-a) | `act.sh bt list -a 29` |
| overflowtraffic | Get the overflow traffic for a given component. Provide a component id (-c) and a duration in minutes for a time range (-d) as parameters. | `act.sh bt overflowtraffic ` |
| rename | Rename a BT. Provide the bt id (-b) and the new name (-n) as parameters | `act.sh bt rename -b 13 -n Checkout` |


## configuration

The configuration API enables you read and modify selected Controller configuration settings programmatically.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get a controller setting by name. Provide a name (-n) as parameter. | `act.sh configuration get -n metrics.min.retention.period` |
| list | List all controller settings The Controller global configuration values are made up of the Controller settings that are presented in the Administration Console. | `act.sh configuration list ` |
| set | Set a controller setting. Set a Controller setting to a specified value. Provide a name (-n) and a value (-v) as parameters | `act.sh configuration set -n metrics.min.retention.period -v 550` |


## controller

Basic calls against an AppDynamics controller.

| Command | Description | Example |
| ------- | ----------- | ------- |
| auth | Authenticate. | `act.sh controller auth ` |
| status | Get the server status. This command will return a XML containing status information about the controller. | `act.sh controller status ` |
| isup | This command will pause until the controller is up. Use this to get notified after the controller is booted successfully. | `act.sh controller isup ; act.sh application list` |
| call | Send a custom HTTP call to an AppDynamics controller. Provide the endpoint you want to call as parameter. You can modify the http method with option -X and add payload with option -d. | `act.sh controller call /controller/rest/serverstatus` |
| login | Check if the login with your appdynamics controller works properly. If the login fails, use `act.sh controller ping` to check if the controller is running and check your credentials if they are correct. | `act.sh controller login ` |
| ping | Check the availability of an appdynamics controller. On success the response time will be provided. | `act.sh controller ping ` |
| version | Get installed version from controller | `act.sh controller version ` |


## dashboard

Import and export custom dashboards in the AppDynamics controller

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete a dashboard. Provide a dashboard id (-i) as parameter | `act.sh dashboard delete -i 2` |
| export | Export a dashboard. Provide a dashboard id (-i) as parameter | `act.sh dashboard export -i 2` |
| get | Get a dashboard. Provide a dashboard id (-i) as parameter. | `act.sh dashboard get -i 2` |
| import | Import a dashboard. Provide a dashboard file or json (-d) as parameter. | `act.sh dashboard import -d @examples/dashboard.json` |
| list | List all dashboards. This command requires no further arguments. | `act.sh dashboard list ` |
| update | Update a dashboard. Provide a dashboard file or json (-d) as parameter. Use the dashboard get command to retrieve the correct format for updating. | `act.sh dashboard update -d @dashboardUpdate.json` |


## dbmon

Use the Database Visibility API to get, create, update, and delete Database Visibility Collectors.

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete multiple collectors. Provide a comma seperated list of collector analyticsSavedSearches | `act.sh dbmon delete -c 17,18` |
| get | Get a specifc collector. Provide the collector id as parameter (-c). | `act.sh dbmon get -c 17` |
| import | Import a collector. Provide a json string or a @file (-d) as parameter. | `act.sh dbmon import -d @collector.json` |
| list | List all collectors. No further arguments required. | `act.sh dbmon list ` |
| queries | Get queries for a server. Requires a server id (-i), a start time (-b) and an end time (-f) as parameters. | `act.sh dbmon queries -i 2 -b 1545237000000 -f 1545238602` |
| servers | List all servers. No further arguments required. | `act.sh dbmon servers ` |
| update | Update a specific collector. Provide a json string or a @file (-d) as parameter. | `act.sh dbmon update -d @collector.json` |
| create | Create a new database collector. You need to provide the following parameters:"<br>"/  -i name"<br>"/  -u user name"<br>"/  -h host name"<br>"/  -a agent name"<br>"/  -t type"<br>"/  -d database name"<br>"/  -p port"<br>"/  -s password | `act.sh dbmon create -i MyTestDB -h localhost -n db -u user -a "Default Database Agent" -t DB2 -p 1555 -s password` |
| events | List all database agent events. This is an alias for `act.sh event list -a '_dbmon'`, so you can use the same parameters for querying the events. | `act.sh dbmon events -t BEFORE_NOW -d 60 -s INFO,WARN,ERROR -e AGENT_EVENT` |


## download

| Command | Description | Example |
| ------- | ----------- | ------- |
| login | Login with AppDynamics to retrieve an OAUTH token for downloads. You can use the provided token for downloads from https://download.appdynamics.com/ | `act.sh download login ` |
| get | Download an agent. You need to provide a partial name of an agent you want to download. Optionally, you can provide a directory (-d) as download location. By default only the first match is downloaded, you can provide parameter -a to download all matches. | `act.sh download get -d /tmp golang` |
| list | List agent files. You can provide a filter (-f) to filter for specific agent files. Or you can provide a search query (-s) to execute . Provide parameter -d to get the full download path | `act.sh download list -d -f golang` |
| versionlist |  | `act.sh download versionlist ` |


## environment

If you want to use act.sh to manage multiple controllers, you can use environments to add and manage them easily.
Use `act.sh environment add` to create an environment providing a name, controller url and credentials.
Afterwards you can use `act.sh -E <name>` to call the given controller.

| Command | Description | Example |
| ------- | ----------- | ------- |
| source | Load environment variables | `act.sh environment source myaccount` |
| get | Retrieve an environment. Provide the name of the environment as parameter. | `act.sh environment get myaccount` |
| delete | Delete an environment. Provide the name of the environment as parameter. | `act.sh environment delete myaccount` |
| add | Add a new environment. To change the default environment, run with `-d` | `act.sh environment add -d` |
| list | List all your environments | `act.sh environment list ` |
| export | Export an environment into a postman environment | `act.sh environment export > output.json` |
| edit |  | `act.sh environment edit myaccount` |


## eum

| Command | Description | Example |
| ------- | ----------- | ------- |
| getapps | Get EUM Apps. |  |


## eumCorrelation

Manage correlation cookies for APM and EUM integration

| Command | Description | Example |
| ------- | ----------- | ------- |
| disable | Disable all EUM correlation cookies. | `act.sh eumCorrelation disable -a 41` |


## event

Create and list events in your business applications.

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create an event. Provide an application (-a), a summary (-s), an event type (-e) and a severity level (-l). Optional parameters are bt (-b), node (-n) and tier (-t) | `act.sh event create -l INFO -c 'New bug fix release.' -e APPLICATION_DEPLOYMENT -a 29 -s 'Version 3.1.3'` |
| list | List all events for a given time range. | `act.sh event list -a 15 -t BEFORE_NOW -d 60 -s ALL -e ALL` |


## federation

Establish a federation between two AppDynamics Controllers.

| Command | Description | Example |
| ------- | ----------- | ------- |
| createkey | Create a key. Provide a name for the api key (-n) as parameter. | `act.sh federation createkey -n saas2onprem` |
| establish | Establish a federation Provide an account name (-a), an api key (-k) and a controller url (-c) for the friend account. | `act.sh federation establish -a customer1 -k NGEzNzlhNTctNzQ1Yy00ZWM3LTkzNmItYTVkYmY0NWVkYzZjOjA0Nzk0ZjI5NzU1OWM0Zjk4YzYxN2E0Y2I2ODkwMDMyZjdjMDhhZTY= -c http://localhost:8090` |
| setup | Setup a controller federation: Generates a key and establishes the mutal friendship. |  |


## flowmap

Retrieve flowmaps

| Command | Description | Example |
| ------- | ----------- | ------- |
| application | Get an application flowmap Provide an application (-a) and a time range string (-t) as parameter. | `act.sh flowmap application -a 41 -t last_1_hour.BEFORE_NOW.-1.-1.60` |
| component | Get an component flowmap Provide an component (tier, node, ...) id (-c) and a time range string (-t) as parameter | `act.sh flowmap component -c 108 -t last_1_hour.BEFOREW_NOW.-1.-1.60` |


## healthrule

Configure and retrieve health rules and their violates.

| Command | Description | Example |
| ------- | ----------- | ------- |
| disable | Disable a healthrule. Provide an application (-a) and a health rule id (-i) as parameters. | `act.sh healthrule disable -a 29 -i 54` |
| enable | Enable a healthrule. Provide an application (-a) and a health rule id (-i) as parameters. | `act.sh healthrule enable -a 29 -i 54` |
| get | Get a healthrule. Provide an application (-a) and a health rule name (-n) as parameters. | `act.sh healthrule get -a 29` |
| list | List all healthrules. Provide an application (-a) as parameter | `act.sh healthrule list -a 29` |
| violations | Get all healthrule violations. Provide an application (-a) and a time range type (-t) as parameters, as well as a duration in minutes (-d) or a start-time (-b) and an end time (-f) | `act.sh healthrule violations -a 29 -t BEFORE_NOW -d 120` |
| import | Import a health rule. |  |
| copy | Copy healthrules from one application to another. Provide the source application id ("-s") and the target application ("-t")."<br>"/If you provide ("-n") only the named health rule will be copied. |  |


## informationPoint



| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create an information point. Provide an json file (with @ as prefix) containing the information point config (-d) as parameter. | `act.sh informationPoint create -d @examples/information_point.json` |
| delete | Delete information points. Provide an id or an list of ids of information points (-i) as parameter. | `act.sh informationPoint delete -i 1326,1327` |
| list | List information points. Provide an application id (-a) and a time range string (-t) as parameters. | `act.sh informationPoint list -a 6743 -t last_1_hour.BEFORE_NOW.-1.-1.60` |
| update | Update an information point. Provide an json file (with @ as prefix) containing the information point update config (-d) as parameter. | `act.sh informationPoint update -d @examples/information_point_update.json` |


## licenserule



| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a license rule. Provide a json string or a @file (-d) as parameter. | `act.sh licenserule create -d examples/licenserule.json` |
| detailview | Get detail view for a license rule Provide a license id (-l) as parameter. | `act.sh licenserule detailview -l ff0fb8ff-d2ef-446d-83bd-8f8e5b8c0d20` |
| list | List all license rules. This command requires no further arguments | `act.sh licenserule list ` |


## logsources



| Command | Description | Example |
| ------- | ----------- | ------- |
| import | Import a source rule. Provide a json string or a file (with @ as prefix) as parameter (-d) | `act.sh logsources import -d @examples/logsources.json` |
| list | List all sources. This command requires no further arguments. | `act.sh logsources list ` |


## metric

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get a specific metric by providing the metric path. Provide the application with option -a |  |
| tree | Create a metric tree for the given application (-a). Note that this will create a lot of requests towards your controller. |  |
| list | List all metrics available for one application (-a). Provide a metric path like "Overall Application Performance" to walk the metrics tree. |  |


## mobileCrash

API to list and retrieve mobile crashes

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get crash details Provide an application ID (-a) and crash ID (-c) as parameters | `act.sh mobileCrash get -a 41 -c d65fff8f-6ff0-4765-8ff4-2ffcbd0441bd` |


## node

Retrieve nodes within a business application

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get a node. Provide the application (-a) and the node (-n) as parameters | `act.sh node get -a 29 -n 45` |
| list | List all nodes. Provide the application id as parameter (-a). | `act.sh node list -a 29` |
| markhistorical | Mark nodes as historical. Provide a comma separated list of node ids. | `act.sh node markhistorical -n 45,46` |
| move | Move node. Provide a node id (-n) and a tier id (-t) to move the given node to the given tier. | `act.sh node move -n 1782418 -t 187811` |


## otel

Configure OpenTelemetry collector for AppDynamics

| Command | Description | Example |
| ------- | ----------- | ------- |
| getApiKey | Get OpenTelemetry API Key No parameter required. | `act.sh otel getApiKey ` |
| isEnabled | Check if OpenTelemetry enabled. No parameter required. | `act.sh otel isEnabled ` |


## policy

Import and export policies

| Command | Description | Example |
| ------- | ----------- | ------- |
| export | List all policies. Provide an application (-a) as parameter. | `act.sh policy export -a 29` |
| get | Get a policy. Provide a policy id (-p) as parameter. | `act.sh policy get -p 9886` |
| import | Import a policy. Provide an application (-a) and a policy file or json (-d) as parameter. | `act.sh policy import -a 29 -d @examples/policy.json` |
| update | Update an existing policy. Provide a policy file or json (-d) as parameter. | `act.sh policy update -d @examples/policy.json` |


## sam

Manage service monitoring configurations

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a monitor. This command takes the following arguments. Those with '?' are optional: name (-n), machineId (-i), url (-u), interval (-i), failureThreshold (-f), successThreshold (-s), thresholdWindow (-w), connectTimeout (-c), socketTimeout (-t), method (-m), downloadSize (-d), headers (-h), body (-b), validationRules (-v) | `act.sh sam create -n 'Checkout' -i 42 -u https://www.example.com/checkout -p 10 -f 1 -s 3 -w 5 -c 30000 -t 30000 -m POST -d 5000` |
| delete | Delete a monitor Provide a monitor id (-i) as parameter | `act.sh sam delete -i 29` |
| get | Get a monitor. Provide a monitor id (-i) as parameter | `act.sh sam get -i 29` |
| import | Import a monitor. Provide a json string or a @file (-d) as parameter. | `act.sh sam import -d @examples/sam.json` |
| list | List monitors. This command requires no further arguments. | `act.sh sam list ` |


## scope

Manage scopes for instrumentation

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a new scope. Provide an application id (-a) as parameter | `act.sh scope create ` |
| list | List all scopes. Provide an application id (-a) as parameter | `act.sh scope list -a 25` |


## sep

List service endpoints

| Command | Description | Example |
| ------- | ----------- | ------- |
| config | List all SEP configurations. Provide an application id (-a). | `act.sh sep config -a 29` |
| delete | Delete SEPs Provide an id or an list of ids of service end points (-s) as parameter. | `act.sh sep delete -s 11705717,11705424` |
| list | List all SEPs Provide an application id (-a), a start timestamp (-s) and an end timestamp (-e) as parameters. | `act.sh sep list -a 29 -s 1610389435 -e 1620389435` |
| updateConfig | Insert or Update SEPs. Provide an application id (-a) and a json string or a @file (-d) as parameter. | `act.sh sep updateConfig -a 29 -d @examples/sep.json` |


## server

List servers, their properties and metrics

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete a machine. Provide a machine id (-m) as parameter. | `act.sh server delete -m 244` |
| get | Get a machine. Provide a machine id (-m) as parameter. | `act.sh server get -m 244` |
| list | List all machines. No additional argument required. | `act.sh server list ` |
| query | Query a machineagent by hostname provide a machine name (-m) as parameter | `act.sh server query -m Myserver or if you want to query your own name -m ${HOSTNAME} on Linux` |


## snapshot

List APM snapshots.

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | Retrieve a list of snapshots Provide an application (-a) as parameter, as well as a time range (-t), the duration in minutes (-d) or start (-b) and end time (-f) | `act.sh snapshot list -a 29 -t BEFORE_NOW -d 120` |


## synthetic

Create synthetic snapshots or jobs

| Command | Description | Example |
| ------- | ----------- | ------- |
| import | Import a synthetic job. Provide an EUM application id (-a) as parameter and a json string or a file (with @ as prefix) as parameter (-d) | `act.sh synthetic import -a 41 -d @examples/syntheticjob.json` |
| list | List all synthetic jobs. Provide an EUM application id (-a) as parameter. | `act.sh synthetic list -a 41` |
| snapshot | Generate synthetic snapshot. Provide an EUM application (-a), a brower (-b) and an URL (-u) as parameter. | `act.sh synthetic snapshot -u http://www.appdynmics.com -l AMS -b Chrome -a 128` |
| update | Update a synthetic job. Provide an EUM application id (-a) as parameter and a json string or a file (with @ as prefix) as parameter (-d) | `act.sh synthetic update -a 41 -d @examples/updatesyntheticjob.json` |


## tier

List all tiers.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get a tier. Provide the application (-a) and the tier (-t) as parameters | `act.sh tier get -a 29 -t 45` |
| list | List all tiers for a given application. Provide the application id as parameter (-a). | `act.sh tier list -a 29` |
| nodes | List nodes for a tier. Provide the application (-a) and the tier (-t) as parameters | `act.sh tier nodes -a 29 -t 45` |


## timerange

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete a specific time range by id |  |
| create | Create a custom time range |  |
| list | List all custom timeranges available on the controller |  |


## transactiondetection

Import and export transaction detection rules.

| Command | Description | Example |
| ------- | ----------- | ------- |
| export | Export transaction detection rules. Provide the application (-a) and the rule type (-r) as parameters. Provide an entry point type (-e) as optional parameter. | `act.sh transactiondetection export -a 29 -r custom -e servlet` |
| import | Import transaction detection rules. Provide the application (-a), the rule type (-r) and an xml file (with @ as prefix) containing the rules (-d) as parameters. Provide an entry point type (-e) as optional parameter. | `act.sh transactiondetection import -a 29 -r custom -e servlet -d @rules.xml` |


## user

Create and Modify AppDynamics Users.

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a new user. Provide a name (-n), a display name (-d), a list of roles (-r), a password (-p) and a mail address (-m) as parameters. | `act.sh user create -n myadmin -d Administrator -r Account` |
| update | Update an existing user. Provide an id (-i), name (-n), a display name (-d), a list of roles (-r), a password (-p) and a mail address (-m) as parameters. | `act.sh user update -n myadmin -d Administrator -r Account` |

