#!/bin/bash

function timerange_list {
  controller_call -X GET /controller/restui/user/getAllCustomTimeRanges
}

register timerange_list List all custom timeranges available on the controller
