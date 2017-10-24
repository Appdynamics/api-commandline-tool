#!/bin/bash

function controller_status {
  controller_call -X GET /controller/rest/serverstatus
}

register controller_status Get server status from controller
describe controller_status << EOF
This command will return a XML containing status information about the controller.
EOF
