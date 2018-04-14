#!/bin/bash
LATEST_RELEASE=`git tag | tail -n 1`
LATEST_COMMIT=`git rev-parse HEAD`
find ./ -maxdepth 3 -mindepth 2 -iname "*.sh" -exec /bin/bash -c "tail -n +2 {}" \; >> temp.sh
awk '/#script_placeholder/ {system("cat temp.sh")} {print}' main.sh \
    | sed '/^\s*$/d' \
    | sed "s/ACT_VERSION=\"vx.y.z\"/ACT_VERSION=\"$LATEST_RELEASE\"/" \
    | sed "s/ACT_LAST_COMMIT=\"xxxxxxxxxx\"/ACT_LAST_COMMIT=\"$LATEST_COMMIT\"/" > act.sh
rm -rf temp.sh
