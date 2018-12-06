#!/bin/bash

COLOR_WARNING="\033[0;33m"
COLOR_INFO="\033[0;32m"
COLOR_ERROR="\033[0;31m"
COLOR_DEBUG="\033[0;35m"
COLOR_RESET="\033[0m"

# Retrieve data from controller
CONTROLLER_ES_EUM_KEY=`../act.sh configuration get -n appdynamics.es.eum.key | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
CONTROLLER_EUM_ES_HOST=`../act.sh configuration get -n eum.es.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
CONTROLLER_EUM_CLOUD_HOST=`../act.sh configuration get -n eum.cloud.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
CONTROLLER_EUM_BEACON_HOST=`../act.sh configuration get -n eum.beacon.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
CONTROLLER_EUM_BEACON_HTTPS_HOST=`../act.sh configuration get -n eum.beacon.https.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
CONTROLLER_EUM_MOBILE_SCREENSHOT_HOST=`../act.sh configuration get -n eum.mobile.screenshot.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`

echo "==== Controller Settings ===="
echo "appdynamics.es.eum.key=${CONTROLLER_ES_EUM_KEY}"
echo "eum.es.host=${CONTROLLER_EUM_ES_HOST}"
echo "eum.cloud.host=${CONTROLLER_EUM_CLOUD_HOST}"
echo "eum.beacon.host=${CONTROLLER_EUM_BEACON_HOST}"
echo "eum.beacon.https.host=${CONTROLLER_EUM_BEACON_HTTPS_HOST}"
echo "eum.mobile.screenshot.host=${CONTROLLER_EUM_MOBILE_SCREENSHOT_HOST}"

EUM_PROPERTIES=${1}
EVENTS_SERVICE_API_STORE_PROPERTIES=${2}

if [ -r "${EUM_PROPERTIES}" ] ; then
  IFS=$'\n'
  for LINE in $(<"${EUM_PROPERTIES}"); do
    if [[ $LINE  == analytics.enabled* ]] ; then
      EUM_ANALYTICS_ENABLED=${LINE##*=};
    fi;
    if [[ $LINE  == analytics.accountAccessKey* ]] ; then
      EUM_ANALYTICS_ACCOUNT_ACCESS_KEY=${LINE##*=};
    fi;
    if [[ $LINE  == analytics.serverScheme* ]] ; then
      EUM_ANALYTICS_SERVER_SCHEME=${LINE##*=};
    fi;
    if [[ $LINE  == analytics.serverHost* ]] ; then
      EUM_ANALYTICS_SERVER_HOST=${LINE##*=};
    fi;
    if [[ $LINE  == analytics.port* ]] ; then
      EUM_ANALYTICS_PORT=${LINE##*=};
    fi;
  done
  IFS=$OLD_IFS
  echo -e "\n===== EUM Settings ====="
  echo "analytics.enabled=${EUM_ANALYTICS_ENABLED}"
  echo "analytics.serverScheme=${EUM_ANALYTICS_SERVER_SCHEME}"
  echo "analytics.serverHost=${EUM_ANALYTICS_SERVER_HOST}"
  echo "analytics.port=${EUM_ANALYTICS_PORT}"
  echo "analytics.accountAccessKey=${EUM_ANALYTICS_ACCOUNT_ACCESS_KEY}"
else
  echo -e "${COLOR_WARNING}No eum.properties file provided. Run ${0} eum.properties events-service-api-store.properties to enable value validation.${COLOR_RESET}"
fi;

if [ -r "${EVENTS_SERVICE_API_STORE_PROPERTIES}" ] ; then
  IFS=$'\n'
  for LINE in $(<"${EVENTS_SERVICE_API_STORE_PROPERTIES}"); do
    if [[ $LINE  == ad.accountmanager.key.eum* ]] ; then
      ES_AD_ACCOUNTMANAGER_KEY_EUM=${LINE##*=};
    fi;
    if [[ $LINE  == ad.dw.http.port* ]] ; then
      ES_AD_DW_HTTP_PORT=${LINE##*=};
    fi;
    if [[ $LINE  == ad.dw.https.enabled* ]] ; then
      ES_AD_DW_HTTPS_ENABLED=${LINE##*=};
    fi;
  done
  IFS=$OLD_IFS
  echo -e "\n===== ES Settings ====="
  echo "ad.accountmanager.key.eum=${ES_AD_ACCOUNTMANAGER_KEY_EUM}"
  echo "ad.dw.https.enabled=${ES_AD_DW_HTTPS_ENABLED}"
  echo "ad.dw.http.port=${ES_AD_DW_HTTP_PORT}"
else
  echo -e "${COLOR_WARNING}No events-service-api-store.properties file provided. Run ${0} eum.properties events-service-api-store.properties to enable value validation.${COLOR_RESET}"
fi;

echo;

if [[ ${CONTROLLER_EUM_CLOUD_HOST} != http://* && ${CONTROLLER_EUM_CLOUD_HOST} != https://* ]] ; then
  echo -e "${COLOR_WARNING}Controller setting eum.cloud.host does not start with a protocol (https:// or http://), assumed protocol is https!${COLOR_RESET}"
  CONTROLLER_EUM_CLOUD_HOST=https://${CONTROLLER_EUM_CLOUD_HOST}
fi

if [[ ${CONTROLLER_EUM_ES_HOST} != http://* && ${CONTROLLER_EUM_ES_HOST} != https://* ]] ; then
  echo -e "${COLOR_WARNING}Controller setting eum.es.host does not start with a protocol (https:// or http://), assumed protocol is https!${COLOR_RESET}"
  CONTROLLER_EUM_ES_HOST=https://${CONTROLLER_EUM_ES_HOST}
fi

if [ -r "${EUM_PROPERTIES}" ] ; then
  if [ "${EUM_ANALYTICS_ENABLED}" != "true" ] ; then
    echo -e "${COLOR_WARNING}EUM setting analytics.enabled is not set to true: '${EUM_ANALYTICS_ENABLED}'${COLOR_RESET}"
  fi

  if [ "${CONTROLLER_ES_EUM_KEY}" != "${EUM_ANALYTICS_ACCOUNT_ACCESS_KEY}" ] ; then
    echo -e "${COLOR_ERROR}Controller setting appdynamics.es.eum.key is not equal to EUM setting analytics.accountAccessKey: '${CONTROLLER_ES_EUM_KEY}' != '${EUM_ANALYTICS_ACCOUNT_ACCESS_KEY}'${COLOR_RESET}"
  else
    echo -e "${COLOR_INFO}Controller setting appdynamics.es.eum.key is equal to EUM setting analytics.accountAccessKey: '${CONTROLLER_ES_EUM_KEY}' == '${EUM_ANALYTICS_ACCOUNT_ACCESS_KEY}'${COLOR_RESET}"
fi
fi

if [ -r "${EVENTS_SERVICE_API_STORE_PROPERTIES}" ] ; then
  if [ "${CONTROLLER_ES_EUM_KEY}" != "${ES_AD_ACCOUNTMANAGER_KEY_EUM}" ] ; then
    echo -e "${COLOR_ERROR}Controller setting appdynamics.es.eum.key is not equal to ES setting ad.accountmanager.key.eum: '${CONTROLLER_ES_EUM_KEY}' != '${ES_AD_ACCOUNTMANAGER_KEY_EUM}'${COLOR_RESET}"
  else
    echo -e "${COLOR_INFO}Controller setting appdynamics.es.eum.key is equal to ES setting ad.accountmanager.key.eum: '${CONTROLLER_ES_EUM_KEY}' == '${ES_AD_ACCOUNTMANAGER_KEY_EUM}'${COLOR_RESET}"
  fi

  if [ "${EUM_ANALYTICS_ACCOUNT_ACCESS_KEY}" != "${ES_AD_ACCOUNTMANAGER_KEY_EUM}" ] ; then
    echo -e "${COLOR_ERROR}EUM setting analytics.accountAccessKey is not equal to ES setting ad.accountmanager.key.eum: '${EUM_ANALYTICS_ACCOUNT_ACCESS_KEY}' != '${ES_AD_ACCOUNTMANAGER_KEY_EUM}'${COLOR_RESET}"
  else
    echo -e "${COLOR_INFO}EUM setting analytics.accountAccessKey is equal to ES setting ad.accountmanager.key.eum: '${EUM_ANALYTICS_ACCOUNT_ACCESS_KEY}' == '${ES_AD_ACCOUNTMANAGER_KEY_EUM}'${COLOR_RESET}"
  fi

  if [ "${ES_AD_DW_HTTPS_ENABLED}" != 'false' ] && [ "${ES_AD_DW_HTTPS_ENABLED}" != 'true' ] ; then
    echo -e "${COLOR_ERROR}ES setting ad.dw.https.enabled '${ES_AD_DW_HTTPS_ENABLED}' is illegal.${COLOR_RESET}"
  else
    if ([ "${ES_AD_DW_HTTPS_ENABLED}" == 'false' ] && [ "${EUM_ANALYTICS_SERVER_SCHEME}" != 'http' ]) || ([ "${ES_AD_DW_HTTPS_ENABLED}" == 'true' ] && [ "${EUM_ANALYTICS_SERVER_SCHEME}" != 'https' ]); then
      echo -e "${COLOR_ERROR}EUM setting analytics.serverScheme is set to '${EUM_ANALYTICS_SERVER_SCHEME}', but ES setting ad.dw.https.enabled is '${ES_AD_DW_HTTPS_ENABLED}'.${COLOR_RESET}"
    else
      echo -e "${COLOR_INFO}EUM setting analytics.serverScheme is set to '${EUM_ANALYTICS_SERVER_SCHEME}', and matches ES setting ad.dw.https.enabled '${ES_AD_DW_HTTPS_ENABLED}'.${COLOR_RESET}"
    fi

    if ([ "${ES_AD_DW_HTTPS_ENABLED}" == 'false' ] && [[ "${CONTROLLER_EUM_ES_HOST}" != 'http://'* ]]) || ([ "${ES_AD_DW_HTTPS_ENABLED}" == 'true' ] && [[ "${CONTROLLER_EUM_ES_HOST}" != 'https://'* ]]); then
      echo -e "${COLOR_ERROR}Controller setting eum.es.host is set to '${CONTROLLER_EUM_ES_HOST}', but ES setting ad.dw.https.enabled is '${ES_AD_DW_HTTPS_ENABLED}'.${COLOR_RESET}"
    else
      echo -e "${COLOR_INFO}Controller setting eum.es.host is set to '${CONTROLLER_EUM_ES_HOST}', and matches ES setting ad.dw.https.enabled '${ES_AD_DW_HTTPS_ENABLED}'.${COLOR_RESET}"
    fi
  fi
fi
