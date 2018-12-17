#!/bin/bash

function tier_list {
  apiCall -X GET "/controller/rest/applications/\{{a}}/tiers" "$@"
}

register tier_list List all tiers for a given application

describe tier_list << EOF
List all tiers for a given application. Provide the application id as parameter.
EOF
