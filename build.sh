#!/bin/bash
LATEST_RELEASE=`git tag | tail -n 1`
LATEST_COMMIT=`git rev-parse HEAD`

source ./yaml-build.sh ; from_yaml

# The following reads in all .sh files from commands/ & helpers/ and merges them into the result
find ./{commands,helpers} -iname "*.sh" -exec /bin/bash -c "tail -n +2 {}" \; >> temp.sh
awk '/#script_placeholder/ {system("cat temp.sh")} {print}' main.sh \
    | sed '/^\s*$/d' \
    | sed "s/ACT_VERSION=\"vx.y.z\"/ACT_VERSION=\"$LATEST_RELEASE\"/" \
    | sed "s/ACT_LAST_COMMIT=\"xxxxxxxxxx\"/ACT_LAST_COMMIT=\"$LATEST_COMMIT\"/" > act.sh
rm -rf temp.sh

./act.sh doc > USAGE.md
