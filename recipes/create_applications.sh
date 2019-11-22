#!/bin/bash
NAMES="AD-Test1 AD-Test2 AD-Test3"

for NAME in $NAMES
do
echo "CREATE ${NAME}"
../act.sh application create -n "${NAME}" -t "APM"
done;
