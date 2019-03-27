#!/bin/bash

_usage() {
    # shellcheck disable=SC2034
    read -r -d '' COMMAND_RESULT <<- EOM
Usage: ${USAGE_DESCRIPTION}${EOL}
'${SCRIPTNAME} help' will list available namespaces and subcommands.
See '${SCRIPTNAME} help <namespace>' to read about a specific namespace and the available subcommands
EOM
}

register _usage Display usage information.
