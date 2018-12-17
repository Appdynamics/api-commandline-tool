#!/bin/bash

function bizjourney_enable {
  apiCall -X PUT '/controller/restui/analytics/biz_outcome/definitions/{{i}}/actions/enable' "$@"
}

register bizjourney_enable "Enable a valid business journey draft"

describe bizjourney_enable << EOF
Enable a valid business journey draft. Provide the journey id (-i) as parameter
EOF
