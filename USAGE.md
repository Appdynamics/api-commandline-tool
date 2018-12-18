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
|-v[vv]                        |Increase application verbosity: v = warn, vv = warn,info, vvv = warn,info,debug|


## Global

The following commands in the global namespace can be called directly.

| Command | Description | Example |
| ------- | ----------- | ------- |
| config | Initialize the default environment. This is an alias for `act.sh environment add -d` | `act.sh  config ` |
| version | Print the current version of act.sh | `act.sh  version ` |


## actiontemplate

These commands allow you to import and export email/http action templates. A common use pattern is exporting the commands from one controller and importing into another. Please note that the export is a list of templates and the import expects a single object, so you need to split the json inbetween.

| Command | Description | Example |
| ------- | ----------- | ------- |
| createmediatype | Create a custom media type. Provide the name of the media type as parameter (-n) | `act.sh actiontemplate createmediatype -n 'application/vnd.appd.events+json'` |
| export | Export all templates of a given type. Provide the type (-t email or httprequest) as parameter. | `act.sh actiontemplate export -t httprequest` |
| delete | Delete an action template. Provide an id (-i) and a type (-t) as parameters. |  |
| import | Import an action template of a given type (email, httprequest) | `act.sh actiontemplate import template.json` |
| list | List all actiontemplates. Provide a type (-t) as parameter. |  |


## analyticssearch

These commands allow you to import and export email/http saved analytics searches.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get an analytics search by id. Provide the id as parameter (-i) | `act.sh analyticssearch get -i 6` |
| import | Import an analytics search. Provide a json file as parameter. | `act.sh analyticssearch import search.json` |
| list | List all analytics searches available on the controller. This command requires no further arguments. | `act.sh analyticssearch list ` |


## application

The applications API lets you retrieve information about the monitored environment as modeled in AppDynamics.

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a new application. Provide a name and a type (APM or WEB) as parameter. | `act.sh application create -t APM -n MyNewApplication` |
| delete | Delete an application. Provide an application id as parameter (-a) | `act.sh application delete -a 29` |
| export | Export an application from the controller. Provide an application id as parameter (-a) | `act.sh application export -a 29` |
| get | Get an application. Provide application id or name as parameter (-a). | `act.sh application get -a 15` |
| list | List all applications available on the controller This command requires no further arguments. | `act.sh application list ` |


## audit

he Controller audit history is a record of the configuration and user activities in the Controller configuration.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Retrieve Controller Audit History. Provide a start time (-b) and an end time (-f) as parameter. | `act.sh audit get -b 2015-12-19T10:50:03.607-700 -f 2015-12-19T17:50:03.607-0700` |


## bizjourney

| Command | Description | Example |
| ------- | ----------- | ------- |
| disable | Disable a valid business journey draft. Provide the journey id (-i) as parameter |  |
| enable | Enable a valid business journey draft. Provide the journey id (-i) as parameter |  |
| import | Import a business journey. Provide a json string or a file (with @ as prefix) as paramater (-d) |  |
| list | List all business journeys. This command requires no further arguments. |  |


## bt

Retrieve information about business transactions within a given business application

| Command | Description | Example |
| ------- | ----------- | ------- |
| creategroup | Create a business transactions group. Provide the application id (-a), name (-n) and a comma separeted list of bt ids (-b) | `act.sh bt creategroup -b 13,14 -n MyGroup` |
| delete | Delete a business transaction. Provide the bt id as parameter (-b) | `act.sh bt delete -b 13` |
| get | Get a BT. Provide as parameters bt id (-b) and application id (-a). | `act.sh bt get -a 29 -b 13` |
| list | List all BTs for a given application. Provide the application id as parameter (-a) | `act.sh bt list -a 29` |
| rename | Rename a business transaction. Provide the bt id (-b) and the new name (-n) as parameters | `act.sh bt rename -b 13 -n Checkout` |


## configuration

The configuration API enables you read and modify selected Controller configuration settings programmatically.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Retrieve a Controller Setting by Name. Provide a name (-n) as parameter. | `act.sh configuration get -n metrics.min.retention.period` |
| list | Retrieve All Controller Settings The Controller global configuration values are made up of the Controller settings that are presented in the Administration Console. | `act.sh configuration list ` |
| set | Set a Controller setting to a specified value. Set a Controller setting to a specified value. Provide a name (-n) and a value (-v) as parameters | `act.sh configuration set -n metrics.min.retention.period -v 550` |


## controller

Basic calls against an AppDynamics controller.

| Command | Description | Example |
| ------- | ----------- | ------- |
| auth | Authenticate Authenticate with an AppDynamics controller | `act.sh controller auth ` |
| isup | This command will pause until the controller is up. Use this to get notified after the controller is booted successfully. |  |
| call | Send a custom HTTP call to an AppDynamics controller. Provide the endpoint you want to call as parameter. You can modify the http method with option -X and add payload with option -d. | `act.sh controller call /controller/rest/serverstatus` |
| login | Check if the login with your appdynamics controller works properly."<br>"/If the login fails, use doc controller ping to check if the controller is running and check your credentials if they are correct. |  |
| ping | Check the availability of an appdynamics controller. On success the response time will be provided. |  |
| status | This command will return a XML containing status information about the controller. |  |
| version | Get installed version from controller |  |


## dashboard

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete a specific dashboard |  |
| update | Update a specific dashboard. Please not that the json you need to provide is not compatible with the export format! |  |
| import | Import a dashboard from a given file |  |
| list | List all dashboards available on the controller |  |
| export | Export a specific dashboard |  |


## dbmon

