#!/bin/bash

function _config {
  local FORCE=0
  local GLOBAL=0
  local SHOW=0
  local PORTAL=0
  while getopts "gfsp" opt "$@";
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
    esac
  done;
  shiftOptInd
  shift $SHIFTS

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
    if [ ! -s "$OUTPUT_DIRECTORY/config.sh" ] || [ $FORCE -eq 1 ]
    then
      mkdir -p $OUTPUT_DIRECTORY
      echo -e "$OUTPUT" > "$OUTPUT_DIRECTORY/config.sh"
      COMMAND_RESULT="Created $OUTPUT_DIRECTORY/config.sh successfully"
    else
      error "Configuration file $OUTPUT_DIRECTORY/config.sh already exists. Please use (-f) to force override"
      COMMAND_RESULT=""
    fi
  fi
}

register _config Initialize the act configuration file
describe _config << EOF
Initialize the act configuration file
EOF
