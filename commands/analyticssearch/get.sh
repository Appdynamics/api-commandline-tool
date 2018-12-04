#!/bin/bash

function analyticssearch_get {
  apiCall '/controller/restui/analyticsSavedSearches/getAnalyticsSavedSearchById/${i}' "$@"
}

register analyticssearch_get Get an analytics search by id.

describe analyticssearch_get << EOF
Get an analytics search by id. Provide the id as parameter (-i)
EOF
