#!/bin/bash

function portal_login {
  debug "Login at 'https://login.appdynamics.com/sso/login/' with $CONFIG_PORTAL_CREDENTIALS"
  httpClient -s -c ${CONFIG_PORTAL_COOKIE_LOCATION} -d "username=${CONFIG_PORTAL_CREDENTIALS%%:*}&password=${CONFIG_PORTAL_CREDENTIALS##*:}" -s 'https://login.appdynamics.com/sso/login/'
  PORTAL_LOGIN_STATUS=0
  grep -q sso-sessionid ${CONFIG_PORTAL_COOKIE_LOCATION} && PORTAL_LOGIN_STATUS=1
  if [ $PORTAL_LOGIN_STATUS -eq 1 ]; then
    COMMAND_RESULT="Portal Login Successful"
  else
    COMMAND_RESULT="Portal Login Error! Please check your credentials"
  fi
}

register portal_login Login to portal.appdynamics.com
describe portal_login << EOF
Login to portal.appdynamics.com
EOF