Use the Database Visibility API to get, create, update, and delete Database Visibility Collectors.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Retrieve information about a specific database collector. Provide the collector id as parameter (-c). | `act.sh dbmon get -c 17` |
| delete | Delete a database collector. Provide the collector id as parameter (-c). | `act.sh dbmon delete -c 17` |
| import | Create a new database collector. Provide a valid json file as parameter. | `act.sh dbmon import dbmon.json` |
| create | Create a new database collector. You need to provide the following parameters:"<br>"/  -i name"<br>"/  -u user name"<br>"/  -h host name"<br>"/  -a agent name"<br>"/  -t type"<br>"/  -d database name"<br>"/  -p port"<br>"/  -s password | `act.sh dbmon create -i MyTestDB -h localhost -n db -u user -a "Default Database Agent" -t DB2 -p 1555 -s password` |
| list | List all database collectors. No further arguments required. | `act.sh dbmon list ` |
| events | List all database agent events. This is an alias for `act.sh event list -a '_dbmon'`, so you can use the same parameters for querying the events. | `act.sh dbmon events -t BEFORE_NOW -d 60 -s INFO,WARN,ERROR -e AGENT_EVENT` |


## environment

If you want to use act.sh to manage multiple controllers, you can use environments to add and manage them easily.
Use `act.sh environment add` to create an environment providing a name, controller url and credentials.
Afterwards you can use `act.sh -E <name>` to call the given controller.

| Command | Description | Example |
| ------- | ----------- | ------- |
| source | Load environment variables |  |
| get | Retrieve an environment. Provide the name of the environment as parameter. | `act.sh environment get myaccount` |
| delete | Delete an environment. Provide the name of the environment as parameter. | `act.sh environment delete myaccount` |
| add | Add a new environment. To change the default environment, run with `-d` | `act.sh environment add -d` |
| list | List all your environments | `act.sh environment list ` |
| export | Export an environment into a postman environment | `act.sh environment export > output.json` |


## eum

| Command | Description | Example |
| ------- | ----------- | ------- |
| getapps | Get EUM Apps. |  |


## event

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a custom event for a given application. Application, summary, event type and severity are required parameters. |  |
| list | List all events for a given time range. | `act.sh event list -a 15 -t BEFORE_NOW -d 60 -s ALL -e ALL` |


## federation

| Command | Description | Example |
| ------- | ----------- | ------- |
| setup | Setup a controller federation: Generates a key and establishes the mutal friendship. |  |
| createkey | Create API Key for Federation. |  |
| establish | Establish Mutual Friendship |  |


## healthrule

Configure and retrieve health rules and their violates.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get a specifc healthrule. Provide an application (-a) and a health rule name (-n) as parameters. | `act.sh healthrule get -a 29` |
| list | List all healthrules. Provide an application (-a) as parameter | `act.sh healthrule list -a 29` |
| violations | Get healthrule violations. Provide an application (-a) and a time range type (-t) as parameters, as well as a duration in minutes (-d) or a start-time (-b) and an end time (-f) | `act.sh healthrule violations -a 29 -t BEFORE_NOW -d 120` |
| import | Import a health rule. |  |
| list | Copy healthrules from one application to another. Provide the source application id ("-s") and the target application ("-t")."<br>"/If you provide ("-n") only the named health rule will be copied. | `act.sh healthrule list -a 29` |


## metric

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get a specific metric by providing the metric path. Provide the application with option -a |  |
| tree | Create a metric tree for the given application (-a). Note that this will create a lot of requests towards your controller. |  |
| list | List all metrics available for one application (-a). Provide a metric path like "Overall Application Performance" to walk the metrics tree. |  |


## node

| Command | Description | Example |
| ------- | ----------- | ------- |
| markhistorical | Mark Nodes as Historical. Provide a comma separated list of node ids. |  |
| get | Retrieve Node Information by Node Name. Provide the application and the node as parameters |  |
| list | Retrieve Node Information for All Nodes in a Business Application. Provide the application as parameter. |  |


## policies

Import and export policies

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | List all policies. Provide an application (-a) as parameter. | `act.sh policies list -a 29` |


## portal

| Command | Description | Example |
| ------- | ----------- | ------- |
| login | Login to portal.appdynamics.com |  |
| download | Download an appdynamics agent |  |


## server

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | List all servers |  |


## snapshot

Retrieve APM snapshots

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | Retrieve a list of snapshots Provide an application (-a) as parameter, as well es a time range (-t), the duration in minutes (-d) or start (-b) and end time (-f) | `act.sh snapshot list -a 29 -t BEFORE_NOW -d 120` |


## tier

Retrieve tiers within a business application

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Retrieve Tier Information by Tier Name Provide the application (-a) and the tier (-t) as parameters | `act.sh tier get -a 29 -t 45` |
| list | List all tiers for a given application. Provide the application id as parameter (-a). | `act.sh tier list -a 29` |
| nodes | Retrieve Node Information for All Nodes in a Tier Provide the application (-a) and the tier (-t) as parameters | `act.sh tier nodes -a 29 -t 45` |


## timerange

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete a specific time range by id |  |
| create | Create a custom time range |  |
| list | List all custom timeranges available on the controller |  |


## user

Create and Modify AppDynamics Users.

| Command | Description | Example |
| ------- | ----------- | ------- |
| create | Create a new user Provide a name (-n), a display name (-d), a list of roles (-r), a password (-p) and a mail address (-m) as parameters. | `act.sh user create ` |
| update | Update an existing user Provide an id (-i), name (-n), a display name (-d), a list of roles (-r), a password (-p) and a mail address (-m) as parameters. | `act.sh user update ` |

