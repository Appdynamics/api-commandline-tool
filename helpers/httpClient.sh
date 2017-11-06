#!/bin/bash

function httpClient {
 debug "$*"
 curl -L --connect-timeout 10 "$@"
}
