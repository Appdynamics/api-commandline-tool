#!/bin/bash

function event_create {
  apiCall -X POST "/controller/rest/applications/{{a}}/events?summary={{s}}&comment={{c?}}&eventtype={{e}}&severity={{l}}&bt=&{{b?}}node={{n?}}&tier={{t?}}" "$@"
}

register event_create Create a custom event for a given application
describe event_create << EOF
Create a custom event for a given application. Application, summary, event type and severity are required parameters.
EOF
