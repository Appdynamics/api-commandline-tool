#!/bin/bash

function actiontemplate_export {
  apiCall -X GET '/controller/actiontemplate/${t}/ ' "$@"
}

register actiontemplate_export "Export all templates of a given type (-t email or httprequest)"

describe actiontemplate_export << EOF
Export all templates of a given type (-t email or httprequest)
EOF
