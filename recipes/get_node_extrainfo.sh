#!/usr/bin/env bash

################################################################################
# Gets extra node info from an applications node list
#
#   NB; review SOURCE_API_NODEINFO setup, for version of controller
#
# Useful output lines for debug;
#   echo "lines: ${#app_list_array[@]} | entries: ${#app_array[@]}"
#   for key in "${!app_array[@]}"; do echo "key   : $key"; echo "value : ${app_array[$key]}"; done
################################################################################

usage () {
    echo "
        Usage:
            $0 [params]

        Params;
            -E [name]      The ACT environment name (Mandatory)
            -L [0|1]       Whether to run for a single app (0) or 
                            whole controller (1)
            -A [999]       Application ID you want to run for
                            only required if LEVEL is set to 0
            -S [0|1]       Input type, controller (0) or file (1)
            -D [0|1]       Output type, stdout (0) or file (1)
            -O [path]      Where source and dest files reside
                            Required if SOURCE or DEST is 1

        Defaults;
            L=0
            S=0
            D=0
            O=(recipes folder)

        Examples;
            ./get_node_extrainfo.sh -E prod -A 123
            ./get_node_extrainfo.sh -E prod -L 1
            ./get_node_extrainfo.sh -E prod -L 1 -D 1"

}

################################################################################
# Setup Variables, etc
################################################################################
# RESTUI API call
# TODO: Find exact version api calls changed
# NB; this api call is valid on > mid-4.5 controller...
SOURCE_API_NODEINFO="/controller/restui/v1/nodes/list/health/ids"
# ...before which it was
#SOURCE_API_NODEINFO="/controller/restui/nodes/list/health/ids"

# Set default input params
LEVEL="0" #This means -A is mandatory unless -L is changed
SOURCE="0"
DEST="0"
IO_FILE_PATH=$(dirname "${BASH_SOURCE[0]}")

# Declare the global variables
declare APP_IDS
declare NODE_IDS
declare APP_SOURCE
declare NODE_SOURCE
declare NODEINFO_SOURCE
# ...and global arrays
declare -a app_list_array
declare -A app_array
declare -a node_list_array
declare -A node_array
declare -a nodeinfo_list_array
declare -A nodeinfo_array
declare -A output_array

# Set up some time variables, to use for time ranged calls
#   Default to last 1 hour with these values
TIME_ZERO="$(date +%s)"
TIME_END="${TIME_ZERO}000"
TIME_START="$((${TIME_ZERO}-3600))000"

# Read input params
while getopts ":E:L:A:S:D:O:" opt "$@"; do
    case "${opt}" in
        E)
            ENVIRONMENT="${OPTARG}"
            ;;
        L)
            LEVEL="${OPTARG}"
            ;;
        A)
            APP_ID="${OPTARG}"
            ;;
        S)
            SOURCE="${OPTARG}"
            ;;
        D)
            DEST="${OPTARG}"
            ;;
        O)
            IO_FILE_PATH="${OPTARG}"
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
#ENVIRONMENT="prod"
#LEVEL="1"
#APP_ID="100"
#SOURCE="1"
#DEST="1"
#IO_FILE_PATH="${IO_FILE_PATH}/../~scratch"


################################################################################
# Start of functions
################################################################################

# Checks
runChecks () {
    # If we didnt get an ENVIRONMENT, we cant continue
    if [[ -z ${ENVIRONMENT} ]]; then echo "No -E param passed."; usage; exit 1; fi
    # If we have an app LEVEL, but no APP_ID, we cant continue
    if [[ ${LEVEL} == "0" && -z ${APP_ID} ]]; then echo "No -A param passed for -L=0."; usage;  exit 1; fi
}

# Setup our data sources
setupSources () {
    # Filenames for input, if SOURCE=1
    # APP0/APP1 is for LEVEL (app/controller) variances
    SOURCE_FILE_APP0="app.txt"
    SOURCE_FILE_APP1="app_list.txt"
    SOURCE_FILE_NODE="node_list.txt"
    SOURCE_FILE_NODEINFO="node_info.txt"
    # File for output if DEST=1
    OUTPUT_FILE="${TIME_ZERO}-E${ENVIRONMENT}-L${LEVEL}-S${SOURCE}.csv"

    # Where are we getting the data from, either...
    # ...controller, via calls
    # ...exported file, from previous controller run
    # Managed by the SOURCE & LEVEL param
    if [[ ${SOURCE} == "0" && ${LEVEL} == "0" ]]; then 
        APP_SOURCE="../act.sh -E ${ENVIRONMENT} application get -a ${APP_ID}"
    elif [[ ${SOURCE} == "1" && ${LEVEL} == "0" ]]; then 
        APP_SOURCE="cat ${IO_FILE_PATH}/${SOURCE_FILE_APP0}"
    elif [[ ${SOURCE} == "0" && ${LEVEL} == "1" ]]; then 
        APP_SOURCE="../act.sh -E ${ENVIRONMENT} application list"
    elif [[ ${SOURCE} == "1" && ${LEVEL} == "1" ]]; then 
        APP_SOURCE="cat ${IO_FILE_PATH}/${SOURCE_FILE_APP1}"
    fi

    if [[ ${SOURCE} == "1" ]]; then NODE_SOURCE="cat ${IO_FILE_PATH}/${SOURCE_FILE_NODE}"; fi
}

