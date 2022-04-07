#!/bin/bash

CONTROLLER_LOGIN_STATUS=0

controller_login() {
  debug "Login at ${CONFIG_CONTROLLER_HOST} with ${CONFIG_CONTROLLER_CREDENTIALS}"
  LOGIN_RESPONSE=$(httpClient -v -c "${CONFIG_CONTROLLER_COOKIE_LOCATION}" --user "${CONFIG_CONTROLLER_CREDENTIALS}" "${CONFIG_CONTROLLER_HOST}/controller/auth?action=login" 2>&1)
  debug "RESPONSE: ${LOGIN_RESPONSE}"
  # The section option is for supporting HTTP2 (#12)
  if [[ "${LOGIN_RESPONSE/200 OK}" != "${LOGIN_RESPONSE}" ]] || [[ "${LOGIN_RESPONSE/HTTP\/2 200}" != "${LOGIN_RESPONSE}" ]]; then
    COMMAND_RESULT="Controller Login Successful"
    CONTROLLER_LOGIN_STATUS=1
  else
    COMMAND_RESULT="Controller Login Error! Please check hostname and credentials"
    CONTROLLER_LOGIN_STATUS=0
  fi
  XCSRFTOKEN=$(grep "X-CSRF-TOKEN" $CONFIG_CONTROLLER_COOKIE_LOCATION | awk 'NF>1{print $NF}')
  debug "XCSRFTOKEN: $XCSRFTOKEN"
}

register controller_login Login to your controller
describe controller_login << EOF
Check if the login with your appdynamics controller works properly. If the login fails, use \`${SCRIPTNAME} controller ping\` to check if the controller is running and check your credentials if they are correct.
EOF
example controller_login << EOF
EOF
