#!/bin/bash

function healthrule_list {
  apiCall -X GET '/controller/healthrules/{{a}}/' "$@"
}

register healthrule_list List all healthrules

describe healthrule_list << EOF
List all health rules. Provide parameter a for the application and parameter.
EOF
