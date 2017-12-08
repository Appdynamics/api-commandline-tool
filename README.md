# AppDynamics Commandline Tool (ADC)

The AppDynamics Commandline Tool (ADC) is a shell script wrapper around [API](https://docs.appdynamics.com/display/PRO43/AppDynamics+APIs#AppDynamicsAPIs-apiindex) calls towards an AppDynamics controller.

## Installation

To use the latest release of ADC just download the raw version of [adc.sh](https://github.com/Appdynamics/adc/blob/master/adc.sh)

Afterwards run `adc.sh config` to provide your controller host and credentials. This will create a configuration file at `~/.appdynamics/adc/config.sh`, e.g.:

```bash
CONFIG_CONTROLLER_HOST=https://appdynamics.example.com:8090
CONFIG_CONTROLLER_CREDENTIALS=me@customer1:secure2
CONFIG_CONTROLLER_COOKIE_LOCATION=/home/ubuntu/.appdynamics/adc/cookie.txt
```

If you want to change your configuration, you can either edit this file or you can re-run the self setup:

```
adc.sh config -f
```

## Usage

`adc.sh` integrates different commands to interact with your AppDynamics controller. Call `adc.sh help` to get a full list of commands.

A simple work flow example is listing, exporting and deleting a dashboard:

```
adc dashboard list
adc dashboard export 13
adc dashboard delete 13
```

Also, you can use `adc.sh` to easily create custom events, like code deployments:

```
./adc.sh event create -s INFO -c "This release fixes some minor issues with the mini cart functionality" -e APPLICATION_DEPLOYMENT -a 145 "Version 3.5.1 released"
```

If a certain API call is not yet wrapped into a command, you can use `controller call` as general interface:

```
adc.sh controller call /controller/rest/applications?output=JSON
```

## Plugins

If you want to use custom plugins with `adc.sh` you can place shell scripts into a plugin folder (default: `~/.appdynamics/adc/plugins`) and they will be sourced automatically. A command plugin requires the following structure:

```
#!/bin/bash
function namespace_command {
...
}
register namespace_command help text
```

To send a call to the AppDynamics controller you can use the `apiCall` helper, that allows you to easily create a subcommand:

```
function tier_nodes {
  apiCall -X GET "/controller/rest/applications/\${a}/tiers/\${t}/nodes" "$@"
}
```

The command `adc.sh tier nodes` will now take two arguments (via -a and -t) and send the given request to the AppDynamics controller.

Since all other sub commands are loaded, you can reuse them in your plugin. Most importantly `call_controller` to send requests to the controller.

Please note, that your plugins will not be validated, so you can change global behaviour or break the script.

## Build

To make working on `adc.sh` easier this git repository includes a very simple build system: The file `main.sh` is merged with all scripts in the sub directories, that are `source`d. So, if you want to build a custom version of `adc.sh` clone this directory, edit `main.sh` or any of the other files in this repository and run `build.sh` to update the script. Any changes you made directly to `adc.sh` will be overwritten.

## License

Copyright 2017 AppDynamics LLC

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
