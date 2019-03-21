#!/bin/bash
ENVIRONMENT=$1
APPLICATION=$2
TARGET_ENVIRONMENT=$3
TARGET_APPLICATION=$4

DATA=$(../act.sh -E ${ENVIRONMENT} synthetic list -a ${APPLICATION} -t last_1_hour.BEFORE_NOW.-1.-1.60)
COUNT=$(echo $DATA | jq '.jobListDatas | length')
declare -i COUNT

COUNT=${COUNT}-1

for i in `seq 0 ${COUNT}` ; do
  NAME=$(echo "$DATA" | jq -r ".jobListDatas | .[$i] | .config | .description")
  CONFIG=$(echo "$DATA" | jq -r ".jobListDatas | .[$i] | .config | setpath([\"id\"];null)")
  echo "Copying ${NAME}: "
  ../act.sh -E "${TARGET_ENVIRONMENT}" synthetic import -a "${TARGET_APPLICATION}" -d "${CONFIG}"
done;
