#!/bin/bash

function _self-setup {
  local FORCE=0
  local GLOBAL=0
  while getopts "gf" opt "$@";
  do
    case "${opt}" in
      g)
        GLOBAL=1
      ;;
      f)
        FORCE=1
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS

  local CONTROLLER_HOST=""
  local CONTROLLER_CREDENTIALS=""
  local OUTPUT_DIRECTORY="${HOME}/.appdynamics/adc"
  local USER_PLUGIN_DIRECTORY="{$HOME}/.appdynamics/adc/plugins"
  local CONTROLLER_COOKIE_LOCATION="${OUTPUT_DIRECTORY}/cookie.txt"

  if [ $GLOBAL -eq 1 ] ; then
    OUTPUT_DIRECTORY="/etc/appdynamics/adc"
    CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-adc-cookie.txt"
  fi

  echo "Controller Host location (e.g. https://appdynamics.example.com:8090)"
  read CONTROLLER_HOST

  echo "Controller Credentials (e.g. user@tenant:password)"
  read CONTROLLER_CREDENTIALS
  
  OUTPUT="CONFIG_CONTROLLER_HOST=${CONTROLLER_HOST}\nCONFIG_CONTROLLER_CREDENTIALS=${CONTROLLER_CREDENTIALS}\nCONFIG_CONTROLLER_COOKIE_LOCATION=${CONTROLLER_COOKIE_LOCATION}\nCONFIG_USER_PLUGIN_DIRECTORY=${USER_PLUGIN_DIRECTORY}"
  if [ ! -s "$OUTPUT_DIRECTORY/config.sh" ] || [ $FORCE -eq 1 ]
  then
    mkdir -p $OUTPUT_DIRECTORY
    echo -e "$OUTPUT" > "$OUTPUT_DIRECTORY/config.sh"
    COMMAND_RESULT="Created $OUTPUT_DIRECTORY/config.sh successfully"
  else
    error "Configuration file $OUTPUT_DIRECTORY/config.sh already exists. Please use (-f) to force override"
    COMMAND_RESULT=""
  fi
}

register _self-setup Initialize the adc configuration file
