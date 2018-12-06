#!/bin/bash

function actiontemplate_createmediatype {
  apiCall -X POST -d '{"name":"${n}","builtIn":false}' '/controller/restui/httpaction/createHttpRequestActionMediaType' "$@"
}

register actiontemplate_createmediatype "Create a custom media type"

describe actiontemplate_createmediatype << EOF
Create a custom media type. Provide the name of the media type as parameter (-n)
EOF

example actiontemplate_createmediatype << EOF
-n 'application/vnd.appd.events+json'
EOF
