#!/usr/bin/env bash

################################################################################
# Bulk updates health rules on congtroller
#
# NB;
#     Various HR types have varying patterns of 'field' names
#     HR String (-H) is used in a 'contains' match
#     Patterns (-X, -Y) are regex, be sure to escape as required
#
# WARNING;
#     Not adding a -H flag will pull ALL HRs !!!
################################################################################

usage() {
  echo "
        Usage:
            $0 [params]

        Params;
            -E [string]    The ACT environment name (Mandatory)
            -A [number]    Application ID you want to run for
            -H [string]    String for health rule matching
            -X [pattern]   Pattern to match in health rule output
            -Y [pattern]   Value to change pattern to

        Examples;
            ./update_healthrule_bulk.sh -E prod -A 123 -H "CPU Utilisation" -X "\"evaluateToTrueOnNoData\":false" -Y "\"evaluateToTrueOnNoData\":true"
            ./update_healthrule_bulk.sh -E prod -A 123 -X "\"evaluateToTrueOnNoData\":false" -Y "\"evaluateToTrueOnNoData\":true"
  "
}

################################################################################
# Setup Variables, etc
################################################################################

# Read input params
while getopts ":E:A:H:X:Y:" opt "$@"; do
  case "${opt}" in
  E)
    ENVIRONMENT="${OPTARG}"
    ;;
  A)
    APPID="${OPTARG}"
    ;;
  H)
    HRSTRING="${OPTARG}"
    ;;
  X)
    PATTERNIN="${OPTARG}"
    ;;
  Y)
    PATTERNOUT="${OPTARG}"
    ;;
  :)
    usage
    exit 1
    ;;
  *)
    echo "Invalid flag ${OPTARG}, exiting..."
    exit 1
    ;;
  esac
done

# Override params
# ENVIRONMENT=""
# APPID=""
# HRSTRING=""
# PATTERNIN=""
# PATTERNOUT=""

################################################################################
# Start of functions
################################################################################

# Checks
runChecks() {
  # If we didnt get an ENVIRONMENT, we cant continue
  if [[ -z ${ENVIRONMENT} ]]; then
    echo "No -E param passed."
    usage
    exit 1
  fi
  # If we didnt get an APPID, we cant continue
  if [[ -z ${APPID} ]]; then
    echo "No -A param passed."
    usage
    exit 1
  fi
  # If we didnt get any PATTERNs, we cant continue
  if [[ -z ${PATTERNIN} || -z ${PATTERNOUT} ]]; then
    echo "No -X or -Y param passed."
    usage
    exit 1
  fi
}

# Clear down node related info
resetVars() {
  HEATHRULEURI=""
  HROUTPUT=""
  HROUTPUTCHECK=""
  HROUTPUTUPDATED=""
  HRPUTRESPONSE=""
  HRPUTRESPONSECHECK=""
}

################################################################################
# GetData functions
################################################################################

# Get health rule data
getHRLIST() {
  # Perform a Login to get tokens
  echo "----------------------------------------------------------------------------"
  echo "Performing login to controller in environment: ${ENVIRONMENT}"
  LOGINRESPONSE=$(../act.sh -E ${ENVIRONMENT} controller call -X GET /controller/auth?action=login)
  echo "  ${LOGINRESPONSE}"

  echo "----------------------------------------------------------------------------"
  echo "Getting list of health rule IDs;"
  # If we dont have a HR pattern to match
  if [[ -z ${HRSTRING} ]]; then
    # Get ALL HRs !!!
    echo "  No -H param, getting ALL HR"
    HRLIST=$(../act.sh -E ${ENVIRONMENT} healthrule list -a ${APPID} | jq -r '.[] | .id')
  else
    echo "  -H '${HRSTRING}', getting matching HRs"
    # Get list if HR IDs matching HRSTRING
    HRLIST=$(../act.sh -E ${ENVIRONMENT} healthrule list -a ${APPID} | jq -r --arg PATTERN "${HRSTRING}" '.[] | select(.name | contains($PATTERN)) | "\(.id), \(.name)"')
  fi
  echo "${HRLIST}"
  echo "----------------------------------------------------------------------------"
}

# Update each health rule
updateHRData() {
  echo "Starting HR updates"

  # Reset our vars and carry on
  resetVars

  OLDIFS=$IFS
  IFS=$'\r\n'

  #  Iterate through HR list
  for HRITEM in $HRLIST; do
    HRID=$(echo ${HRITEM} | cut -d "," -f1)
    echo "Updating ${HRID}..."
    # Set our URI for getting/updating current HR
    HEATHRULEURI="/controller/alerting/rest/v1/applications/${APPID}/health-rules/${HRID}"
    # GET our HR json
    HROUTPUT=$(../act.sh -E ${ENVIRONMENT} controller call -X GET ${HEATHRULEURI})

    # Do we see the PATTERNIN in our HR?
    HROUTPUTCHECK=$(echo ${HROUTPUT} | grep -E "${PATTERNIN}")
    if [[ -z ${HROUTPUTCHECK} ]]; then
      echo "         No pattern match found in health rule, skipping any changes..."
      continue
    else
      # Update the HR json
      HROUTPUTUPDATED=$(echo "${HROUTPUT}" | sed -r "s|${PATTERNIN}|${PATTERNOUT}|g")
      # PUT our HR json back
      HRPUTRESPONSE=$(../act.sh -E ${ENVIRONMENT} controller call -X PUT -d "${HROUTPUTUPDATED}" ${HEATHRULEURI})
      HRPUTRESPONSECHECK=$(echo ${HRPUTRESPONSE} | grep -E "\"id\":${HRID},")
      if [[ ${HRPUTRESPONSECHECK} ]]; then
        echo "         Updated"
      else
        echo "         Error"
      fi
    fi
  done

  IFS=$OLDIFS

  echo "----------------------------------------------------------------------------"
  echo "Completed HR updates"
  echo "----------------------------------------------------------------------------"
}

################################################################################
################################################################################
# MAIN CODE
################################################################################
################################################################################

# Lets get ready
runChecks

# Lets go
getHRLIST
updateHRData
