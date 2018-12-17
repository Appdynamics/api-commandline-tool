#!/bin/bash

function tier_nodes {
  apiCall -X GET '/controller/rest/applications/{{a}}/tiers/{{t}}/nodes' "$@"
}

register tier_nodes" Retrieve Node Information for All Nodes in a Tier"

describe tier_nodes << EOF
Retrieve Node Information for All Nodes in a Tier. Provide the application and the tier as parameters
EOF
