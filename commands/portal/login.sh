#!/bin/bash
PORTAL_LOGIN_STATUS=0

function portal_login {
  if [ -n "$CONFIG_PORTAL_CREDENTIALS" ] ; then
    debug "Login at 'https://login.appdynamics.com/sso/login/' with $CONFIG_PORTAL_CREDENTIALS"
    LOGIN_RESPONSE=$(httpClient -s -c ${CONFIG_PORTAL_COOKIE_LOCATION} -d "username=${CONFIG_PORTAL_CREDENTIALS%%:*}&password=${CONFIG_PORTAL_CREDENTIALS##*:}" 'https://login.appdynamics.com/sso/login/')
    grep -q sso-sessionid ${CONFIG_PORTAL_COOKIE_LOCATION} && PORTAL_LOGIN_STATUS=1
    if [ $PORTAL_LOGIN_STATUS -eq 1 ]; then
      COMMAND_RESULT="Portal Login Successful"
    else
      COMMAND_RESULT="Portal Login Error! Please check your credentials"
    fi
  else
    COMMAND_RESULT="Please run $1 config -p to setup portal credentials."
  fi
}

register portal_login Login to portal.appdynamics.com
describe portal_login << EOF
Login to portal.appdynamics.com
EOF
