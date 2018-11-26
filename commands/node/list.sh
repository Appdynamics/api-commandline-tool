#!/bin/bash

function node_list {
  apiCall -X GET "/controller/rest/applications/\${a}/nodes" "$@"
}

register node_list Retrieve Node Information for All Nodes in a Business Application

describe node_list << EOF
Retrieve Node Information for All Nodes in a Business Application. Provide the application as parameter.
EOF
