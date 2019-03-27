#!/bin/bash

SHIFTS=0
declare -i SHIFTS
shiftOptInd() {
  SHIFTS=$OPTIND
  SHIFTS=${SHIFTS}-1
  OPTIND=0
  return $SHIFTS
}
