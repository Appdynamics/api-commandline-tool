#!/bin/bash
LATEST_RELEASE=`git tag | tail -n 1`
LATEST_COMMIT=`git rev-parse HEAD`

function from_yaml {
  YSH_LIB=1;source ./ysh
  eval "$(YSH_parse commands.yml)"
  NAMESPACES=`set | grep "^y_" | awk -F"_" '{ print $2; }' | sort -u`
  POSTMAN='{"info": {"name": "AppDynamics API","schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"}, "auth": {"type": "basic","basic": [{"key": "password","value": "{{controller_password}}","type": "string"},{"key": "username","value": "{{controller_user}}@{{controller_account}}","type": "string"}]}, "event": [{"listen": "test","script": {"type": "text/javascript","exec": ["pm.globals.set(\"X-CSRF-TOKEN\", postman.getResponseCookie(\"X-CSRF-TOKEN\").value);"]}}],"item": ['
  for NS in ${NAMESPACES}; do
    COMMANDS=`set | grep "^y_${NS}_"  | awk -F"_" '{ print $3; }'| grep -v "=" | sort -u`
    # echo -e "Building ${NS}"
    NS_DESCRIPTION="y_${NS}_description"

    read -r -d '' OUTPUT << ASDF
doc ${NS} << EOF
${!NS_DESCRIPTION}
EOF\n
ASDF

    POSTMAN+="{\"name\": \"${NS}\",\"item\": ["
    echo -en "${OUTPUT}" >> temp.sh
    echo -en "${POSTMAN}" >> postman-collection.json

    for CMD in ${COMMANDS}; do
      TITLE="y_${NS}_${CMD}_title"
      DESCRIPTION="y_${NS}_${CMD}_description"
      EXAMPLE="y_${NS}_${CMD}_example"
      METHOD="y_${NS}_${CMD}_method"
      ENDPOINT="y_${NS}_${CMD}_endpoint"
      PAYLOAD="y_${NS}_${CMD}_payload"
      FORM="y_${NS}_${CMD}_form"
      EXPAND="y_${NS}_${CMD}_expand"

      ENDPOINT=${!ENDPOINT}
      PAYLOAD=${!PAYLOAD}
      FORM=${!FORM}
      EXPAND=${!EXPAND}

      # echo -e "\t- ${CMD} (${ENDPOINT})"

      POSTMAN_ENDPOINT=${ENDPOINT}
      POSTMAN_PAYLOAD=${PAYLOAD}

      ARGUMENT_PATTERN="\{\{([a-zA-Z]):([a-zA-Z0-9_-]+)(\??)\}\}"
      while [[ $POSTMAN_ENDPOINT =~ $ARGUMENT_PATTERN ]] ; do
        REPLACEMENT="{{${BASH_REMATCH[2]}}}"
        POSTMAN_ENDPOINT=${POSTMAN_ENDPOINT//${BASH_REMATCH[0]}/$REPLACEMENT}
      done;
      while [[ $POSTMAN_PAYLOAD =~ $ARGUMENT_PATTERN ]] ; do
        REPLACEMENT="{{${BASH_REMATCH[2]}}}"
        POSTMAN_PAYLOAD=${POSTMAN_PAYLOAD//${BASH_REMATCH[0]}/$REPLACEMENT}
      done;

      P_PATH=${POSTMAN_ENDPOINT%%\?*}

      P_PATH=${P_PATH//\//\",\"}


      P_QUERY=""
      if [[ ${POSTMAN_ENDPOINT} == *"?"* ]] ; then
        P_QUERY=${POSTMAN_ENDPOINT#*\?}
        local REPLACEMENT="\"},{\"key\":\""
        P_QUERY=${P_QUERY//&/${REPLACEMENT}}
        P_QUERY="{\"key\": \"${P_QUERY//=/\",\"value\": \"}\"}"
      fi

      POSTMAN+="{
					\"name\": \"${!TITLE}\",
					\"request\": {
						\"method\": \"${!METHOD}\",
						\"header\": [
              {
								\"key\": \"Content-Type\",
								\"value\": \"application/json;charset=UTF-8\",
								\"type\": \"text\"
							},
              {
								\"key\": \"X-CSRF-TOKEN\",
								\"value\": \"{{X-CSRF-TOKEN}}\",
								\"type\": \"text\"
							}
            ],
						\"body\": {
							\"mode\": \"raw\",
							\"raw\": \"${POSTMAN_PAYLOAD//\"/\\\"}\"
						},
						\"url\": {
							\"raw\": \"{{controller_host}}${ENDPOINT}\",
              \"host\": [
								\"{{controller_host}}\"
							],
							\"path\": [${P_PATH#\",}\"],
              \"query\": [${P_QUERY}]
						},
            \"description\": \"${!DESCRIPTION}\"
					}
				},"

        if [ -n "${PAYLOAD}" ] ; then
          PAYLOAD=" -d '${PAYLOAD}'"
        else
          PAYLOAD=""
        fi;

        if [ -n "${FORM}" ] ; then
          FORM=" -F '${FORM}'"
        else
          FORM=""
        fi;


        if [ -n "${!METHOD}" ] && [ "${!METHOD}" != "GET" ]; then
          METHOD=" -X ${!METHOD}"
        else
          METHOD=""
        fi;

        if [ "${EXPAND}" == "true" ] ; then
          read -r -d '' OUTPUT << ASDF
${NS}_${CMD}() { apiCallExpand${METHOD}${PAYLOAD}${FORM} '${ENDPOINT}' "\$@" ; }
rde ${NS}_${CMD} "${!TITLE}" "${!DESCRIPTION}" "${!EXAMPLE}"\n
ASDF
        else
          read -r -d '' OUTPUT << ASDF
${NS}_${CMD}() { apiCall${METHOD}${PAYLOAD}${FORM} '${ENDPOINT}' "\$@" ; }
rde ${NS}_${CMD} "${!TITLE}" "${!DESCRIPTION}" "${!EXAMPLE}"\n
ASDF
        fi

      echo -en "${OUTPUT}" >> temp.sh
    done;
    POSTMAN=${POSTMAN%,}
    POSTMAN+="]},"
  done;
  POSTMAN=${POSTMAN%,}
  echo -en "${POSTMAN}]\n}" > postman-collection.json
}
