#!/bin/sh
ICON=$(printf '\357\211\200')
read -r capacity </sys/class/power_supply/BAT0/capacity
printf "%s %s%%" "$ICON" "$capacity"
