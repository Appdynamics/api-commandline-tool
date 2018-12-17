#!/bin/bash

function federation_establish {
  local ACCOUNT=${CONFIG_CONTROLLER_CREDENTIALS##*@}
  ACCOUNT=${ACCOUNT%%:*}
  info "Establishing friendship..."
  apiCall -X POST -d "{ \
    \"accountName\": \"${ACCOUNT}\", \
    \"controllerUrl\": \"${CONFIG_CONTROLLER_HOST}\", \
    \"friendAccountName\": \"{{a}}\", \
    \"friendAccountApiKey\": \"{{k}}\", \
    \"friendAccountControllerUrl\": \"{{c}}\" \
  }" "/controller/rest/federation/establishmutualfriendship" "$@"
}

register federation_establish Establish Mutual Friendship
describe federation_establish << EOF
Establish Mutual Friendship
EOF