# Setup some sources that require data not available at start
setInFlightSources () {
    if [[ ${SOURCE} == "0" ]]; then NODE_SOURCE="../act.sh -E ${ENVIRONMENT} node list -a ${APP_ID}"; fi

    if [[ ${SOURCE} == "0" ]]; then 
        NODEINFO_SOURCE="../act.sh -E ${ENVIRONMENT} controller call -X POST -d {\"requestFilter\":[${NODE_IDS}],\"resultColumns\":[\"VM_RUNTIME_VERSION\"],\"timeRangeStart\":${TIME_START},\"timeRangeEnd\":${TIME_END}} ${SOURCE_API_NODEINFO}"
    elif [[ ${SOURCE} == "1" ]]; then 
        NODEINFO_SOURCE="cat ${IO_FILE_PATH}/${SOURCE_FILE_NODEINFO}"
    fi
}

# Clear down node related info
resetVars () {
    NODE_IDS=""
    NODE_LIST=""
    unset node_list_array
    unset node_array

    NODEINFO_LIST=""
    unset nodeinfo_list_array
    unset nodeinfo_array
}


################################################################################
# XML and JSON parsing functions
################################################################################

# Function to read XML and pull tags (ENTITY) and values (CONTENT)
#   Using this to remove dependancy on non-standard utils
read_xml () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

# Parse the APP XML, just for IDs
parse_xml_app_ids () {
    while read_xml; do 
        if [[ ${ENTITY} == "id" ]]; then echo "${CONTENT}"; fi
    done <<< "$(${APP_SOURCE})"
}

# Parse the APP XML
parse_xml_app_list () {
    while read_xml; do 
        if [[ ${ENTITY} == "id" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "name" ]]; then echo "${CONTENT}"; fi
    done <<< "$(${APP_SOURCE})"
}

# Parse the NODE XML, just for IDs
parse_xml_node_ids () {
    while read_xml; do
        if [[ ${ENTITY} == "id" ]]; then echo "${CONTENT},"; fi
    done <<< "$(${NODE_SOURCE})"
}

# Parse the NODE XML
parse_xml_node_list () {
    while read_xml; do
        if [[ ${ENTITY} == "id" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "name" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "tierName" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "machineName" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "machineOSType" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "machineAgentPresent" && ${CONTENT} = "false" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "appAgentPresent" && ${CONTENT} = "false" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "machineAgentVersion" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "appAgentVersion" ]]; then echo "${CONTENT}"; fi
        if [[ ${ENTITY} == "agentType" ]]; then echo "${CONTENT}"; fi
    done <<< "$(${NODE_SOURCE})"
}

