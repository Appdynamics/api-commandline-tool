#!/bin/bash
LATEST_RELEASE=`git tag | tail -n 1`
LATEST_COMMIT=`git rev-parse HEAD`
awk '
    $1 == "source" {system("tail -n +2 " $2); next}
    {print}
' main.sh | sed '/^\s*$/d' \
          | sed "s/ACT_VERSION=\"vx.y.z\"/ACT_VERSION=\"$LATEST_RELEASE\"/" \
          | sed "s/ACT_LAST_COMMIT=\"xxxxxxxxxx\"/ACT_LAST_COMMIT=\"$LATEST_COMMIT\"/" > act.sh
