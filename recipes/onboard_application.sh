#!/bin/bash
APPLICATION="$*"
OLD_APPLICATION="AD-Test-App"
DASHBOARD_FOLDER="${HOME}/mydashboards"
RUNID=${RANDOM}
for i in ${DASHBOARD_FOLDER}/*.json; do 
	jq ".name|=\"${APPLICATION} - \" + ." $i | sed "s/${OLD_APPLICATION}/${APPLICATION}/g" > "/tmp/onboard-${RUNID}-$(basename ${i})"; 
done

../act.sh -E achim dashboard import -d @/tmp/onboard-${RUNID}-*

rm /tmp/onboard-${RUNID}-*
