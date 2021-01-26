#!/bin/bash
ENVIRONMENT=$1
EXISTING_APPLICATION_IDS=$(../act.sh -E "${ENVIRONMENT}" application list | grep "<id>" | sed "s# *<id>\([^<]*\)</id>#\1#g")

for APPLICATION in $EXISTING_APPLICATION_IDS
do
echo "Disable correlation cookies for ${APPLICATION}"
../act.sh -E "${ENVIRONMENT}" eumCorrelation disable "${APPLICATION}"
done;
