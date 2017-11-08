#!/bin/bash

function application_create {
  apiCall -X POST -d "{\"name\": \"\${n}\", \"description\": \"\"}" "/controller/restui/allApplications/createApplication?applicationType=\${t}" "$@"
}

register application_create Create a new application

describe application_create << EOF
Create a new application. Provide a name and a type (APM or WEB) as parameter.
EOF
