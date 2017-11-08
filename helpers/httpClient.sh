#!/bin/bash

function httpClient {
 debug "$*"
 local TIMEOUT=10
 if [ -n "$CONFIG_HTTP_TIMEOUT" ] ; then
   TIMEOUT=$CONFIG_HTTP_TIMEOUT
 fi
 curl -L --connect-timeout $TIMEOUT "$@"
}
