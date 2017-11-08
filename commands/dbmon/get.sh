#!/bin/bash

function dbmon_get {
  apiCall "/controller/restui/databases/collectors/configurations/\${c}" "$@"
}

register dbmon_get Retrieve information about a specific database collector
describe dbmon_get << EOF
Retrieve information about a specific database collector. Provide the collector id as parameter.
EOF
