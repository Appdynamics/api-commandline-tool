#!/bin/bash

function event_list {
  apiCall '/controller/rest/applications/${a}/events?time-range-type=${t}&duration-in-mins=${d?}&start-time=${b?}&end-time=${f?}&event-types=${e}&severities=${s}' "$@"
}

register event_list List all events for a given time range.
describe event_list << EOF
List all events for a given time range.
EOF
