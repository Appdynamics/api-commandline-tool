#!/bin/bash

function controller_version {
  controller_call -X GET /controller/rest/serverstatus
  COMMAND_RESULT=`echo -e $COMMAND_RESULT | sed -n -e 's/.*Controller v\(.*\) Build.*/\1/p'`
}

register controller_version Get installed version from controller
