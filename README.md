# API Commandline Tool

The [API Commandline Tool](https://github.com/Appdynamics/api-commandline-tool) (ACT) is a shell script wrapper around [API](https://docs.appdynamics.com/display/latest/AppDynamics+APIs#AppDynamicsAPIs-apiindex) calls towards an AppDynamics controller. It allows you to run common commands from your shell, integrate them with other shell commands and automate certain tasks.

ACT is completely bash based, so you don't need to install or compile anything, just download and run it!

If you want to see some examples what ACT can do, before installing it, look into the list of [available commands](USAGE.md) and [available recipes](RECIPES.md)

As a byproduct the tool generates a [postman](https://www.getpostman.com/) compatible [collection of API calls](postman-collection.json). The integration is described at [POSTMAN.md](POSTMAN.md)

## Installation

To use the latest release of ACT just download the raw version of [act.sh](https://github.com/Appdynamics/api-commandline-tool/blob/master/act.sh)

Afterwards run `act.sh config` to provide your controller host and credentials. This will create a configuration file at `~/.appdynamics/act/config.sh`, e.g.:

```bash
CONFIG_CONTROLLER_HOST=https://appdynamics.example.com:8090
CONFIG_CONTROLLER_CREDENTIALS=me@customer1:secure2
CONFIG_CONTROLLER_COOKIE_LOCATION=/home/ubuntu/.appdynamics/act/cookie.txt
```

To update your configuration, you can either edit this file or you can re-run the setup:

```shell
act.sh config -f
```

If you want to work with multiple controllers, you can use [environments](USAGE.md#environment)


## Usage

`act.sh` integrates different commands to interact with your AppDynamics controller. See [USAGE.md](USAGE.md) for a full list of commands or call `act.sh help` from the command line.

A simple work flow example is listing, exporting and deleting a dashboard:

```shell
act.sh dashboard list
act.sh dashboard export 13
act.sh dashboard delete 13
```

Another example is getting a notification while your on premise controller is starting up. Combine act.sh with the notification tool of your choice ([noti](https://github.com/variadico/noti/), [terminal-notifier](https://github.com/julienXX/terminal-notifier), ...) or run commands after the controller is running:

```shell
noti act.sh controller isup
act.sh controller isup | terminal-notifier
act.sh controller isup ; act.sh applications list
```

Also, you can use `act.sh` to easily create custom events, like code deployments:

```shell
act.sh event create -l INFO -c "This release fixes some minor issues with the mini cart functionality" -e APPLICATION_DEPLOYMENT -a 145 -s "Version 3.5.1 released"
```

For some activities, that require multiple API calls, there are combined commands, e.g. controller federation or copying health rules from one application to another

```bash
act.sh federation setup -h "http://anothercontroller" -c "admin:customer1@password"
act.sh healthrule copy -s 546 -t 1000
```

If a certain API call is not yet wrapped into a command, you can use `controller call` as general interface:

```
act.sh controller call /controller/rest/applications?output=JSON
```

Finally, you can find some more recipes on using ACT in [RECIPES.md](RECIPES.md).

## Postman Integration

If you prefer using a graphical user interface to interact with the API you can import all available commands and your environments into [postman](https://www.getpostman.com/). Read the guide at [POSTMAN.md](POSTMAN.md) to learn more.

## Plugins

If you want to use custom plugins with `act.sh` you can place shell scripts into a plugin folder (default: `~/.appdynamics/act/plugins`) and they will be sourced automatically. A command plugin requires the following structure:

```shell
#!/bin/bash
function namespace_command {
...
}
register namespace_command help text
```

To send a call to the AppDynamics controller you can use the `apiCall` helper, that allows you to easily create a subcommand:

```shell
function tier_nodes {
  apiCall -X GET "/controller/rest/applications/\${a}/tiers/\${t}/nodes" "$@"
}
```

The command `act.sh tier nodes` will now take two arguments (via -a and -t) and send the given request to the AppDynamics controller.

Since all other sub commands are loaded, you can reuse them in your plugin. Most importantly `call_controller` to send requests to the controller.

Please note, that your plugins will not be validated, so you can change global behaviour or break the script.

## Build

To make working on `act.sh` easier this git repository includes a very simple build system: The file `main.sh` is merged with all scripts in the sub directories, that are `source`d. So, if you want to build a custom version of `act.sh` clone this directory, edit `main.sh` or any of the other files in this repository and run `build.sh` to update the script. Any changes you made directly to `act.sh` will be overwritten.

## License

Copyright 2017 AppDynamics LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
