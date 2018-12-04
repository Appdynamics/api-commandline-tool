#!/bin/bash

function analyticssearch_list {
  apiCall '/controller/restui/analyticsSavedSearches/getAllAnalyticsSavedSearches' "$@"
}

register analyticssearch_list List all analytics searches on the controller.

describe analyticssearch_list << EOF
List all analytics searches available on the controller. This command requires no further arguments.
EOF
