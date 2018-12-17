#!/bin/bash

function tier_get {
  apiCall -X GET "/controller/rest/applications/\{{a}}/tiers/\{{t}}" "$@"
}

register tier_get Retrieve Tier Information by Tier Name

describe tier_get << EOF
Retrieve Tier Information by Tier Name. Provide the application and the tier as parameters
EOF
