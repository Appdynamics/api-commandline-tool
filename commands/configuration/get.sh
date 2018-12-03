#!/bin/bash

function configuration_get {
  apiCall -X GET '/controller/rest/configuration?name=${n}' "$@"
}

register configuration_get Retrieve a Controller Setting by Name

describe configuration_get << EOF
Retrieve a Controller Setting by Name. Provide a name (-n) as parameter
EOF
