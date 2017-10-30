#!/bin/bash

function portal_download {
  local VERSION=0
  local OPERATING_SYSTEM=`uname -s`
  local MACHINE_HARDWARE=`uname -m`
  local MACHINE_HARDWARE_BITS=""
  local INSTALLER_SUFFIX=".sh"
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
  local TARGET=$*
  if [ $VERSION = "0" ] ; then
    controller_version
    VERSION=$COMMAND_RESULT
  fi
  local FILE=""

  case "$OPERATING_SYSTEM" in
    Darwin|darwin|OSX|osx)
      OPERATING_SYSTEM="osx"
      INSTALLER_SUFFIX=".dmg"
    ;;
    linux|Linux)
      OPERATING_SYSTEM="linux"
      INSTALLER_SUFFIX=".sh"
    ;;
    SunOS)
      OPERATING_SYSTEM="solaris-sparc"
      INSTALLER_SUFFIX=".sh"
    ;;
    Windows|windows|win)
    OPERATING_SYSTEM="windows"
    INSTALLER_SUFFIX=".msi"
    ;;
  esac

  case "$MACHINE_HARDWARE" in
    64bit|x86_64|64)
      MACHINE_HARDWARE="x64"
      MACHINE_HARDWARE_BITS="64bit"
    ;;
    32bit|i686)
      MACHINE_HARDWARE="x32"
      MACHINE_HARDWARE_BITS="32bit"
    ;;
  esac

  case "$TARGET" in
    java*)
      FILE="sun-jvm/$VERSION/AppServerAgent-$VERSION.zip"
    ;;
    universal*)

      FILE="universal-agent/$VERSION/universal-agent-$MACHINE_HARDWARE-$OPERATING_SYSTEM-$VERSION.zip"
    ;;
    machine*)

      FILE="machine-bundle/$VERSION/machineagent-bundle-$MACHINE_HARDWARE_BITS-$OPERATING_SYSTEM-$VERSION.zip"
    ;;
    controller)
      FILE="controller/$VERSION/controller_${MACHINE_HARDWARE_BITS}_$OPERATING_SYSTEM-$VERSION$INSTALLER_SUFFIX"
    ;;
    file*)
      shift
      FILE=$*
    ;;
    *)
      COMMAND_RESULT="Unknown agent type: $TARGET"
    ;;
  esac

  if [ "$FILE" != "" ]; then
    portal_login
    if [ $PORTAL_LOGIN_STATUS -eq 1 ] ; then
      info "Downloading https://download.appdynamics.com/download/prox/download-file/$FILE"
      httpClient -O -b $CONFIG_PORTAL_COOKIE_LOCATION https://download.appdynamics.com/download/prox/download-file/$FILE
    fi
  fi
}

register portal_download Download an appdynamics agent
describe portal_download << EOF
Download an appdynamics agent
EOF
