#!/bin/bash

function snapshot_list {
  apiCall '/controller/rest/applications/{{a}}/request-snapshots?time-range-type={{t}}&duration-in-mins={{d?}}&start-time={{b?}}&end-time={{f?}}' "$@"
}

register snapshot_list Retrieve a list of snapshots for a specific application

describe snapshot_list << EOF
Retrieve a list of snapshots for a specific application.
EOF
