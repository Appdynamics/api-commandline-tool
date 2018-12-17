#!/bin/bash
START=`date +%s`
COOKIE_PATH="/tmp/act-test-cookie"
SUCCESS_COUNTER=0
TEST_COUNTER=0
SKIP_COUNTER=0
LAST_TEST_STATUS=0

declare -i SUCCESS_COUNTER
declare -i SKIP_COUNTER
declare -i TEST_COUNTER

FRIEND_CONTROLLER_HOST="http://controller.local:8090"
FRIEND_CONTROLLER_CREDENTIALS="admin@customer1:appdynamics123"
FRIEND_COOKIE_PATH="/tmp/act-test-friend-cookie"

echo "Sourcing user config for controller host and credentials..."
source "$HOME/.appdynamics/act/config.sh"
echo "Will use the following controller for testing: $CONFIG_CONTROLLER_HOST"

function assert_equals {
  TEST_COUNTER=$TEST_COUNTER+1
  if [[ "$2" = "$1" ]]; then
    SUCCESS_COUNTER=$SUCCESS_COUNTER+1
    LAST_TEST_STATUS=0
    echo -en "\033[0;32m.\033[0m"
  else
    LAST_TEST_STATUS=1
    echo -e "\n\033[0;31mTest \033[0;34m$3\033[0;31m failed: \033[0;33m$1\033[0;31m doesn't equal \033[0;35m$2\033[0m"
  fi
}

function assert_empty {
  TEST_COUNTER=$TEST_COUNTER+1
  if [[ -z "$1" ]]; then
    SUCCESS_COUNTER=$SUCCESS_COUNTER+1
    echo -en "\033[0;32m.\033[0m"
    LAST_TEST_STATUS=0
  else
    LAST_TEST_STATUS=1
    echo -e "\n\033[0;31mTest \033[0;34m$3\033[0;31m failed: \033[0;33m$1\033[0;31m is not an empty string."
  fi
}

function assert_contains_substring {
  TEST_COUNTER=$TEST_COUNTER+1
  if [[ $2 = *$1* ]]; then
    SUCCESS_COUNTER=$SUCCESS_COUNTER+1
    echo -en "\033[0;32m.\033[0m"
    LAST_TEST_STATUS=0
  else
    LAST_TEST_STATUS=1
    echo -e "\n\033[0;31mTest \033[0;34m$3\033[0;31m failed: Couldn't find \033[0;33m$1\033[0;31m in \033[0;35m$2\033[0m"
  fi
}

function assert_regex {
  TEST_COUNTER=$TEST_COUNTER+1
  if [[ $2 =~ $1 ]]; then
    SUCCESS_COUNTER=$SUCCESS_COUNTER+1
    echo -en "\033[0;32m.\033[0m"
    LAST_TEST_STATUS=0
  else
    LAST_TEST_STATUS=1
    echo -e "\n\033[0;31mTest \033[0;34m$3\033[0;31m failed: Couldn't find \033[0;33m$1\033[0;31m in \033[0;35m$2\033[0m"
  fi
}

ACT="./act.sh -N -H $CONFIG_CONTROLLER_HOST -C $CONFIG_CONTROLLER_CREDENTIALS -J $COOKIE_PATH"
ACT_FRIEND="./act.sh -N -H $FRIEND_CONTROLLER_HOST -C $FRIEND_CONTROLLER_CREDENTIALS -J $FRIEND_COOKIE_PATH"
#### BEGIN TESTS ####

##### Test controller functionality #####
assert_contains_substring "Pong!" "`${ACT} controller ping`"
assert_contains_substring "Login Successful" "`${ACT} controller login`"
assert_contains_substring "<available>true</available>" "`${ACT} controller status`"
assert_regex "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" "`${ACT} controller version`"

