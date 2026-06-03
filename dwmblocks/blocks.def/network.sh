#!/bin/sh
ICON=$(printf "\357\203\254")
ip="$(ip route get 8.8.8.8 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1); exit}')"
[ -z "$ip" ] && ip="offline"
printf "%s %s" "$ICON" "$ip"
