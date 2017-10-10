#!/bin/bash

awk '
    $1 == "source" {system("tail -n +2 " $2); next}
    {print}
' main.sh | sed '/^\s*$/d' > adc.sh
