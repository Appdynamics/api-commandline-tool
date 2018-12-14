#!/bin/bash

function environment_export {
  environment_source "${1}";


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
  			"key": "controller_credentials",
  			"value": "${CONFIG_CONTROLLER_CREDENTIALS}",
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
