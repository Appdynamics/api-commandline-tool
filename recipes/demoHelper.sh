#!/bin/bash
ACT_ENV="${1}"
APPLICATION_ID="${2}"

function get_header() {
  cat << EOF
[Options]
@include[] = /^https?://.*\.appdynamics\.com(:[0-9]+)?/.*$/
@namespace[] = appdynamics
EOF
}

function get_applications() {
  echo -e "\n[Applications]"
  APPLICATIONS=$(../act.sh -Q -E "${ACT_ENV}" application list | jq -r 'to_entries[] | [.value.id, .value.name] | @tsv')

  IFS=$'\n'
  for APPLICATION in ${APPLICATIONS} ; do
    ID=${APPLICATION%%$'\t'*}
    NAME=${APPLICATION##*$'\t'}
    echo ";${NAME} = "
  done;
  for APPLICATION in ${APPLICATIONS} ; do
    ID=${APPLICATION%%$'\t'*}
    NAME=${APPLICATION##*$'\t'}
    echo ";!hideApplication(${NAME}) = "
  done;
}

function get_bts() {
  echo -e "\n[Business Transactions]"
  BTS=$(../act.sh -Q -E "${ACT_ENV}" bt list -a ${APPLICATION_ID} | jq -r 'to_entries[] | [.value.id, .value.name] | @tsv')

  IFS=$'\n'
  for BT in ${BTS} ; do
    ID=${BT%%$'\t'*}
    NAME=${BT##*$'\t'}
    if [ ${NAME} != '_APPDYNAMICS_DEFAULT_TX_' ] ; then
      echo ";${NAME} = "
    fi;
  done;
  for BT in ${BTS} ; do
    ID=${BT%%$'\t'*}
    NAME=${BT##*$'\t'}
    if [ ${NAME} != '_APPDYNAMICS_DEFAULT_TX_' ] ; then
      echo ";!hideBT(${NAME}) = "
    fi;
  done;
}

function get_flowmap() {
  ../act.sh -E "${ACT_ENV}" flowmap application -a ${1} -t last_2_hours.BEFORE_NOW.-1.-1.720
}

function get_nodes() {
  echo -e "\n[Flowmap.Nodes]"
  NODES=$(echo "${1}" | jq -r '.nodes | .[] | [.name,.idNum] | @tsv')
  IFS=$'\n'
  for NODE in ${NODES} ; do
    NAME=${NODE%%$'\t'*}
    ID=${NODE##*$'\t'}
    # echo ${ID}
    echo ";${NAME} = "
  done;
}

function get_node_name() {
  echo -e "${1}" | jq -r ".nodes | .[] | select(.id == \"${2}\") | .name"
}

function get_connections() {
  echo -e '\n[Flowmap.Edges]'
  CONNECTIONS=$(echo "${1}" | jq -r '.edges | .[] | [.sourceNode, .targetNode] | @tsv')
  IFS=$'\n'
  for CONNECTION in $CONNECTIONS ; do
    SOURCE=${CONNECTION%%$'\t'*}
    TARGET=${CONNECTION##*$'\t'}
    echo ";!replaceFlowMapConnection($(get_node_name "${1}" "${SOURCE}"), $(get_node_name "${1}" "${TARGET}")) ="
  done;
}


FLOWMAP=$(get_flowmap ${APPLICATION_ID})


get_header
get_applications
get_nodes "${FLOWMAP}"
get_connections "${FLOWMAP}"
get_bts
