#!/bin/bash
PORTAL_LOGIN_STATUS=0
PORTAL_LOGIN_TOKEN=""

download_login() {
  if [ -n "$CONFIG_PORTAL_CREDENTIALS" ] ; then
    USERNAME=${CONFIG_PORTAL_CREDENTIALS%%:*}
    PASSWORD=${CONFIG_PORTAL_CREDENTIALS#*:}
    debug "Login at 'https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token' with $USERNAME and $PASSWORD"
    LOGIN_RESPONSE=$(httpClient -s -X POST -d "{\"username\": \"${USERNAME}\",\"password\": \"${PASSWORD}\",\"scopes\": [\"download\"]}" https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token)
    if [[ "${LOGIN_RESPONSE/\"error\"}" != "${LOGIN_RESPONSE}" ]]; then
      COMMAND_RESULT="Login Error! Please check your portal credentials."
    else
      PORTAL_LOGIN_STATUS=1
      PORTAL_LOGIN_TOKEN="${LOGIN_RESPONSE#*"access_token\": \""}"
      PORTAL_LOGIN_TOKEN=${PORTAL_LOGIN_TOKEN%%\"*}
      COMMAND_RESULT="Login Successful! Token: ${PORTAL_LOGIN_TOKEN}"
    fi
  else
    COMMAND_RESULT="Please run $1 config -p to setup portal credentials."
  fi
}

rde download_login "Login with AppDynamics to retrieve an OAUTH token for downloads." "You can use the provided token for downloads from https://download.appdynamics.com/" ""
