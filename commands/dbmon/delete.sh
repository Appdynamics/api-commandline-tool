#!/bin/bash

function dbmon_delete {
    apiCall -X DELETE '/controller/rest/databases/collectors/{{c}}' "$@"
}

register dbmon_delete Delete a database collector
describe dbmon_delete << EOF
Delete a database collector. Provide the collector id as parameter (-c).
EOF

example dbmon_delete << EOF
-c 17
EOF
