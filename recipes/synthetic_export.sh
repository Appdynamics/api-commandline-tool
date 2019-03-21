#!/bin/bash
ENVIRONMENT=$1
APPLICATION=$2
OUTPUTDIRECTORY=$3

if [ ! -d "${OUTPUTDIRECTORY}" ] ;
then
  echo "${OUTPUTDIRECTORY} is not a directory."
  exit
fi;

DATA=$(../act.sh -E ${ENVIRONMENT} synthetic list -a ${APPLICATION} -t last_1_hour.BEFORE_NOW.-1.-1.60)
COUNT=$(echo $DATA | jq '.jobListDatas | length')
declare -i COUNT

COUNT=${COUNT}-1

for i in `seq 0 ${COUNT}` ; do
  NAME=$(echo "$DATA" | jq -r ".jobListDatas | .[$i] | .config | .description")
  echo "$DATA" | jq -r ".jobListDatas | .[$i] | .config | setpath([\"id\"];null)" > "${OUTPUTDIRECTORY}/${NAME}.json"
done;
