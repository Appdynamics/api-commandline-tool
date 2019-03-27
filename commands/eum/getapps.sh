#!/bin/bash

eum_getapps() {
  apiCall  "/controller/restui/eumApplications/getAllEumApplicationsData?time-range=last_1_hour.BEFORE_NOW.-1.-1.60"
}

register eum_getapps Get EUM App Keys
describe eum_getapps << EOF
Get EUM Apps.
EOF
