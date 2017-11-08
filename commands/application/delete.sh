#!/bin/bash

function application_delete {
  apiCall -X POST -d "\${a}" "/controller/restui/allApplications/deleteApplication" "$@"
}

register application_delete Delete an application

describe application_delete << EOF
Delete an application. Provide application id as parameter.
EOF
