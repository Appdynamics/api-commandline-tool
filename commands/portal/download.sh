#!/bin/bash

function portal_download {
  local VERSION=0
  local OPERATING_SYSTEM=`uname -s`
  local MACHINE_HARDWARE=`uname -m`
  while getopts "v:s:m:" opt "$@";
  do
    case "${opt}" in
      v)
        VERSION=${OPTARG}
      ;;
      s)
        OPERATING_SYSTEM=${OPTARG}
      ;;
      m)
        MACHINE_HARDWARE=${OPTARG}
      ;;
    esac
  done;
  shiftOptInd
  shift $SHIFTS
  local AGENT=$*
  if [ $VERSION = "0" ] ; then
    controller_version
    VERSION=$COMMAND_RESULT
  fi
  local FILE=""
  case "$AGENT" in
    java*)
      FILE="sun-jvm/$VERSION/AppServerAgent-$VERSION.zip"
    ;;
    universal*)
      if [[ "${MACHINE_HARDWARE/64}" != "$MACHINE_HARDWARE" ]]; then
        MACHINE_HARDWARE="x64"
      else
        MACHINE_HARDWARE="x32"
      fi
      FILE="universal-agent/$VERSION/universal-agent-x32-$OPERATING_SYSTEM-$VERSION.zip"
    ;;
    machine*)
      if [[ "${MACHINE_HARDWARE/64}" != "$MACHINE_HARDWARE" ]]; then
        MACHINE_HARDWARE="64bit"
      else
        MACHINE_HARDWARE="32bit"
      fi
      case "$OPERATING_SYSTEM" in
        Darwin)
          OPERATING_SYSTEM="osx"
        ;;
        Linux)
          OPERATING_SYSTEM="linux"
        ;;
        SunOS)
          OPERATING_SYSTEM="solaris-sparc"
        ;;
      esac
      FILE="machine-bundle/$VERSION/machineagent-bundle-$MACHINE_HARDWARE-$OPERATING_SYSTEM-$VERSION.zip"
    ;;
    *)
      COMMAND_RESULT="Unknown agent type: $AGENT"
    ;;
  esac

  if [ "$FILE" != "" ]; then
    #portal_login
    echo -O -b $CONFIG_PORTAL_COOKIE_LOCATION https://download.appdynamics.com/download/prox/download-file/$FILE
  fi
}

register portal_download Download an appdynamics agent
describe portal_download << EOF
Download an appdynamics agent
EOF
