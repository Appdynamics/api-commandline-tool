#!/bin/bash

function controller_status {
  controller_call -X GET /controller/rest/serverstatus
}

register controller_status Get server status from controller
