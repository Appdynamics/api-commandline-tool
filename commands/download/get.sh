#!/bin/bash

download_get() {
  local WORKING_DIRECTORY="."
  local DOWNLOAD_DRYRUN=0
  local DOWNLOAD_ALL_MATCHES=0
  local DOWNLOAD_FILTER=""
  local SEARCH=""
  local WITHSEARCH=""
  while getopts "Aard:s:" opt "$@";
  do
    case "${opt}" in
      d)
        WORKING_DIRECTORY=${OPTARG}
      ;;
      r)
        DOWNLOAD_DRYRUN=1
      ;;
      s)
        WITHSEARCH="-s"
        SEARCH="${OPTARG}"
        DOWNLOAD_FILTER='.*'
      ;;
      a)
        DOWNLOAD_ALL_MATCHES=1
      ;;
      A)
        DOWNLOAD_ALL_MATCHES=1
        DOWNLOAD_FILTER='.*'
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS

  if [ ! -d ${WORKING_DIRECTORY} ] ; then
    error "${WORKING_DIRECTORY} is not a directory"
    exit 1
  fi;

  if [ "${DOWNLOAD_ALL_MATCHES}" -eq "0" ] ; then
    download_list -f "${1:-${DOWNLOAD_FILTER}}" -1 -d ${WITHSEARCH} "${SEARCH}"
  else
    download_list -f "${1:-${DOWNLOAD_FILTER}}" -d ${WITHSEARCH} "${SEARCH}"
  fi

  # use echo to remove trailing line breaks
  FILES=$COMMAND_RESULT

  COMMAND_RESULT=""

  if [ "$FILES" != "" ]; then
    download_login
    if [ $PORTAL_LOGIN_STATUS -eq 1 ] ; then
      OLD_DIRECTORY=`pwd`
      cd ${WORKING_DIRECTORY} || exit
      for FILE in ${FILES} ; do
        output "Downloading ${FILE} to ${WORKING_DIRECTORY}"
        if [ "${DOWNLOAD_DRYRUN}" -eq "0" ] ; then
          httpClient -L -O -H "Authorization: Bearer ${PORTAL_LOGIN_TOKEN}" "${FILE}"
        else
          output "Dry run."
        fi
      done
      COMMAND_RESULT="Successfully downloaded $(bashBasename ${FILE}) to ${WORKING_DIRECTORY}"
      cd "${OLD_DIRECTORY}" || exit
    fi
  else
    COMMAND_RESULT="No matching agent found."
  fi
}

rde download_get "Download an agent." "You need to provide a partial name of an agent you want to download. Optionally, you can provide a directory (-d) as download location. By default only the first match is downloaded, you can provide parameter -a to download all matches." "-d /tmp golang"
