#!/bin/bash
START=`date +%s`
COOKIE_PATH="/tmp/adc-test-cookie"
SUCCESS_COUNTER=0
TEST_COUNTER=0

declare -i SUCCESS_COUNTER
declare -i TEST_COUNTER

function assert_equals {
  TEST_COUNTER=$TEST_COUNTER+1
  if [[ "$2" = "$1" ]]; then
    SUCCESS_COUNTER=$SUCCESS_COUNTER+1
    echo -en "\033[0;32m.\033[0m"
  else
    echo -e "\n\033[0;31mTest failed: \033[0;33m$1\033[0;31m doesn't equal \033[0;35m$2\033[0m"
  fi
}

function assert_contains_substring {
  TEST_COUNTER=$TEST_COUNTER+1
  if [[ $2 == *$1* ]]; then
    SUCCESS_COUNTER=$SUCCESS_COUNTER+1
    echo -en "\033[0;32m.\033[0m"
  else
    echo -e "\n\033[0;31mTest failed: Couldn't find \033[0;33m$1\033[0;31m in \033[0;35m$2\033[0m"
  fi
}

function assert_regex {
  TEST_COUNTER=$TEST_COUNTER+1
  if [[ $2 =~ $1 ]]; then
    SUCCESS_COUNTER=$SUCCESS_COUNTER+1
    echo -en "\033[0;32m.\033[0m"
  else
    echo -e "\n\033[0;31mTest failed: Couldn't find \033[0;33m$1\033[0;31m in \033[0;35m$2\033[0m"
  fi
}

echo "Sourcing user config for controller host and credentials..."
source "$HOME/.appdynamics/adc/config.sh"
echo "Will use the following controller for testing: $CONFIG_CONTROLLER_HOST"

ADC="./adc.sh -H $CONFIG_CONTROLLER_HOST -C $CONFIG_CONTROLLER_CREDENTIALS -J $COOKIE_PATH"
#### BEGIN TESTS ####

##### Test controller functionality #####
assert_contains_substring "Pong!" "`${ADC} controller ping`"
assert_contains_substring "Login Successful" "`${ADC} controller login`"
assert_contains_substring "<available>true</available>" "`${ADC} controller status`"
assert_regex "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" "`${ADC} controller version`"

##### List different entities #####
assert_contains_substring "<applications>" "`${ADC} application list`"
assert_contains_substring "<tiers>" "`${ADC} tier list -a 5`"
assert_contains_substring "<business-transactions>" "`${ADC} bt list -a 5`"

##### Error handling #####
assert_equals "Error" "`env CONFIG_HTTP_TIMEOUT=1 ./adc.sh -H 127.0.0.2:8009 controller ping`"

##### Database Collector Create, List, Get, Delete #####
CREATE="`${ADC} dbmon create -i adc_test_collector -h localhost -n db -u user -a "Default Database Agent" -t DB2 -p 1555 -s password`"
assert_contains_substring '"name" : "adc_test_collector",' "$CREATE"
assert_contains_substring '"name" : "adc_test_collector",' "`${ADC} dbmon list`"
if [[ $CREATE =~ \"id\"\ \:\ ([0-9]+) ]] ; then
 COLLECTOR_ID=${BASH_REMATCH[1]}
 assert_contains_substring '"name" : "adc_test_collector",' "`${ADC} dbmon get $COLLECTOR_ID`"
 assert_contains_substring '"status" : "SUCCESS",' "`${ADC} dbmon delete $COLLECTOR_ID`"
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
