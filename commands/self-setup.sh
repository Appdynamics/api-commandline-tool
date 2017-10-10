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
  local CONTROLLER_COOKIE_LOCATION="${OUTPUT_DIRECTORY}/cookie.txt"

  if [ $GLOBAL -eq 1 ] ; then
    OUTPUT_DIRECTORY="/etc/appdynamics/adc"
    CONTROLLER_COOKIE_LOCATION="/tmp/appdynamics-adc-cookie.txt"
  fi 


  if [ -z ${CONFIG_CONTROLLER_HOST} ] ; then
   echo "Controller Host location (e.g. https://appdynamics.example.com:8090)"
   read CONTROLLER_HOST
  else
   info "Will use $CONFIG_CONTROLLER_HOST as controller host location"
   CONTROLLER_HOST=$CONFIG_CONTROLLER_HOST
  fi

  if [ -z ${CONFIG_CONTROLLER_CREDENTIALS} ] ; then
   echo "Controller Credentials (e.g. user@tenant:password)"
   read CONTROLLER_CREDENTIALS
  else
   info "Will use $CONFIG_CONTROLLER_CREDENTIALS as controller credentials"
   CONTROLLER_CREDENTIALS=$CONFIG_CONTROLLER_CREDENTIALS
  fi

  OUTPUT="CONFIG_CONTROLLER_HOST=${CONTROLLER_HOST}\nCONFIG_CONTROLLER_CREDENTIALS=${CONTROLLER_CREDENTIALS}\nCONFIG_CONTROLLER_COOKIE_LOCATION=${CONTROLLER_COOKIE_LOCATION}"
  if [ ! -s "$OUTPUT_DIRECTORY/config.sh" ] || [ $FORCE -eq 1 ]
  then  
    echo -e "$OUTPUT" > "$OUTPUT_DIRECTORY/config.sh"
    COMMAND_RESULT="Created $OUTPUT_DIRECTORY/config.sh successfully"
  else
    error "Configuration file $OUTPUT_DIRECTORY/config.sh already exists. Please use (-f) to force override"
    COMMAND_RESULT=""
  fi
}

register _self-setup Initialize the adc configuration file