##### Create a test application
APPNAME="ACT_TEST_APPLICATION_${RANDOM}"
CREATE_APPLICATION="`${ACT} application create -t APM -n "$APPNAME"`"
assert_contains_substring "\"name\" : \"${APPNAME}\"," "$CREATE_APPLICATION"
if [[ $CREATE_APPLICATION =~ \"id\"\ \:\ ([0-9]+) ]] ; then
  APPLICATION_ID=${BASH_REMATCH[1]}

  ##### List different entities #####
  assert_contains_substring "<applications>" "`${ACT} application list`" "List Applications"
  assert_contains_substring "<tiers>" "`${ACT} tier list -a $APPLICATION_ID`" "List Tiers"
  assert_contains_substring "<business-transactions>" "`${ACT} bt list -a $APPLICATION_ID`" "List BTs"
  assert_contains_substring "<nodes>" "`${ACT} node list -a $APPLICATION_ID`" "List Nodes"

  ##### Run exports #####
  assert_contains_substring "<rule" "`${ACT} application export -a $APPLICATION_ID`" "Export Application"

  ##### Database Collector Create, List, Get, Delete #####
  DBMON_NAME="act_test_collector_$RANDOM"
  CREATE_DBMON="`${ACT} dbmon create -i ${DBMON_NAME} -h localhost -n db -u user -a "Default Database Agent" -t DB2 -p 1555 -s password`"
  assert_contains_substring "HTTP Status: 201" "${CREATE_DBMON}" "Create Database Collector"
  sleep 10
  assert_contains_substring "\"name\":\"${DBMON_NAME}\"," "`${ACT} dbmon list`" "List Database Collectors"
  echo $CREATE_DBMON
  if [[ $CREATE_DBMON =~ \"id\"\:([0-9]+) ]] ; then
    COLLECTOR_ID=${BASH_REMATCH[1]}
    assert_contains_substring "\"name\" : \"${DBMON_NAME}\"," "`${ACT} dbmon get -c $COLLECTOR_ID`"
    assert_contains_substring '"status" : "SUCCESS",' "`${ACT} dbmon delete -c $COLLECTOR_ID`"
  else
    SKIP_COUNTER=$SKIP_COUNTER+2
    echo -en "\033[0;33m!!\033[0m"
  fi

  ##### Events #####
  assert_contains_substring "Successfully created the event id:" "`${ACT} event create -a ${APPLICATION_ID} -s "Test" -l INFO -e CUSTOM`" "Create custom event"
  assert_contains_substring "Successfully created the event id:" "`${ACT} event create -a ${APPLICATION_ID} -s "Test" -l INFO -e APPLICATION_DEPLOYMENT`" "Create application deployment"
  assert_contains_substring "Successfully created the event id:" "`${ACT} event create -a ${APPLICATION_ID} -s "Urlencoding Test" -c "With Comment" -l INFO -e APPLICATION_DEPLOYMENT`" "Create application deployment"
  # It takes the controller several seconds to update the list of events, so we (currently) skip checking the existence of the ids above
  assert_contains_substring "<events></events>" "`${ACT} event list -a ${APPLICATION_ID} -t BEFORE_NOW -d 60 -e APPLICATION_DEPLOYMENT -s INFO`"

  ##### Federation #####
  FRIEND_LOGIN="`${ACT_FRIEND} controller login`"
  assert_contains_substring "Login Successful" "$FRIEND_LOGIN" "Federation Friend login successful"
  if [ $LAST_TEST_STATUS -eq 0 ]; then
    assert_contains_substring "Federation Key for account {customer1}" "`${ACT} federation createkey -n key_${RANDOM}`" "Create federation key"
    assert_contains_substring "HTTP Status: 200" "`${ACT_FRIEND} federation setup -h "${CONFIG_CONTROLLER_HOST}" -c "${CONFIG_CONTROLLER_CREDENTIALS}"`" "Federation Setup"
  else
    SKIP_COUNTER=$SKIP_COUNTER+2
    echo -en "\033[0;33m!!\033[0m"
  fi
  ##### Error handling #####
  assert_equals "Error" "`env CONFIG_HTTP_TIMEOUT=1 ./act.sh -H 127.0.0.2:8009 controller ping`"
  assert_equals "ERROR: Please provide an argument for paramater -a" "`${ACT} event create`" "Missing required argument"

  ##### Delete the test application
  assert_contains_substring "HTTP Status: 204" "`${ACT} application delete $APPLICATION_ID`"
fi
#### END TESTS ####

declare -i PERCENTAGE

PERCENTAGE=$((($SUCCESS_COUNTER*100)/($TEST_COUNTER)))

if [ $PERCENTAGE -eq 100 ]; then
  echo -e "\033[0;32m"
elif [ $PERCENTAGE -ge 80 ]; then
  echo -e "\033[0;33m"
else
  echo -e "\033[0;31m"
fi

rm $COOKIE_PATH
END=`date +%s`

echo -e "\n$SUCCESS_COUNTER/$TEST_COUNTER ($PERCENTAGE%) tests completed in $((END-START))s.\033[0m"
if [ $SKIP_COUNTER -gt 0 ] ; then
  echo -e "\033[0;33m$SKIP_COUNTER tests have been skipped.\033[0m"
fi
