#!/bin/bash

function environment_add {
  local FORCE=0
  local GLOBAL=0
  local SHOW=0
  local PORTAL=0
  local DEFAULT=0
  while getopts "gfspd" opt "$@";
  do
    case "${opt}" in
      g)
        GLOBAL=1
      ;;
      f)
        FORCE=1
      ;;
      s)
        SHOW=1
      ;;
      p)
        PORTAL=1
      ;;
      d)
        DEFAULT=1
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS

  local ENVIRONMENT=""
  local CONTROLLER_HOST=""
  local CONTROLLER_CREDENTIALS=""
  local PORTAL_PASSWORD=""
  local PORTAL_USER=""
  local OUTPUT_DIRECTORY="${HOME}/.appdynamics/act"
  local USER_PLUGIN_DIRECTORY="${HOME}/.appdynamics/act/plugins"
  local CONTROLLER_COOKIE_LOCATION="${OUTPUT_DIRECTORY}/cookie.txt"

  if [ $GLOBAL -eq 1 ] ; then
    OUTPUT_DIRECTORY="/etc/appdynamics/act"
    CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-act-cookie.txt"
  fi

  if [ $SHOW -eq 1 ] ; then
    if [ -r $OUTPUT_DIRECTORY/config.sh ] ; then
      COMMAND_RESULT=$(<$OUTPUT_DIRECTORY/config.sh)
    else
      COMMAND_RESULT="act is not configured."
    fi
  else

    if [ $DEFAULT -eq 0 ] ; then
      echo -n "Environment name"
      if [ -n "${CONFIG_ENVIRONMENT}" ] ; then
        echo " [${CONFIG_ENVIRONMENT}]"
      else
        echo " []"
      fi
      read ENVIRONMENT
    fi

    if [ -z "$ENVIRONMENT" ] ; then
      ENVIRONMENT=$CONFIG_ENVIRONMENT
    fi

    echo -n "Controller Host location (e.g. https://appdynamics.example.com:8090)"
    if [ -n "${CONFIG_CONTROLLER_HOST}" ] ; then
      echo " [${CONFIG_CONTROLLER_HOST}]"
    else
      echo " []"
    fi
    read CONTROLLER_HOST

    if [ -z "$CONTROLLER_HOST" ] ; then
      CONTROLLER_HOST=$CONFIG_CONTROLLER_HOST
    fi

    echo -n "Controller Credentials (e.g. user@tenant:password)"
    if [ -n "${CONFIG_CONTROLLER_CREDENTIALS}" ] ; then
      echo " [${CONFIG_CONTROLLER_CREDENTIALS%%:*}:********]"
    else
      echo " []"
    fi
    read CONTROLLER_CREDENTIALS

    if [ -z "$CONTROLLER_CREDENTIALS" ] ; then
      CONTROLLER_CREDENTIALS=$CONFIG_CONTROLLER_CREDENTIALS
    fi

    if [ $PORTAL -eq 1 ] ; then
      echo -n "AppDynamics Portal Credentials (e.g. user@example.com:password)"
      if [ -n "${CONFIG_PORTAL_CREDENTIALS}" ] ; then
        echo " [${CONFIG_PORTAL_CREDENTIALS%%:*}:********]"
      else
        echo " []"
      fi
      read PORTAL_CREDENTIALS
    fi

    OUTPUT="CONFIG_CONTROLLER_HOST=${CONTROLLER_HOST}\nCONFIG_CONTROLLER_CREDENTIALS=${CONTROLLER_CREDENTIALS}\nCONFIG_CONTROLLER_COOKIE_LOCATION=${CONTROLLER_COOKIE_LOCATION}\nCONFIG_USER_PLUGIN_DIRECTORY=${USER_PLUGIN_DIRECTORY}\nCONFIG_PORTAL_CREDENTIALS=${PORTAL_CREDENTIALS}"
    OUTPUT_FILE="$OUTPUT_DIRECTORY/config.${ENVIRONMENT}.sh"
    if [ $DEFAULT -eq 1 ] ; then
      OUTPUT_FILE="$OUTPUT_DIRECTORY/config.sh"
    fi
    if [ ! -s "$OUTPUT_DIRECTORY/config.${ENVIRONMENT}.sh" ] || [ $FORCE -eq 1 ]
    then
      mkdir -p $OUTPUT_DIRECTORY
      echo -e "$OUTPUT" > "${OUTPUT_FILE}"
      COMMAND_RESULT="Created ${OUTPUT_FILE} successfully"
    else
      error "Configuration file ${OUTPUT_FILE} already exists. Please use (-f) to force override"
      COMMAND_RESULT=""
    fi
  fi
}

register environment_add Add a new environment.
describe environment_add << EOF
Add a new environment. To change the default environment, run with \`-d\`
EOF

example environment_add << EOF
-d
EOF
