#!/bin/bash

function configuration_set {
  apiCall -X POST '/controller/rest/configuration?name=${n}&value=${v}' "$@"
}

register configuration_set Set a Controller setting to a specified value.

describe configuration_set << EOF
Set a Controller setting to a specified value. Provide a name (-n) and a value (-v) as parameters
EOF
