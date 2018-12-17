#!/bin/bash
LATEST_RELEASE=`git tag | tail -n 1`
LATEST_COMMIT=`git rev-parse HEAD`

function from_yaml {
  YSH_LIB=1;source ./ysh
  eval "$(YSH_parse commands.yml)"
  NAMESPACES=`set | grep "^y_" | awk -F"_" '{ print $2; }' | sort -u`
  read -r -d '' POSTMAN << ASDF
{
  "info": {
    "name": "AppDynamics API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
ASDF
  for NS in ${NAMESPACES}; do
    COMMANDS=`set | grep "^y_${NS}"  | awk -F"_" '{ print $3; }'| grep -v "=" | sort -u`
    echo -e "Building ${NS}"
    NS_DESCRIPTION="y_${NS}_description"
    read -r -d '' OUTPUT << ASDF
doc ${NS} << EOF
${!NS_DESCRIPTION}
EOF\n
ASDF
POSTMAN+="{\"name\": \"${NS}\",\"item\": []},"
    echo -en "${OUTPUT}" >> temp.sh
    echo -en "${POSTMAN}" >> postman-collection.json

    for CMD in ${COMMANDS}; do
      TITLE="y_${NS}_${CMD}_title"
      DESCRIPTION="y_${NS}_${CMD}_description"
      EXAMPLE="y_${NS}_${CMD}_example"
      METHOD="y_${NS}_${CMD}_method"
      ENDPOINT="y_${NS}_${CMD}_endpoint"
      PAYLOAD="y_${NS}_${CMD}_payload"
      if [ -n "${!PAYLOAD}" ] ; then
        PAYLOAD=" -d '${!PAYLOAD}'"
      else
        PAYLOAD=""
      fi;
      if [ -n "${!METHOD}" ] && [ "${!METHOD}" != "GET" ]; then
        METHOD=" -X ${!METHOD}"
      else
        METHOD=""
      fi;
      echo -e "\t- ${CMD} (${!ENDPOINT})"
      read -r -d '' OUTPUT << ASDF
function ${NS}_${CMD} { apiCall${METHOD}${PAYLOAD} '${!ENDPOINT}' "\$@" ; }
rde ${NS}_${CMD} "${!TITLE}" "${!DESCRIPTION}" "${!EXAMPLE}"\n
ASDF
      echo -en "${OUTPUT}" >> temp.sh
    done;
  done;
  POSTMAN=${POSTMAN%,}
  echo -en "${POSTMAN}]\n}" > postman-collection.json
}

from_yaml

find ./{commands,helpers} -iname "*.sh" -exec /bin/bash -c "tail -n +2 {}" \; >> temp.sh
awk '/#script_placeholder/ {system("cat temp.sh")} {print}' main.sh \
    | sed '/^\s*$/d' \
    | sed "s/ACT_VERSION=\"vx.y.z\"/ACT_VERSION=\"$LATEST_RELEASE\"/" \
    | sed "s/ACT_LAST_COMMIT=\"xxxxxxxxxx\"/ACT_LAST_COMMIT=\"$LATEST_COMMIT\"/" > act.sh
rm -rf temp.sh

./act.sh doc > USAGE.md
