#!/bin/bash
APPLICATION=$1
SUBJECT=$2
COMMENT=$3
../act.sh event create -s INFO -c "${COMMENT}" -e APPLICATION_DEPLOYMENT -a ${APPLICATION} -s "${SUBJECT}" -l INFO
