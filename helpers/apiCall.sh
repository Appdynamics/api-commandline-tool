#!/bin/bash

function apiCall {
  local OPTS
  local OPTIONAL_OPTIONS=""
  local METHOD="GET"

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
    if [[ $MATCH =~ \{([a-zA-Z])(\??)\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      if [ "${BASH_REMATCH[2]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;

  for MATCH in $ENDPOINT ; do
    if [[ $MATCH =~ \{([a-zA-Z])(\??)\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      if [ "${BASH_REMATCH[2]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;
  IFS=$OLDIFS

  debug "Identified Options: ${OPTS}"
  debug "Optional Options: $OPTIONAL_OPTIONS"

  if [ -n "$OPTS" ] ; then
    while getopts ${OPTS} opt;
    do
      local ARG=`urlencode "$OPTARG"`
      debug "Applying $opt with $ARG"
      # PAYLOAD=${PAYLOAD//\$\{${opt}\}/$OPTARG}
      # ENDPOINT=${ENDPOINT//\$\{${opt}\}/$OPTARG}
      while [[ $PAYLOAD =~ \$\{$opt\??\} ]] ; do
        PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$OPTARG}
      done;
      while [[ $ENDPOINT =~ \$\{$opt\??\} ]] ; do
        ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$ARG}
      done;
    done
    shiftOptInd
    shift $SHIFTS
  fi

  while [[ $PAYLOAD =~ \$\{([a-zA-Z])(\??)\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      if [ "${MISSING}" == "a" ] && [ -n "${CONFIG_CONTROLLER_DEFAULT_APPLICATION}" ] ; then
        ENDPOINT=${ENDPOINT//'${a}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
      else
        error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
        return;
      fi
    fi
    PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$1}
    shift
  done

  while [[ $ENDPOINT =~ \$\{([a-zA-Z])(\??)\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      if [ "${MISSING}" == "a" ] && [ -n "${CONFIG_CONTROLLER_DEFAULT_APPLICATION}" ] ; then
        ENDPOINT=${ENDPOINT//'${a}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
      else
        error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
        return;
      fi
    fi
    ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$1}
    shift
  done

  debug "Call Controller: -X $METHOD -d $PAYLOAD $ENDPOINT"
  if [ -n "$PAYLOAD" ] ; then

    if [ "${PAYLOAD:0:1}" = "@" ] ; then
      debug "Loading payload from file ${PAYLOAD:1}"
      PAYLOAD=$(<${PAYLOAD:1})
    fi

    controller_call -X $METHOD -d "$PAYLOAD" "$ENDPOINT"
  else
    controller_call -X $METHOD $ENDPOINT
  fi
}
