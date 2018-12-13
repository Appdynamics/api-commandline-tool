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

These commands allow you to import and export email/http action templates.
A common use pattern is exporting the commands from one controller and importing
into another. Please note that the export is a list of templates and the import
expects a single object, so you need to split the json inbetween.

| Command | Description | Example |
| ------- | ----------- | ------- |
| createmediatype | Create a custom media type. Provide the name of the media type as parameter (-n) | `act.sh actiontemplate createmediatype -n 'application/vnd.appd.events+json'` |
| import | Import an action template of a given type (email, httprequest) | `act.sh actiontemplate import template.json` |
| export | Export all templates of a given type (-t email or httprequest) | `act.sh actiontemplate export -t httprequest` |


## analyticssearch

These commands allow you to import and export email/http saved analytics searches.

| Command | Description | Example |
| ------- | ----------- | ------- |
| get | Get an analytics search by id. Provide the id as parameter (-i) | `act.sh analyticssearch get -i 6` |
| import | Import an analytics search. Provide a json file as parameter. | `act.sh analyticssearch import search.json` |
| list | List all analytics searches available on the controller. This command requires no further arguments. | `act.sh analyticssearch list ` |


## application

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | Retrieve a list of snapshots for a specific application. |  |
| get | Get an application. Provide application id or name as parameter (-a). |  |
| delete | Delete an application. Provide application id as parameter. |  |
| create | Create a new application. Provide a name and a type (APM or WEB) as parameter. |  |
| list | List all applications available on the controller. This command requires no further arguments. |  |
| export | Export a application from the controller. Specifiy the application id as parameter. |  |


## bizjourney

| Command | Description | Example |
| ------- | ----------- | ------- |
| disable | Disable a valid business journey draft. Provide the journey id (-i) as parameter |  |
| enable | Enable a valid business journey draft. Provide the journey id (-i) as parameter |  |
| import | Create a new business journey. Provide a name and a type (APM or WEB) as parameter. |  |
| list | List all business journeys. This command requires no further arguments. |  |


## bt

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | List all business transactions for a given application. Provide the application id as parameter. |  |
| get | Get an BT. Provide as parameters bt id (-b) and application id (-a). |  |


## configuration

| Command | Description | Example |
| ------- | ----------- | ------- |
| set | Set a Controller setting to a specified value. Provide a name (-n) and a value (-v) as parameters |  |
| get | Retrieve a Controller Setting by Name. Provide a name (-n) as parameter |  |
| list | Retrieve All Controller Settings |  |


## controller

| Command | Description | Example |
| ------- | ----------- | ------- |
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
| list | List all database collectors | `act.sh dbmon list ` |
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

| Command | Description | Example |
| ------- | ----------- | ------- |
| import | Import a health rule. |  |
| list | List all health rules. Provide parameter a for the application and parameter. |  |
| export | Export a health rule. Provide parameter a for the application and parameter n for the name of the health rule. If you want to export all healthrules use the "list" command |  |
| list | Copy healthrules from one application to another. Provide the source application id ("-s") and the target application ("-t")."<br>"/If you provide ("-n") only the named health rule will be copied. |  |


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


## portal

| Command | Description | Example |
| ------- | ----------- | ------- |
| login | Login to portal.appdynamics.com |  |
| download | Download an appdynamics agent |  |


## server

| Command | Description | Example |
| ------- | ----------- | ------- |
| list | List all servers |  |


## tier

| Command | Description | Example |
| ------- | ----------- | ------- |
| nodes | Retrieve Node Information for All Nodes in a Tier. Provide the application and the tier as parameters |  |
| get | Retrieve Tier Information by Tier Name. Provide the application and the tier as parameters |  |
| list | List all tiers for a given application. Provide the application id as parameter. |  |


## timerange

| Command | Description | Example |
| ------- | ----------- | ------- |
| delete | Delete a specific time range by id |  |
| create | Create a custom time range |  |
| list | List all custom timeranges available on the controller |  |

