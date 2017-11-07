#!/bin/bash

function apiCall {
  local OPTS

  while getopts "X:d:" opt "$@";
  do
    case "${opt}" in
      X)
	      METHOD=${OPTARG}
      ;;
      d)
        PAYLOAD=${OPTARG}
      ;;
    esac
  done
  shiftOptInd
  shift $SHIFTS

  ENDPOINT=$1
  debug "Unparsed endpoint is $ENDPOINT"
  debug "Unparsed payload is $PAYLOAD"
  shift

  OLDIFS=$IFS
  IFS="\$"
  for MATCH in $PAYLOAD ; do
    if [ "${MATCH::1}" = "{" ] && [ "${MATCH:2:1}" = "}" ] ; then
      MATCH=${MATCH:1}
      OPT=${MATCH%%\}*}:
      OPTS="${OPTS}${OPT}"
    fi
  done;

  for MATCH in $ENDPOINT ; do
    if [ "${MATCH::1}" = "{" ] && [ "${MATCH:2:1}" = "}" ] ; then
      MATCH=${MATCH:1}
      OPT=${MATCH%%\}*}:
      OPTS="${OPTS}${OPT}"
    fi
  done;
  IFS=$OLDIFS

  if [ -n "$OPTS" ] ; then
    while getopts ${OPTS} opt;
    do
      PAYLOAD=${PAYLOAD//\$\{$opt\}/$OPTARG}
      ENDPOINT=${ENDPOINT//\$\{$opt\}/$OPTARG}
    done
    shiftOptInd
    shift $SHIFTS
  fi

  while [[ $PAYLOAD =~ \${[^}]*} ]] ; do
    if [ -z "$1" ] ; then
      error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
      return;
    fi
    PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$1}
    shift
  done

  while [[ $ENDPOINT =~ \${[^}]*} ]] ; do
    if [ -z "$1" ] ; then
      error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
      return;
    fi
    ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$1}
    shift
  done

  debug "Call Controller: -X $METHOD -d $PAYLOAD $ENDPOINT"
  if [ -n "$PAYLOAD" ] ; then
    echo -X $METHOD -d $PAYLOAD $ENDPOINT
  else
    echo -X $METHOD $ENDPOINT
  fi
}

# __call GET "/controller/rest/applications/\${a}/business-transactions" -a ECommerce
# echo "########"
# __call GET "/controller/rest/applications/\${a}/nodes/\${n}" -n Web2 -a ECommerce
