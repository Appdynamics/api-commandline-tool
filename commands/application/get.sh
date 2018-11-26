#!/bin/bash

function bt_get {
  apiCall '/controller/rest/applications/${a}/business-transactions/${b}' "$@"
}

register bt_get Get an BT by id

describe bt_get << EOF
Get an BT. Provide as parameters bt id (-b) and application id (-a).
EOF
