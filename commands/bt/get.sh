#!/bin/bash

function application_get {
  apiCall '/controller/rest/applications/${a}' "$@"
}

register application_get Get an application

describe application_get << EOF
Get an application. Provide application id or name as parameter (-a).
EOF
