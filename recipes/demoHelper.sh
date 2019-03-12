#!/bin/bash
APPLICATIONS=$(../act.sh -E demo2 application list | grep "<name>" | sed "s# *<name>\([^<]*\)</name>#\1#g")

OLDIFS=$IFS
IFS=$'\n'
echo '[Applications]'
for APPLICATION in ${APPLICATIONS}; do
  echo "# !hideApplication(${APPLICATION})"
done;
for APPLICATION in ${APPLICATIONS}; do
  echo "# ${APPLICATION} = "
done;

APPLICATIONS="ECommerce"

for APPLICATION in ${APPLICATIONS}; do
  echo -e '\n[Tiers]'
  TIERS=$(../act.sh -E demo2 tier list -a $APPLICATION | grep "<name>" | sed "s# *<name>\([^<]*\)</name>#\1#g")
  for TIER in ${TIERS}; do
      echo "# ${TIER} = ";
  done;
  echo -e '\n[Business Transactions]'
  BTS=$(../act.sh -E demo2 bt list -a $APPLICATION | grep "<name>" | sed "s# *<name>\([^<]*\)</name>#\1#g")
  for BT in ${BTS}; do
    if [ "${BT}" != "_APPDYNAMICS_DEFAULT_TX_" ] ; then
      echo "# !hideBT(${BT})";
    fi;
  done;
  for BT in ${BTS}; do
    if [ "${BT}" != "_APPDYNAMICS_DEFAULT_TX_" ] ; then
      echo "# ${BT} = ";
    fi;
  done;
  echo -e '\n[Backends]'
  BACKENDS=$(../act.sh -E demo2 backend list -a $APPLICATION | grep "<name>" | sed "s# *<name>\([^<]*\)</name>#\1#g")
  for BACKEND in ${BACKENDS}; do
      echo "# ${BACKEND} = ";
  done;
done;
IFS=$OLDIFS
