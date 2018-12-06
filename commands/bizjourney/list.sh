#!/bin/bash

function bizjourney_list {
  controller_call '/controller/restui/analytics/biz_outcome/definitions/summary'
}

register bizjourney_list List all business journeys

describe bizjourney_list << EOF
List all business journeys. This command requires no further arguments.
EOF
