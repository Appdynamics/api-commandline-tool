#!/bin/bash
LATEST_RELEASE=`git tag | tail -n 1`
LATEST_COMMIT=`git rev-parse HEAD`
awk '
    $1 == "source" {system("tail -n +2 " $2); next}
    {print}
' main.sh | sed '/^\s*$/d' \
          | sed "s/ADC_VERSION=\"vx.y.z\"/ADC_VERSION=\"$LATEST_RELEASE\"/" \
          | sed "s/ADC_LAST_COMMIT=\"xxxxxxxxxx\"/ADC_LAST_COMMIT=\"$LATEST_COMMIT\"/" > adc.sh
