#!/bin/bash
function dbmon_list {
  controller_call /controller/rest/databases/collectors
}
rde dbmon_list "List all database collectors." "No further arguments required." ""
