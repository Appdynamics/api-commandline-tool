#!/bin/bash
doc environment << EOF
If you want to use ${SCRIPTNAME} to manage multiple controllers, you can use environments to add and manage them easily.
Use \`${SCRIPTNAME} environment add\` to create an environment providing a name, controller url and credentials.
Afterwards you can use \`${SCRIPTNAME} -E <name>\` to call the given controller.
EOF
