#!/bin/bash

function configuration_list {
  apiCall -X GET "/controller/rest/configuration" "$@"
}

register configuration_list Retrieve All Controller Settings

describe configuration_list << EOF
Retrieve All Controller Settings
EOF
