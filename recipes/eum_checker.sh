#!/bin/bash
ES_EUM_KEY=`../act.sh configuration get -n appdynamics.es.eum.key | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
EUM_ES_HOST=`../act.sh configuration get -n eum.es.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
EUM_CLOUD_HOST=`../act.sh configuration get -n eum.cloud.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
EUM_BEACON_HOST=`../act.sh configuration get -n eum.beacon.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
EUM_BEACON_HTTPS_HOST=`../act.sh configuration get -n eum.beacon.https.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`
EUM_MOBILE_SCREENSHOT_HOST=`../act.sh configuration get -n eum.mobile.screenshot.host | grep value | sed -e "s#.*<value>\(.*\)</value>.*#\1#"`


echo "appdynamics.es.eum.key: ${ES_EUM_KEY}"
echo "eum.es.host: ${EUM_ES_HOST}"
echo "eum.cloud.host: ${EUM_CLOUD_HOST}"
echo "eum.beacon.host: ${EUM_BEACON_HOST}"
echo "eum.beacon.https.host: ${EUM_BEACON_HTTPS_HOST}"
echo "eum.mobile.screenshot.host: ${EUM_MOBILE_SCREENSHOT_HOST}"
