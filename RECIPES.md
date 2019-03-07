# RECIPES

## Applications

### Batch create applications

```shell
#!/bin/bash
NAMES="AD-Test1 AD-Test2 AD-Test3"

for NAME in $NAMES
do
echo "CREATE ${NAME}"
../act.sh application create -n "${NAME}" -t "APM"
done;
```

### Delete all applications on one controller

```shell
#!/bin/bash
EXISTING_APPLICATION_IDS=`../act.sh application list | grep "<id>" | sed "s# *<id>\([^<]*\)</id>#\1#g"`

for APPLICATION in $EXISTING_APPLICATION_IDS
do
echo "DELETE ${APPLICATION}"
../act.sh application delete -a "${APPLICATION}"
done;
```

## Events

### Application Deployment

Integrate this command with your deployment process

```shell
#!/bin/bash
APPLICATION=$1
SUBJECT=$2
COMMENT=$3
../act.sh event create -s INFO -c "${COMMENT}" -e APPLICATION_DEPLOYMENT -a ${APPLICATION} -s "${SUBJECT}" -l INFO
```

## Config

### EUM Verficiation

Use the following script to verify the values configured in your on-premise EUM installation

```shell
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
```

## Service Availability Monitoring

### Batch create monitors

Use the following script to batch create service monitors from a list of URLs:

```shell
#!/bin/bash
# Run this command with the act environment, the machine ID and your list of URLs as parameters, e.g.:
# ./create_service_monitors.sh demo 48 http://www.google.com http://www.google.ch http://www.google.de
ENVIRONMENT="${1}"
MACHINE_ID="${2}"
shift
shift
URLS="$@"
for URL in ${URLS}; do
  ../act.sh -E ${ENVIRONMENT} sam create -n "${URL}" -i ${MACHINE_ID} -u "${URL}" -p 10 -f 1 -s 3 -w 5 -c 30000 -t 30000 -m GET -d 5000 -v '{"field": "STATUS_CODE","value": "200","operator": "GREATER_THAN"}'
done;
```

## Time Ranges

### Relative time ranges

Use the following script with a cronjob, that is run every day after midnight. You might need to adjust for timezones:

```shell
#!/bin/bash

TODAY_MIDNIGHT=$(date -r $(((`date +%s`/86400*86400))) +%s)
declare -i TODAY_MIDNIGHT

# yesterday, 0:00 - today, 0:00)
../act.sh timerange create -s "$((${TODAY_MIDNIGHT}-86400))000" -e "${TODAY_MIDNIGHT}000" yesterday

# "Business Hours", today, 6am-8pm
../act.sh timerange create -s "$((${TODAY_MIDNIGHT}+21600))000" -e "$((${TODAY_MIDNIGHT}+72000))000" 'Business Hours'

# "Same Weekday, 7 days ago"
../act.sh timerange create -s "$((${TODAY_MIDNIGHT}-604800))000" -e "$((${TODAY_MIDNIGHT}-518400))000" '7 days ago'
```
