#!/bin/bash

function bizjourney_disable {
  apiCall -X PUT '/controller/restui/analytics/biz_outcome/definitions/{{i}}/actions/userDisable' "$@"
}

register bizjourney_disable "Disable a valid business journey draft"

describe bizjourney_disable << EOF
Disable a valid business journey draft. Provide the journey id (-i) as parameter
EOF
