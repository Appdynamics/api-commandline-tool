#!/bin/bash

function server_list {
  apiCall -X GET "/controller/sim/v2/user/machines" "$@"
}

register server_list List all servers

describe server_list << EOF
List all servers
EOF
