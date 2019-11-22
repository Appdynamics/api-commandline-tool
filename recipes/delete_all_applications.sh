#!/bin/bash
EXISTING_APPLICATION_IDS=`../act.sh application list | grep "<id>" | sed "s# *<id>\([^<]*\)</id>#\1#g"`

for APPLICATION in $EXISTING_APPLICATION_IDS
do
echo "DELETE ${APPLICATION}"
../act.sh application delete -a "${APPLICATION}"
done;
