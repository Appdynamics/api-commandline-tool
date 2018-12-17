#!/bin/bash

function node_get {
  apiCall -X GET "/controller/rest/applications/\{{a}}/nodes/\{{n}}" "$@"
}

register node_get Retrieve Node Information by Node Name

describe node_get << EOF
Retrieve Node Information by Node Name. Provide the application and the node as parameters
EOF
