# AppDynamics Commandline Tool (ADC)

The AppDynamics Commandline Tool (ADC) is a shell script wrapper around [API](https://docs.appdynamics.com/display/PRO43/AppDynamics+APIs#AppDynamicsAPIs-apiindex) calls towards an AppDynamics controller. 

## Installation

To use the latest release of ADC just download the raw version of [adc.sh](https://github.com/Appdynamics/adc/blob/master/adc.sh)

Afterwards run `adc.sh self-setup` to provide your controller host and credentials. This will create a configuration file at `~/.appdynamics/adc/config.sh`, e.g.:

```bash
CONFIG_CONTROLLER_HOST=https://appdynamics.example.com:8090
CONFIG_CONTROLLER_CREDENTIALS=me@customer1:secure2
CONFIG_CONTROLLER_COOKIE_LOCATION=/home/ubuntu/.appdynamics/adc/cookie.txt
```

If you want to change your configuration, you can either edit this file or you can re-run the self setup:

```
adc.sh self-setup -f
```

## Usage

`adc.sh` integrates different commands to interact with your AppDynamics controller. Call `adc.sh help` to get a full list:

```
Usage: ./adc.sh <namespace> <command>

To execute a action, provide a namespace and a command, e.g. "dbmon list" to list all database collectors.
Finally the following commands in the global namespace can be called directly:

controller
	call		Send a custom HTTP call to a controller
	login		Login to your controller

dashboard
	delete		Delete a specific dashboard
	export		Export a specific dashboard
	list		List all dashboards available on the controller

dbmon
	create		Create a new database collector


	help		Display the global usage information
	self-setup		Initialize the adc configuration file

timerange
	create		Create a custom time range
	delete		Delete a specific time range by id
	list		List all custom timeranges available on the controller
```

A simple work flow example is listing, exporting and deleting a dashboard:

```
adc dashboard list
adc dashboard export 13
adc dashboard delete 13
```

If a certain API call is not yet wrapped into a command, you can use `controller call` as general interface:

```
adc.sh controller call /controller/rest/applications?output=JSON 
```

## Build

You can build your own version of `adc.sh` and integrate custom commands by cloning this git repository and working with `build.sh` to merge all scripts into one. 
