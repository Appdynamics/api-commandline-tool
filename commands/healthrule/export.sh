#!/bin/bash

function healthrule_export {
  apiCall -X GET '/controller/healthrules/{{a}}/?name={{n?}}' "$@"
}

register healthrule_export Export a health rule

describe healthrule_export << EOF
Export a health rule. Provide parameter a for the application and parameter n for the name of the health rule. If you want to export all healthrules use the "list" command
EOF
