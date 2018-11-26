#!/bin/bash

function node_markhistorical {
  apiCall -X POST '/controller/rest/mark-nodes-historical?application-component-node-ids=${n}' "$@"
}

register node_markhistorical Mark Nodes as Historical

describe node_markhistorical << EOF
Mark Nodes as Historical. Provide a comma separated list of node ids.
EOF
