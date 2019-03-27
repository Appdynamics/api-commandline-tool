#!/bin/bash

httpClient() {
 local TIMEOUT=10
 if [ -n "$CONFIG_HTTP_TIMEOUT" ] ; then
   TIMEOUT=$CONFIG_HTTP_TIMEOUT
 fi
 debug "curl -L --connect-timeout ${TIMEOUT} $*"
 curl -L --connect-timeout ${TIMEOUT} "$@"
}
