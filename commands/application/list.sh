#!/bin/bash

function application_list {
  controller_call /controller/rest/applications
}

register application_list List all applications available on the controller

describe application_list << EOF
List all applications available on the controller. This command requires no further arguments.
EOF
