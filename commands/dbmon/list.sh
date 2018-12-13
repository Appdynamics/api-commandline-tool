#!/bin/bash

function dbmon_list {
  controller_call /controller/rest/databases/collectors
}

register dbmon_list List all database collectors
describe dbmon_list << EOF
List all database collectors
EOF
