#!/bin/bash

function federation_createkey {
  apiCall -X POST -d '{"apiKeyName": "{{n}}"}' "/controller/rest/federation/apikeyforfederation" "$@"
}

register federation_createkey Create API Key for Federation
describe federation_createkey << EOF
Create API Key for Federation.
EOF
