#!/bin/bash

function bt_list {
  apiCall -X GET "/controller/rest/applications/\${a}/business-transactions" "$@"
}

register bt_list List all business transactions for a given application

describe bt_list << EOF
List all business transactions for a given application. Provide the application id as parameter.
EOF
