#!/bin/bash

function dbmon_create {
  local DB_USER=""
  local DB_HOSTNAME=""
  local DB_AGENT=""
  local DB_TYPE=""
  local DB_COLLECTOR_NAME=""
  local DB_NAME=""
  local DB_PORT=""
  local DB_PASSWORD=""

  while getopts "u:h:a:t:n:p:s:" opt "$@";
  do
    case "${opt}" in
      u)
        DB_USER=${OPTARG}
      ;;
      h)
        DB_HOSTNAME=${OPTARG}
      ;;
      a)
        DB_AGENT=${OPTARG}
      ;;
      t)
        DB_TYPE=${OPTARG}
      ;;
      n)
        DB_NAME=${OPTARG}
      ;;
      p)
        DB_PORT=${OPTARG}
      ;;
      s)
        DB_PASSWORD=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  DB_COLLECTOR_NAME="$*"
  controller_call -X POST -d "{ \
                      \"username\": \"$DB_USER\",\
                      \"hostname\": \"$DB_HOSTNAME\",\
                      \"agentName\": \"$DB_AGENT\",\
                      \"type\": \"$DB_TYPE\",\
                      \"orapkiSslEnabled\": false,\
                      \"orasslTruststoreLoc\": null,\
                      \"orasslTruststoreType\": null,\
                      \"orasslTruststorePassword\": null,\
                      \"orasslClientAuthEnabled\": false,\
                      \"orasslKeystoreLoc\": null,\
                      \"orasslKeystoreType\": null,\
                      \"orasslKeystorePassword\": null,\
                      \"name\": \"$DB_COLLECTOR_NAME\",\
                      \"databaseName\": \"$DB_NAME\",\
                      \"port\": \"$DB_PORT\",\
                      \"password\": \"$DB_PASSWORD\",\
                      \"excludedSchemas\": [],\
                      \"enabled\": true\
                    }" /controller/restui/databases/collectors/createConfiguration
}

register dbmon_create Create a new database collector
describe dbmon_create << EOF
Create a new database collector
EOF
