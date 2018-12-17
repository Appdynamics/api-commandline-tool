#!/bin/bash

function bizjourney_import {
  apiCall -X POST -d '{{d}}' '/controller/restui/analytics/biz_outcome/definitions/saveAsValidDraft' "$@"
}

register bizjourney_import Import a business journey

describe bizjourney_import << EOF
Import a business journey. Provide a json string or a file (with @ as prefix) as paramater (-d)
EOF
