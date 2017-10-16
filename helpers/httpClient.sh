#!/bin/bash

function httpClient {
 curl -L --connect-timeout 10 "$@"
}
