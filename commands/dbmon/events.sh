#!/bin/bash

function dbmon_events {
  event_list -a '_dbmon' "$@"
}

register dbmon_events List all database agent events.
describe dbmon_events << EOF
List all database agent events. This is an alias for \`${SCRIPTNAME} event list -a '_dbmon'\`, so you can use the same parameters for querying the events.
EOF
example dbmon_events << EOF
-t BEFORE_NOW -d 60 -s INFO,WARN,ERROR -e AGENT_EVENT
EOF
