#!/bin/bash

function apiCall {
  local OPTS
  local OPTIONAL_OPTIONS=""
  local OPTS_TYPES=()
  local METHOD="GET"
  local WITH_FORM=0
  local PAYLOAD

  while getopts "X:d:F:" opt "$@";
  do
    case "${opt}" in
      X)
	    METHOD=${OPTARG}
      ;;
      d)
        PAYLOAD=${OPTARG}
      ;;
      F)
        PAYLOAD=${OPTARG}
        WITH_FORM=1
      ;;
    esac
  done
  shiftOptInd
  shift $SHIFTS

  ENDPOINT=$1
  debug "Unparsed endpoint is $ENDPOINT"
  debug "Unparsed payload is $PAYLOAD"
  shift

  ## Special replacements for {{controller_account}} and {{controller_url}}
  ## (This is currently used by federation_establish)
  local ACCOUNT=${CONFIG_CONTROLLER_CREDENTIALS##*@}
  ACCOUNT=${ACCOUNT%%:*}
  local ACCOUNT_PATTERN="{{controller_account}}"
  local CONTROLLER_URL_PATTERN="{{controller_url}}"
  PAYLOAD=${PAYLOAD//${ACCOUNT_PATTERN}/${ACCOUNT}}
  PAYLOAD=${PAYLOAD//${CONTROLLER_URL_PATTERN}/${CONFIG_CONTROLLER_HOST}}


  OLDIFS=$IFS
  IFS="{{"
  for MATCH in $PAYLOAD ; do
    if [[ $MATCH =~ ([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      OPTS_TYPES+=(${BASH_REMATCH[1]}${BASH_REMATCH[2]})
      if [ "${BASH_REMATCH[3]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;

  for MATCH in $ENDPOINT ; do
    if [[ $MATCH =~ ([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]]; then
      OPT=${BASH_REMATCH[1]}:
      OPTS_TYPES+=(${BASH_REMATCH[1]}${BASH_REMATCH[2]})
      if [ "${BASH_REMATCH[3]}" = "?" ] ; then
        OPTIONAL_OPTIONS=${OPTIONAL_OPTIONS}${OPT}
      fi
      OPTS="${OPTS}${OPT}"
    fi
  done;
  IFS=$OLDIFS

  debug "Identified Options: ${OPTS}"
  debug "Identified Types: ${OPTS_TYPES[*]}"
  debug "Optional Options: $OPTIONAL_OPTIONS"

  if [ -n "$OPTS" ] ; then
    while getopts ${OPTS} opt;
    do
      local ARG=`urlencode "$OPTARG"`
      debug "Applying $opt with $ARG"
      # PAYLOAD=${PAYLOAD//\$\{${opt}\}/$OPTARG}
      # ENDPOINT=${ENDPOINT//\$\{${opt}\}/$OPTARG}
      while [[ $PAYLOAD =~ \{\{$opt(:[a-zA-Z0-9_-]+)?\??\}\} ]] ; do
        PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$OPTARG}
      done;
      while [[ $ENDPOINT =~ \{\{$opt(:[a-zA-Z0-9_-]+)?\??\}\} ]] ; do
        ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$ARG}
      done;
    done
    shiftOptInd
    shift $SHIFTS
  fi

  while [[ $PAYLOAD =~ \{\{([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      if [ "${MISSING}" == "a" ] && [ -n "${CONFIG_CONTROLLER_DEFAULT_APPLICATION}" ] ; then
        ENDPOINT=${ENDPOINT//'{{a}}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
      else
        error "Please provide an argument for paramater -${BASH_REMATCH:2:1}"
        return;
      fi
    fi
    PAYLOAD=${PAYLOAD//${BASH_REMATCH[0]}/$1}
    shift
  done

  while [[ $ENDPOINT =~ \{\{([a-zA-Z])(:[a-zA-Z0-9_-]+)?(\??)\}\} ]] ; do
    if [ -z "$1" ] && [[ "${OPTIONAL_OPTIONS}" != *"${BASH_REMATCH[1]}"* ]] ; then
      local MISSING=${BASH_REMATCH:2:1}
      if [ "${MISSING}" == "a" ] && [ -n "${CONFIG_CONTROLLER_DEFAULT_APPLICATION}" ] ; then
        debug "Using default application for -a: ${CONFIG_CONTROLLER_DEFAULT_APPLICATION}"
        ENDPOINT=${ENDPOINT//'{{a}}'/${CONFIG_CONTROLLER_DEFAULT_APPLICATION}}
      else
        ERROR_MESSAGE="Please provide an argument for parameter -${MISSING}"
        for TYPE in "${OPTS_TYPES[@]}" ;
        do
          if [[ "${TYPE}" == ${MISSING}:* ]] ; then
            TYPE=${TYPE//_/ }
            ERROR_MESSAGE="Missing ${TYPE#*:}: ${ERROR_MESSAGE}"
          fi
        done;
        error "${ERROR_MESSAGE}"
        return;
      fi
    fi
    local ARG=`urlencode "$1"`
    debug "Applying ${BASH_REMATCH[0]} with $ARG"
    ENDPOINT=${ENDPOINT//${BASH_REMATCH[0]}/$ARG}
    shift
  done

  local CONTROLLER_ARGS=()

  if [[ "${ENDPOINT}" == */controller/rest/* ]] || [[ "${ENDPOINT}" == */controller/transactiondetection/* ]] ; then
    CONTROLLER_ARGS+=("-B")
    debug "Using basic http authentication"
  fi;

  if [ -n "$PAYLOAD" ] ; then
    if [ "${PAYLOAD:0:1}" = "@" ] ; then
      debug "Loading payload from file ${PAYLOAD:1}"
      if [ -r "${PAYLOAD:1}" ] ; then
        PAYLOAD=$(<${PAYLOAD:1})
      else
        COMMAND_RESULT=""
        error "File not found or not readable: ${PAYLOAD:1}"
        exit
      fi
    fi
  fi;

  debug "With form: ${WITH_FORM}"
  if [ "${WITH_FORM}" -eq 1 ] ; then
    CONTROLLER_ARGS+=("-F" "${PAYLOAD}")
  else
    CONTROLLER_ARGS+=("-d" "${PAYLOAD}")
  fi

  CONTROLLER_ARGS+=("-X" "${METHOD}" "${ENDPOINT}")

  debug "Call Controller with ${CONTROLLER_ARGS[*]}"
  controller_call "${CONTROLLER_ARGS[@]}"
}