# Parse the NODEINFO JSON
parse_json_nodeinfo_list () {
    while read line; do
        if [[ ${line} =~ \"nodeId\"[[:space:]]*:[[:space:]]*(.*),$ ]]; then echo "${BASH_REMATCH[1]}"; fi
        if [[ ${line} =~ \"jvmVersion\"[[:space:]]*:[[:space:]]*(.*),$ ]]; then echo "${BASH_REMATCH[1]}"; fi
        if [[ ${line} =~ \"appServerRestartDate\"[[:space:]]*:[[:space:]]*(.*),$ ]]; then echo "${BASH_REMATCH[1]}"; fi
    done <<< "$(${NODEINFO_SOURCE})"
}


################################################################################
# Output functions
################################################################################

outputHeader () {
    # Output variables used
    echo "ENVIRONMENT: ${ENVIRONMENT} | LEVEL: ${LEVEL} | APP_ID: ${APP_ID} | SOURCE: ${SOURCE} | DEST: ${DEST}"
    # Output header line
    if [[ ${DEST} == "0" ]]; then 
        echo "appId,appName,nodeId,nodeName,tierName,machineName,machineOSType,machineAgentVersion,appAgentVersion,agentType,jvmVersion,appServerRestartDate"
    elif [[ ${DEST} == "1" ]]; then 
        echo "appId,appName,nodeId,nodeName,tierName,machineName,machineOSType,machineAgentVersion,appAgentVersion,agentType,jvmVersion,appServerRestartDate" >> "${IO_FILE_PATH}/${OUTPUT_FILE}"
    fi
    
}

# Output the data to stdout or file
outputData () {
    for node in "${!node_array[@]}"; do
        if [[ ${DEST} == "0" ]]; then 
            echo "${APP_ID},${app_array[${APP_ID}]},${node},${node_array[${node}]},${nodeinfo_array[${node}]}"
        elif [[ ${DEST} == "1" ]]; then 
            echo "${APP_ID},${app_array[${APP_ID}]},${node},${node_array[${node}]},${nodeinfo_array[${node}]}" >> ${IO_FILE_PATH}/${OUTPUT_FILE}
        fi
    done
    
    # And reset node data for next run
    resetVars
}


################################################################################
# GetData functions
################################################################################

# Get application data
getAppData () {
    # Produce list of App IDs - to use for calling getNodeIDs
    APP_IDS=$(parse_xml_app_ids)

    # Produce list of App data fields (id and name) - to build output file
    APP_LIST=$(parse_xml_app_list)

    # Import APP_LIST into app_list_array using IFS
    IFS=$'\r\n' GLOBIGNORE='*' command eval 'app_list_array=(${APP_LIST})'

    # Loop through the list array
    app_count=0
    while [ ${app_count} -lt ${#app_list_array[@]} ] ; do
        # Add new array entry
        app_array+=([${app_list_array[${app_count}]}]=${app_list_array[${app_count} + 1]})
        # Jump the number of fields we have in each 'row'
        app_count=$(($app_count + 2))
    done
}

# Get all node ids for an application id
getNodeIDs () {
    setInFlightSources

    # Produce csv list of Node IDs - for use for calling getNodeInfo
    NODE_IDS=$(parse_xml_node_ids | tr -d '\n' | sed -e "s/,$//")

    # Produce list of Node data fields (8 currently) - to build output file
    NODE_LIST=$(parse_xml_node_list)

    # Import NODE_LIST into node_list_array using IFS
    IFS=$'\r\n' GLOBIGNORE='*' command eval 'node_list_array=(${NODE_LIST})'

    # Loop through the list array
    node_count=0
    while [ ${node_count} -lt ${#node_list_array[@]} ] ; do
        # Add new array entry
        node_array+=([${node_list_array[${node_count}]}]=${node_list_array[${node_count} + 1]},${node_list_array[${node_count} + 2]},${node_list_array[${node_count} + 3]},${node_list_array[${node_count} + 4]},${node_list_array[${node_count} + 5]},${node_list_array[${node_count} + 6]},${node_list_array[${node_count} + 7]})
        # Jump the number of fields we have in each 'row'
        node_count=$(($node_count + 8))
    done
}

# Get all node extra info for a list of node ids
getNodeInfo () {
    setInFlightSources

    # Produce list of NodeInfo data fields (3 currently) - to build output file
    NODEINFO_LIST=$(parse_json_nodeinfo_list)

    # Import NODEINFO_LIST into nodeinfo_list_array using IFS
    IFS=$'\r\n' GLOBIGNORE='*' command eval 'nodeinfo_list_array=(${NODEINFO_LIST})'

    # Loop through the list array
    nodeinfo_count=0
    while [ ${nodeinfo_count} -lt ${#nodeinfo_list_array[@]} ] ; do
        # Add new array entry
        nodeinfo_array+=([${nodeinfo_list_array[${nodeinfo_count}]}]=${nodeinfo_list_array[${nodeinfo_count} + 1]},${nodeinfo_list_array[${nodeinfo_count} + 2]})
        # Jump the number of fields we have in each 'row'
        nodeinfo_count=$(($nodeinfo_count + 3))
    done
}


################################################################################
################################################################################
# MAIN CODE 
################################################################################
################################################################################

# Lets get ready
runChecks
setupSources

# Output header line
outputHeader

# Run based on whether we are APP or CONTROLLER level
case $LEVEL in
    0) # Run at APP Level
        getAppData
        getNodeIDs
        getNodeInfo
        outputData
        ;;
    1) # Run at CONTROLLER level
        getAppData
        # Iterate through the apps obtained
        for app in "${!app_array[@]}"; do 
            APP_ID=${app}
            getNodeIDs
            getNodeInfo
            outputData
        done
        ;;
esac
