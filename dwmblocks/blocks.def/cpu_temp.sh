#!/bin/sh
ICON=$(printf '\357\213\233')
crit=70
read -r temp </sys/class/thermal/thermal_zone0/temp
temp="${temp%???}"
printf "%s %s°C" "$ICON" "$temp"
