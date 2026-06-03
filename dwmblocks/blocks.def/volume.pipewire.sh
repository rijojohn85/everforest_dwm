#!/bin/sh
# Volume + mute state of the default pipewire/pulse sink.
# Triggered by ../daemons/pulse_daemon.sh on sink events.
sink="$(pactl get-default-sink 2>/dev/null)"
[ -n "$sink" ] || exit 0
mute="$(pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}')"
vol="$(pactl get-sink-volume "$sink" 2>/dev/null | awk -F'/' 'NR==1 {gsub(/ /,"",$2); print $2}')"
[ -z "$vol" ] && vol="?"
ON=$(printf '\357\200\250')   # nerd-font speaker
OFF=$(printf '\357\152\232')  # nerd-font speaker-mute
if [ "$mute" = "yes" ]; then
    printf "%s %s" "$OFF" "$vol"
else
    printf "%s %s" "$ON" "$vol"
fi
