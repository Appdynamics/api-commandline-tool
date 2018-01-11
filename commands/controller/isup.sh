#!/bin/bash

function controller_isup {
  local START
  local END
  declare -i END
  START=`date +%s`
  controller_ping
  while [ "$COMMAND_RESULT" = "Error" ] ; do
    controller_ping
    sleep 1
  done
  sleep 1
  END=`date +%s`
  END=$END-$START
  COMMAND_RESULT="Controller at $CONFIG_CONTROLLER_HOST up after $END seconds"
}

register controller_isup Pause until controller is up
describe controller_isup << EOF
This command will pause until the controller is up. Use this to get notified after the controller is booted successfully.
EOF
