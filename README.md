# AppDynamics Commandline Tool (ADC)

## Installation

To use the latest release of ADC just download the raw version of [adc.sh](https://github.com/Appdynamics/adc/blob/master/adc.sh)

Afterwards run `adc.sh self-setup` to provide your controller host and credentials. 

## Usage

`adc.sh` integrates different commands to interact with your AppDynamics controller. Call `adc.sh help` to get a full list. A simple work flow example is listing, exporting and deleting a dashboard:

```
adc dashboard list
adc dashboard export 13
adc dashboard delete 13
```


## Build

If you want to build your own version of `adc.sh` clone this repository and use `build.sh` to merge all shell scripts into a single file
