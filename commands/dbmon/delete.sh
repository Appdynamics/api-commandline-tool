#!/bin/bash

function dbmon_delete {
    apiCall -X POST -d "[\${c}]" /controller/restui/databases/collectors/configuration/batchDelete "$@"
}

register dbmon_delete Delete a database collector
describe dbmon_delete << EOF
Delete a database collector. Provide the collector id as parameter.
EOF
