#!/bin/bash

function dbmon_get {
  apiCall '/controller/rest/databases/collectors/${c}' "$@"
}

register dbmon_get Retrieve information about a specific database collector
describe dbmon_get << EOF
Retrieve information about a specific database collector. Provide the collector id as parameter (-c).
EOF
example dbmon_get << EOF
-c 17
EOF
